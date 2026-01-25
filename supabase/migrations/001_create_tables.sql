-- StyleMCP Database Schema
-- Run this in your Supabase SQL editor

-- pgcrypto provides gen_random_uuid() which is available by default in Supabase

-- Subscription tiers
create type subscription_tier as enum ('free', 'pro', 'team', 'enterprise');

-- Users table (extends Supabase auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  tier subscription_tier default 'free' not null,
  stripe_customer_id text unique,
  stripe_subscription_id text unique,
  api_key text unique default ('sk_' || replace(gen_random_uuid()::text, '-', '')),
  monthly_request_limit integer default 1000,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- API usage tracking
create table public.api_usage (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  endpoint text not null,
  method text not null,
  status_code integer,
  response_time_ms integer,
  created_at timestamp with time zone default now()
);

-- Monthly usage summary (for faster lookups)
create table public.usage_summary (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  month date not null, -- First day of the month
  request_count integer default 0,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  unique(user_id, month)
);

-- Custom style packs per user
create table public.user_packs (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  name text not null,
  description text,
  config jsonb not null default '{}',
  voice jsonb not null default '{}',
  copy_patterns jsonb not null default '{}',
  cta_rules jsonb not null default '{}',
  is_public boolean default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Indexes for performance
create index idx_api_usage_user_id on public.api_usage(user_id);
create index idx_api_usage_created_at on public.api_usage(created_at);
create index idx_usage_summary_user_month on public.usage_summary(user_id, month);
create index idx_profiles_api_key on public.profiles(api_key);
create index idx_profiles_stripe_customer on public.profiles(stripe_customer_id);

-- Row Level Security
alter table public.profiles enable row level security;
alter table public.api_usage enable row level security;
alter table public.usage_summary enable row level security;
alter table public.user_packs enable row level security;

-- Policies: Users can only see their own data
create policy "Users can view own profile" on public.profiles
  for select using (auth.uid() = id);

create policy "Users can update own profile" on public.profiles
  for update using (auth.uid() = id);

create policy "Users can view own usage" on public.api_usage
  for select using (auth.uid() = user_id);

create policy "Users can view own summary" on public.usage_summary
  for select using (auth.uid() = user_id);

create policy "Users can manage own packs" on public.user_packs
  for all using (auth.uid() = user_id);

create policy "Users can view public packs" on public.user_packs
  for select using (is_public = true);

-- Service role can do everything (for API backend)
create policy "Service role full access profiles" on public.profiles
  for all using (auth.role() = 'service_role');

create policy "Service role full access usage" on public.api_usage
  for all using (auth.role() = 'service_role');

create policy "Service role full access summary" on public.usage_summary
  for all using (auth.role() = 'service_role');

-- Function to create profile on user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email);
  return new;
end;
$$ language plpgsql security definer;

-- Trigger to auto-create profile
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Function to increment usage counter
create or replace function public.increment_usage(p_user_id uuid, p_endpoint text, p_method text, p_status integer, p_time_ms integer)
returns boolean as $$
declare
  v_month date;
  v_limit integer;
  v_count integer;
begin
  v_month := date_trunc('month', now())::date;

  -- Get user's limit and current count
  select monthly_request_limit into v_limit from public.profiles where id = p_user_id;
  select coalesce(request_count, 0) into v_count from public.usage_summary where user_id = p_user_id and month = v_month;

  -- Check if over limit
  if v_count >= v_limit then
    return false;
  end if;

  -- Log the request
  insert into public.api_usage (user_id, endpoint, method, status_code, response_time_ms)
  values (p_user_id, p_endpoint, p_method, p_status, p_time_ms);

  -- Update or insert summary
  insert into public.usage_summary (user_id, month, request_count)
  values (p_user_id, v_month, 1)
  on conflict (user_id, month)
  do update set request_count = public.usage_summary.request_count + 1, updated_at = now();

  return true;
end;
$$ language plpgsql security definer;

-- Function to get usage stats
create or replace function public.get_usage_stats(p_user_id uuid)
returns json as $$
declare
  v_month date;
  v_profile record;
  v_usage record;
begin
  v_month := date_trunc('month', now())::date;

  select * into v_profile from public.profiles where id = p_user_id;
  select * into v_usage from public.usage_summary where user_id = p_user_id and month = v_month;

  return json_build_object(
    'tier', v_profile.tier,
    'limit', v_profile.monthly_request_limit,
    'used', coalesce(v_usage.request_count, 0),
    'remaining', v_profile.monthly_request_limit - coalesce(v_usage.request_count, 0),
    'reset_date', (v_month + interval '1 month')::date
  );
end;
$$ language plpgsql security definer;

-- Tier limits configuration
comment on table public.profiles is 'Tier limits: free=1000, pro=50000, team=250000, enterprise=unlimited';
