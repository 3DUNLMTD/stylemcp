-- Error Events table for Error Capture & Auto-Healing system
-- Migration: 002_error_events.sql

-- Severity enum
create type error_severity as enum ('low', 'medium', 'high', 'critical');

-- Error events table
create table public.error_events (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default now() not null,

  -- Classification
  error_type text not null,          -- 'api_error', 'pack_load', 'auth_failure', 'ai_service', 'validation', 'client', 'unknown'
  error_code text,                   -- e.g. 'PACK_CACHE_CORRUPT', 'CLAUDE_RATE_LIMIT', 'AUTH_EXPIRED'
  severity error_severity default 'medium' not null,

  -- Error details
  message text not null,
  stack_trace text,

  -- Context (flexible JSON)
  context jsonb not null default '{}',
  -- Expected keys: endpoint, method, user_id, ip, user_agent, request_body (sanitized), pack_name, etc.

  -- Auto-healing
  auto_healed boolean default false not null,
  healing_action text,               -- e.g. 'pack_cache_reload', 'retry_success', 'fallback_applied', 'session_refreshed'
  healing_details jsonb,             -- Additional info about what the healer did

  -- Resolution
  resolved boolean default false not null,
  resolved_at timestamp with time zone,
  resolved_by text                   -- 'auto', 'manual', user id, etc.
);

-- Indexes for dashboard queries
create index idx_error_events_created_at on public.error_events(created_at desc);
create index idx_error_events_type on public.error_events(error_type);
create index idx_error_events_severity on public.error_events(severity);
create index idx_error_events_unresolved on public.error_events(resolved, created_at desc) where resolved = false;
create index idx_error_events_code on public.error_events(error_code) where error_code is not null;

-- Composite index for dashboard time-series queries
create index idx_error_events_type_created on public.error_events(error_type, created_at desc);

-- RLS
alter table public.error_events enable row level security;

-- Service role full access (API backend writes errors)
create policy "Service role full access error_events" on public.error_events
  for all using (auth.role() = 'service_role');

-- Authenticated users can view errors (dashboard — restrict further if needed)
create policy "Authenticated users can view errors" on public.error_events
  for select using (auth.role() = 'authenticated');

-- Helper: get error summary for dashboard
create or replace function public.get_error_summary(
  p_hours integer default 24
)
returns json as $$
declare
  v_since timestamp with time zone;
  v_total bigint;
  v_by_type json;
  v_by_severity json;
  v_healed bigint;
  v_unresolved bigint;
begin
  v_since := now() - (p_hours || ' hours')::interval;

  select count(*) into v_total
    from public.error_events where created_at >= v_since;

  select json_agg(row_to_json(t)) into v_by_type
    from (
      select error_type, count(*) as count
        from public.error_events
        where created_at >= v_since
        group by error_type
        order by count desc
    ) t;

  select json_agg(row_to_json(t)) into v_by_severity
    from (
      select severity::text, count(*) as count
        from public.error_events
        where created_at >= v_since
        group by severity
        order by count desc
    ) t;

  select count(*) into v_healed
    from public.error_events
    where created_at >= v_since and auto_healed = true;

  select count(*) into v_unresolved
    from public.error_events
    where resolved = false;

  return json_build_object(
    'period_hours', p_hours,
    'since', v_since,
    'total', v_total,
    'auto_healed', v_healed,
    'unresolved', v_unresolved,
    'by_type', coalesce(v_by_type, '[]'::json),
    'by_severity', coalesce(v_by_severity, '[]'::json)
  );
end;
$$ language plpgsql security definer;

-- Cleanup: auto-delete resolved events older than 90 days (run via pg_cron or manually)
-- SELECT cron.schedule('cleanup-old-errors', '0 3 * * 0', $$
--   DELETE FROM public.error_events WHERE resolved = true AND created_at < now() - interval '90 days';
-- $$);
