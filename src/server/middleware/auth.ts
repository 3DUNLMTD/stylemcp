import { Request, Response, NextFunction } from 'express';
import { validateApiKey, checkQuota, recordUsage, isBillingEnabled, UserProfile, UsageStats } from '../billing.js';

// Extend Express Request to include user info
declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      user?: UserProfile;
      usageStats?: UsageStats;
      requestStart?: number;
    }
  }
}

const LEGACY_API_KEY = process.env.STYLEMCP_API_KEY || '';

// Authentication middleware
export async function authMiddleware(req: Request, res: Response, next: NextFunction): Promise<void> {
  req.requestStart = Date.now();

  // If billing is not enabled, fall back to legacy API key
  if (!isBillingEnabled()) {
    if (LEGACY_API_KEY) {
      const providedKey = req.headers['x-api-key'] || req.query.api_key;
      if (providedKey !== LEGACY_API_KEY) {
        res.status(401).json({ error: 'Invalid or missing API key' });
        return;
      }
    }
    next();
    return;
  }

  // Get API key from header or query
  const apiKey = (req.headers['x-api-key'] || req.query.api_key) as string;

  if (!apiKey) {
    res.status(401).json({
      error: 'API key required',
      docs: 'https://stylemcp.com/docs#authentication'
    });
    return;
  }

  // Validate API key
  const user = await validateApiKey(apiKey);

  if (!user) {
    res.status(401).json({
      error: 'Invalid API key',
      docs: 'https://stylemcp.com/docs#authentication'
    });
    return;
  }

  // Check quota
  const { allowed, stats } = await checkQuota(user.id);

  if (!allowed) {
    res.status(429).json({
      error: 'Monthly request limit exceeded',
      usage: stats,
      upgrade_url: 'https://stylemcp.com/pricing',
    });
    return;
  }

  // Attach user and stats to request
  req.user = user;
  req.usageStats = stats;

  // Add usage headers
  res.setHeader('X-RateLimit-Limit', stats.limit);
  res.setHeader('X-RateLimit-Remaining', stats.remaining - 1);
  res.setHeader('X-RateLimit-Reset', stats.reset_date);

  next();
}

// Response logging middleware (call after response is sent)
export function usageLogger(req: Request, res: Response, next: NextFunction): void {
  // Hook into response finish to log usage
  res.on('finish', async () => {
    if (req.user && isBillingEnabled()) {
      const responseTime = req.requestStart ? Date.now() - req.requestStart : 0;

      await recordUsage(
        req.user.id,
        req.path,
        req.method,
        res.statusCode,
        responseTime
      );
    }
  });

  next();
}

// Optional auth - doesn't require key but attaches user if provided
export async function optionalAuth(req: Request, res: Response, next: NextFunction): Promise<void> {
  if (!isBillingEnabled()) {
    next();
    return;
  }

  const apiKey = (req.headers['x-api-key'] || req.query.api_key) as string;

  if (apiKey) {
    const user = await validateApiKey(apiKey);
    if (user) {
      const { stats } = await checkQuota(user.id);
      req.user = user;
      req.usageStats = stats;
    }
  }

  next();
}
