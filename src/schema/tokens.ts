import { z } from 'zod';

/**
 * Design Tokens schema - defines colors, typography, spacing, etc.
 */

export const ColorTokenSchema = z.object({
  value: z.string().describe('Color value (hex, rgb, hsl)'),
  description: z.string().optional(),
  usage: z.array(z.string()).default([]).describe('Where this color should be used'),
});

export const TypographyTokenSchema = z.object({
  fontFamily: z.string(),
  fontSize: z.string().describe('Size with unit (px, rem, em)'),
  fontWeight: z.union([z.string(), z.number()]),
  lineHeight: z.union([z.string(), z.number()]),
  letterSpacing: z.string().optional(),
  textTransform: z.enum(['none', 'uppercase', 'lowercase', 'capitalize']).optional(),
});

export const SpacingTokenSchema = z.object({
  value: z.string().describe('Spacing value with unit'),
  description: z.string().optional(),
});

export const ShadowTokenSchema = z.object({
  value: z.string().describe('CSS box-shadow value'),
  description: z.string().optional(),
});

export const RadiusTokenSchema = z.object({
  value: z.string().describe('Border radius value'),
  description: z.string().optional(),
});

export const BreakpointTokenSchema = z.object({
  value: z.string().describe('Breakpoint value (e.g., 768px)'),
  description: z.string().optional(),
});

export const TokensSchema = z.object({
  version: z.string().default('1.0'),
  name: z.string().describe('Name of this token set'),
  description: z.string().optional(),

  colors: z.object({
    primary: z.record(ColorTokenSchema).default({}),
    secondary: z.record(ColorTokenSchema).default({}),
    neutral: z.record(ColorTokenSchema).default({}),
    semantic: z.object({
      success: z.record(ColorTokenSchema).default({}),
      warning: z.record(ColorTokenSchema).default({}),
      error: z.record(ColorTokenSchema).default({}),
      info: z.record(ColorTokenSchema).default({}),
    }).default({}),
    background: z.record(ColorTokenSchema).default({}),
    text: z.record(ColorTokenSchema).default({}),
  }).default({}),

  typography: z.object({
    fontFamilies: z.record(z.string()).default({}),
    fontWeights: z.record(z.union([z.string(), z.number()])).default({}),
    fontSizes: z.record(z.string()).default({}),
    lineHeights: z.record(z.union([z.string(), z.number()])).default({}),
    styles: z.record(TypographyTokenSchema).default({}).describe('Composite typography styles'),
  }).default({}),

  spacing: z.record(SpacingTokenSchema).default({}),

  borderRadius: z.record(RadiusTokenSchema).default({}),

  shadows: z.record(ShadowTokenSchema).default({}),

  breakpoints: z.record(BreakpointTokenSchema).default({}),

  zIndex: z.record(z.number()).default({}),

  transitions: z.object({
    duration: z.record(z.string()).default({}),
    easing: z.record(z.string()).default({}),
  }).default({}),
});

export type ColorToken = z.infer<typeof ColorTokenSchema>;
export type TypographyToken = z.infer<typeof TypographyTokenSchema>;
export type SpacingToken = z.infer<typeof SpacingTokenSchema>;
export type ShadowToken = z.infer<typeof ShadowTokenSchema>;
export type RadiusToken = z.infer<typeof RadiusTokenSchema>;
export type BreakpointToken = z.infer<typeof BreakpointTokenSchema>;
export type Tokens = z.infer<typeof TokensSchema>;
