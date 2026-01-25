import { z } from 'zod';

/**
 * Tests schema - defines test cases for validation
 */

export const TestCaseSchema = z.object({
  id: z.string().describe('Unique test identifier'),
  name: z.string().describe('Human-readable test name'),
  description: z.string().optional(),

  input: z.string().describe('Text to validate'),

  expect: z.object({
    pass: z.boolean().describe('Whether this should pass validation'),
    minScore: z.number().min(0).max(100).optional().describe('Minimum expected score'),
    maxScore: z.number().min(0).max(100).optional().describe('Maximum expected score'),
    violations: z.array(z.object({
      rule: z.string().describe('Rule ID that should be violated'),
      severity: z.enum(['error', 'warning', 'info']).optional(),
    })).optional().describe('Expected violations'),
    noViolations: z.array(z.string()).optional().describe('Rules that should NOT be violated'),
  }),

  context: z.object({
    type: z.enum(['ui-copy', 'marketing', 'docs', 'support', 'general']).optional(),
    component: z.string().optional().describe('UI component context'),
    audience: z.string().optional(),
  }).optional(),

  tags: z.array(z.string()).default([]).describe('Tags for filtering tests'),
});

export const TestSuiteSchema = z.object({
  version: z.string().default('1.0'),
  name: z.string().describe('Name of this test suite'),
  description: z.string().optional(),

  tests: z.array(TestCaseSchema),

  config: z.object({
    stopOnFirstFailure: z.boolean().default(false),
    verbose: z.boolean().default(false),
  }).default({}),
});

export type TestCase = z.infer<typeof TestCaseSchema>;
export type TestSuite = z.infer<typeof TestSuiteSchema>;
