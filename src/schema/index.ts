import { z } from 'zod';

// Re-export all schemas
export * from './voice.js';
export * from './copy-patterns.js';
export * from './cta-rules.js';
export * from './tokens.js';
export * from './tests.js';

import { VoiceSchema } from './voice.js';
import { CopyPatternsSchema } from './copy-patterns.js';
import { CTARulesSchema } from './cta-rules.js';
import { TokensSchema } from './tokens.js';
import { TestSuiteSchema } from './tests.js';

/**
 * StyleMCP Pack - a complete, versioned style package
 */
export const PackManifestSchema = z.object({
  name: z.string().describe('Pack name (e.g., "saas", "devtool", "fintech")'),
  version: z.string().describe('Semantic version'),
  description: z.string().optional(),
  author: z.string().optional(),
  license: z.string().optional(),

  files: z.object({
    voice: z.string().default('voice.yaml'),
    copyPatterns: z.string().default('copy_patterns.yaml'),
    ctaRules: z.string().default('cta_rules.yaml'),
    tokens: z.string().default('tokens.json'),
    tests: z.string().default('tests.yaml'),
  }).default({}),

  extends: z.string().optional().describe('Parent pack to extend from'),

  config: z.object({
    strictMode: z.boolean().default(false).describe('Fail on any violation'),
    minScore: z.number().min(0).max(100).default(70).describe('Minimum passing score'),
  }).default({}),
});

export const PackSchema = z.object({
  manifest: PackManifestSchema,
  voice: VoiceSchema,
  copyPatterns: CopyPatternsSchema,
  ctaRules: CTARulesSchema,
  tokens: TokensSchema,
  tests: TestSuiteSchema,
});

export type PackManifest = z.infer<typeof PackManifestSchema>;
export type Pack = z.infer<typeof PackSchema>;

/**
 * Validation result types
 */
export const ViolationSchema = z.object({
  id: z.string(),
  rule: z.string(),
  severity: z.enum(['error', 'warning', 'info']),
  message: z.string(),
  position: z.object({
    start: z.number(),
    end: z.number(),
  }).optional(),
  text: z.string().optional().describe('The violating text'),
  suggestion: z.string().optional(),
});

export const ValidationResultSchema = z.object({
  valid: z.boolean(),
  score: z.number().min(0).max(100),
  input: z.string(),
  violations: z.array(ViolationSchema),
  summary: z.object({
    errors: z.number(),
    warnings: z.number(),
    info: z.number(),
  }),
  metadata: z.object({
    packName: z.string(),
    packVersion: z.string(),
    validatedAt: z.string(),
  }),
});

export const RewriteResultSchema = z.object({
  original: z.string(),
  rewritten: z.string(),
  changes: z.array(z.object({
    type: z.enum(['replace', 'insert', 'delete']),
    original: z.string(),
    replacement: z.string(),
    reason: z.string(),
    position: z.object({
      start: z.number(),
      end: z.number(),
    }),
  })),
  score: z.object({
    before: z.number(),
    after: z.number(),
  }),
});

export type Violation = z.infer<typeof ViolationSchema>;
export type ValidationResult = z.infer<typeof ValidationResultSchema>;
export type RewriteResult = z.infer<typeof RewriteResultSchema>;
