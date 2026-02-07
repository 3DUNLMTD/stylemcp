import { describe, expect, test, vi, beforeEach } from 'vitest';
import { captureError } from './error-capture.js';

// Mock getSupabase to return null (no DB in tests)
vi.mock('./billing.js', () => ({
  getSupabase: () => null,
}));

describe('Error Capture', () => {
  beforeEach(() => {
    vi.spyOn(console, 'error').mockImplementation(() => {});
  });

  test('classifies pack not found as pack_load error', async () => {
    const result = await captureError(new Error('Pack not found: foobar'));
    // Should be healed (pack cache reload)
    expect(result.healed).toBe(true);
    expect(result.action).toBe('pack_cache_reload');
  });

  test('classifies rate limit as ai_service error', async () => {
    const result = await captureError(new Error('Rate limit exceeded (429)'));
    expect(result.healed).toBe(true);
    expect(result.action).toBe('rate_limit_backoff');
  });

  test('classifies auth expired as auth_failure', async () => {
    const result = await captureError(new Error('JWT expired'));
    expect(result.healed).toBe(true);
    expect(result.action).toBe('session_refresh_signal');
  });

  test('classifies validation errors as healed (user error)', async () => {
    const result = await captureError(new Error('Validation failed: missing text field'));
    expect(result.healed).toBe(true);
    expect(result.action).toBe('user_error_ignored');
  });

  test('unknown errors are not healed', async () => {
    const result = await captureError(new Error('Something completely unexpected happened'));
    expect(result.healed).toBe(false);
  });

  test('handles non-Error values', async () => {
    const result = await captureError('string error');
    expect(result).toBeDefined();
    expect(typeof result.healed).toBe('boolean');
  });

  test('handles null/undefined', async () => {
    const result = await captureError(null);
    expect(result).toBeDefined();
  });

  test('classifies Claude timeout as AI service error with fallback', async () => {
    const result = await captureError(new Error('Anthropic API timeout'));
    expect(result.healed).toBe(true);
    expect(result.action).toBe('fallback_rule_based');
  });

  test('classifies OOM as critical', async () => {
    const result = await captureError(new Error('ENOMEM: out of memory'));
    // OOM is not auto-healed
    expect(result.healed).toBe(false);
  });
});
