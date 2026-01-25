import { z } from 'zod';

/**
 * CTA Rules schema - defines call-to-action patterns and guidelines
 */

export const CTASchema = z.object({
  id: z.string().describe('Unique identifier'),
  text: z.string().describe('The CTA text'),
  context: z.array(z.string()).describe('Contexts where this CTA is appropriate'),
  priority: z.enum(['primary', 'secondary', 'tertiary']).default('primary'),
  action: z.string().optional().describe('What action this CTA triggers'),
});

export const CTACategorySchema = z.object({
  name: z.string().describe('Category name'),
  description: z.string().optional(),
  ctas: z.array(CTASchema),
});

export const CTAGuidelinesSchema = z.object({
  verbStyle: z.enum(['imperative', 'infinitive', 'gerund']).default('imperative')
    .describe('Verb style: "Save" vs "To save" vs "Saving"'),
  maxWords: z.number().default(4).describe('Maximum words in a CTA'),
  capitalization: z.enum(['sentence', 'title', 'uppercase', 'lowercase']).default('sentence'),
  avoidWords: z.array(z.string()).default([]).describe('Words to avoid in CTAs'),
  preferWords: z.array(z.string()).default([]).describe('Preferred action words'),
});

export const CTAAntiPatternSchema = z.object({
  pattern: z.string().describe('The anti-pattern text or regex'),
  isRegex: z.boolean().default(false),
  reason: z.string().describe('Why this is an anti-pattern'),
  suggestion: z.string().optional().describe('What to use instead'),
});

export const CTARulesSchema = z.object({
  version: z.string().default('1.0'),
  name: z.string().describe('Name of this CTA ruleset'),
  description: z.string().optional(),

  guidelines: CTAGuidelinesSchema.default({}),

  categories: z.array(CTACategorySchema).describe('CTA categories with approved CTAs'),

  antiPatterns: z.array(CTAAntiPatternSchema).default([]).describe('CTA patterns to avoid'),

  contextualRules: z.array(z.object({
    context: z.string().describe('Context description'),
    required: z.array(z.string()).default([]).describe('Required CTA elements'),
    forbidden: z.array(z.string()).default([]).describe('Forbidden CTA elements'),
    preferred: z.array(z.string()).default([]).describe('Preferred CTAs for this context'),
  })).default([]),
});

export type CTA = z.infer<typeof CTASchema>;
export type CTACategory = z.infer<typeof CTACategorySchema>;
export type CTAGuidelines = z.infer<typeof CTAGuidelinesSchema>;
export type CTAAntiPattern = z.infer<typeof CTAAntiPatternSchema>;
export type CTARules = z.infer<typeof CTARulesSchema>;
