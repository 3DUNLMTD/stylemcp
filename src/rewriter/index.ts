import { Pack, RewriteResult } from '../schema/index.js';
import { validate } from '../validator/index.js';

// Re-export AI rewriter
export { aiRewrite, isAIRewriteAvailable, estimateAIRewriteCost } from './ai-rewriter.js';
export type { AIRewriteOptions, AIRewriteResult } from './ai-rewriter.js';

export interface RewriteOptions {
  pack: Pack;
  text: string;
  context?: {
    type?: 'ui-copy' | 'marketing' | 'docs' | 'support' | 'general';
    component?: string;
  };
  /** Only apply fixes for these severity levels */
  fixSeverity?: ('error' | 'warning' | 'info')[];
  /** Maximum number of changes to apply */
  maxChanges?: number;
}

export interface Change {
  type: 'replace' | 'insert' | 'delete';
  original: string;
  replacement: string;
  reason: string;
  position: {
    start: number;
    end: number;
  };
}

/**
 * Rewrite text to conform to style rules
 * Makes minimal changes based on detected violations
 */
export function rewrite(options: RewriteOptions): RewriteResult {
  const {
    pack,
    text,
    context,
    fixSeverity = ['error', 'warning'],
    maxChanges = 50,
  } = options;

  // First, validate to get violations
  const validation = validate({ pack, text, context });

  // Filter violations that match severity and have positions
  const candidateViolations = validation.violations
    .filter(v => fixSeverity.includes(v.severity))
    .filter(v => v.position);

  // Dedupe violations at the same position (keep the one with best fixability)
  const positionMap = new Map<string, typeof candidateViolations[0]>();
  for (const v of candidateViolations) {
    const key = `${v.position!.start}-${v.position!.end}`;
    const existing = positionMap.get(key);

    if (!existing) {
      positionMap.set(key, v);
    } else {
      // Prefer vocabulary.preferred (auto-fixable) over vocabulary.forbidden
      if (v.rule === 'vocabulary.preferred' && existing.rule === 'vocabulary.forbidden') {
        positionMap.set(key, v);
      }
      // Otherwise keep the existing (first one found)
    }
  }

  const fixableViolations = Array.from(positionMap.values()).slice(0, maxChanges);

  // Sort by position (descending) so we can apply changes from end to start
  // This prevents position shifts from affecting subsequent changes
  const sortedViolations = [...fixableViolations].sort(
    (a, b) => (b.position?.start || 0) - (a.position?.start || 0)
  );

  let rewritten = text;
  const changes: Change[] = [];

  for (const violation of sortedViolations) {
    if (!violation.position) continue;

    const { start, end } = violation.position;
    const original = rewritten.slice(start, end);

    // Determine replacement based on violation type
    let replacement: string | null = null;

    if (violation.rule === 'vocabulary.preferred' && violation.suggestion) {
      // For vocabulary preferences, the suggestion is the preferred word
      replacement = matchCase(original, violation.suggestion);
    } else if (violation.rule === 'vocabulary.forbidden') {
      // For forbidden words, we can't just replace - we need manual review
      // Skip auto-fixing forbidden words
      continue;
    } else if (violation.rule.startsWith('doNot.') || violation.rule.startsWith('cta.')) {
      // For doNot patterns and CTA issues, we usually can't auto-fix
      // These need human review
      continue;
    } else {
      // For other violations, skip if we can't determine a safe replacement
      continue;
    }

    if (replacement === null) continue;

    // Apply the change
    rewritten = rewritten.slice(0, start) + replacement + rewritten.slice(end);

    changes.push({
      type: replacement === '' ? 'delete' : 'replace',
      original,
      replacement,
      reason: violation.message,
      position: { start, end },
    });
  }

  // Re-validate to get new score
  const afterValidation = validate({ pack, text: rewritten, context });

  // Reverse changes array so it's in document order
  changes.reverse();

  return {
    original: text,
    rewritten,
    changes,
    score: {
      before: validation.score,
      after: afterValidation.score,
    },
  };
}

/**
 * Apply minimal rewrites - only fix errors, leave warnings as-is
 */
export function rewriteMinimal(options: Omit<RewriteOptions, 'fixSeverity'>): RewriteResult {
  return rewrite({ ...options, fixSeverity: ['error'] });
}

/**
 * Apply aggressive rewrites - fix everything including info-level issues
 */
export function rewriteAggressive(options: Omit<RewriteOptions, 'fixSeverity'>): RewriteResult {
  return rewrite({ ...options, fixSeverity: ['error', 'warning', 'info'] });
}

/**
 * Match the case pattern of the original word
 */
function matchCase(original: string, replacement: string): string {
  if (!original || !replacement) return replacement;

  // All uppercase
  if (original === original.toUpperCase()) {
    return replacement.toUpperCase();
  }

  // Title case (first letter uppercase)
  if (original[0] === original[0].toUpperCase()) {
    return replacement.charAt(0).toUpperCase() + replacement.slice(1).toLowerCase();
  }

  // All lowercase
  if (original === original.toLowerCase()) {
    return replacement.toLowerCase();
  }

  return replacement;
}

/**
 * Generate a diff-like view of changes
 */
export function formatChanges(result: RewriteResult): string {
  if (result.changes.length === 0) {
    return 'No changes made.';
  }

  const lines: string[] = [
    `Score: ${result.score.before} → ${result.score.after}`,
    '',
    'Changes:',
  ];

  for (const change of result.changes) {
    lines.push(`  - "${change.original}" → "${change.replacement}"`);
    lines.push(`    Reason: ${change.reason}`);
  }

  return lines.join('\n');
}

/**
 * Generate a unified diff format
 */
export function generateDiff(result: RewriteResult): string {
  const lines: string[] = [];

  // Simple line-by-line diff
  const originalLines = result.original.split('\n');
  const rewrittenLines = result.rewritten.split('\n');

  lines.push('--- original');
  lines.push('+++ rewritten');

  const maxLines = Math.max(originalLines.length, rewrittenLines.length);

  for (let i = 0; i < maxLines; i++) {
    const orig = originalLines[i] || '';
    const rewr = rewrittenLines[i] || '';

    if (orig !== rewr) {
      if (orig) lines.push(`- ${orig}`);
      if (rewr) lines.push(`+ ${rewr}`);
    } else if (orig) {
      lines.push(`  ${orig}`);
    }
  }

  return lines.join('\n');
}
