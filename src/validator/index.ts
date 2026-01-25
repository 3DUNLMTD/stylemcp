import { Pack, ValidationResult, Violation } from '../schema/index.js';
import { checkVoiceRules } from './rules/voice.js';
import { checkCtaRules } from './rules/cta.js';
import { checkConstraints } from './rules/constraints.js';

export interface ValidateOptions {
  pack: Pack;
  text: string;
  context?: {
    type?: 'ui-copy' | 'marketing' | 'docs' | 'support' | 'general';
    component?: string;
  };
}

export interface ValidatorConfig {
  strictMode?: boolean;
  minScore?: number;
}

/**
 * Main validation function
 */
export function validate(options: ValidateOptions): ValidationResult {
  const { pack, text, context } = options;
  const violations: Violation[] = [];

  // Run all rule checkers
  violations.push(...checkVoiceRules(text, pack.voice));
  violations.push(...checkCtaRules(text, pack.ctaRules, context));
  violations.push(...checkConstraints(text, pack.voice.constraints));

  // Calculate score
  const score = calculateScore(violations);

  // Determine if valid based on pack config
  const minScore = pack.manifest.config?.minScore ?? 70;
  const strictMode = pack.manifest.config?.strictMode ?? false;

  const hasErrors = violations.some(v => v.severity === 'error');
  const valid = strictMode
    ? violations.length === 0
    : score >= minScore && !hasErrors;

  return {
    valid,
    score,
    input: text,
    violations,
    summary: {
      errors: violations.filter(v => v.severity === 'error').length,
      warnings: violations.filter(v => v.severity === 'warning').length,
      info: violations.filter(v => v.severity === 'info').length,
    },
    metadata: {
      packName: pack.manifest.name,
      packVersion: pack.manifest.version,
      validatedAt: new Date().toISOString(),
    },
  };
}

/**
 * Calculate a 0-100 score based on violations
 */
function calculateScore(violations: Violation[]): number {
  if (violations.length === 0) return 100;

  // Weight by severity
  const weights = {
    error: 25,
    warning: 10,
    info: 3,
  };

  const totalPenalty = violations.reduce((sum, v) => sum + weights[v.severity], 0);

  // Cap penalty at 100
  const score = Math.max(0, 100 - totalPenalty);
  return Math.round(score);
}

export { checkVoiceRules } from './rules/voice.js';
export { checkCtaRules } from './rules/cta.js';
export { checkConstraints } from './rules/constraints.js';
