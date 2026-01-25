import { z } from 'zod';

/**
 * Copy Patterns schema - defines reusable patterns for UI copy situations
 */

export const CopyPatternVariantSchema = z.object({
  template: z.string().describe('The copy template with {{placeholders}}'),
  tone: z.string().optional().describe('Tone variant: neutral, friendly, urgent, etc.'),
  length: z.enum(['short', 'medium', 'long']).optional(),
});

export const CopyPatternSchema = z.object({
  id: z.string().describe('Unique identifier for this pattern'),
  name: z.string().describe('Human-readable name'),
  category: z.enum([
    'error',
    'empty-state',
    'success',
    'loading',
    'confirmation',
    'onboarding',
    'tooltip',
    'notification',
    'modal',
    'form-validation',
    'navigation',
    'feature-gate',
    'upgrade-prompt',
    'other'
  ]).describe('Category of UI situation'),
  description: z.string().optional().describe('When to use this pattern'),

  variants: z.array(CopyPatternVariantSchema).min(1).describe('Available copy variants'),

  guidelines: z.array(z.string()).default([]).describe('Guidelines for using this pattern'),

  examples: z.object({
    good: z.array(z.string()).default([]),
    bad: z.array(z.string()).default([]),
  }).default({ good: [], bad: [] }),

  placeholders: z.record(z.object({
    description: z.string(),
    examples: z.array(z.string()).default([]),
    required: z.boolean().default(true),
  })).optional().describe('Placeholder definitions'),

  metadata: z.object({
    maxLength: z.number().optional().describe('Max character length'),
    minLength: z.number().optional().describe('Min character length'),
    requiresAction: z.boolean().optional().describe('Whether pattern should include a CTA'),
  }).optional(),
});

export const CopyPatternsSchema = z.object({
  version: z.string().default('1.0'),
  name: z.string().describe('Name of this pattern library'),
  description: z.string().optional(),
  patterns: z.array(CopyPatternSchema),
});

export type CopyPatternVariant = z.infer<typeof CopyPatternVariantSchema>;
export type CopyPattern = z.infer<typeof CopyPatternSchema>;
export type CopyPatterns = z.infer<typeof CopyPatternsSchema>;
