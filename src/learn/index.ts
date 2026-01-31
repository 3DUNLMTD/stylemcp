/**
 * Learn My Voice
 * Analyzes sample content to generate a custom style pack
 */

export interface LearnVoiceOptions {
  /** Sample texts to analyze */
  samples: string[];
  /** Brand/company name */
  brandName: string;
  /** Industry for context */
  industry?: string;
  /** Additional context about the brand */
  context?: string;
  /** API key for Claude */
  apiKey?: string;
}

export interface LearnedVoice {
  /** Generated pack name (slug) */
  packName: string;
  /** Display name */
  displayName: string;
  /** Pack manifest */
  manifest: {
    name: string;
    version: string;
    description: string;
    industry: string;
  };
  /** Generated voice configuration */
  voice: {
    tone: {
      summary: string;
      attributes: Array<{ name: string; weight: number; description: string }>;
    };
    vocabulary: {
      rules: Array<{ preferred: string; avoid: string[]; reason: string }>;
      forbidden: string[];
    };
    doNot: Array<{ pattern: string; reason: string; suggestion: string }>;
    examples: {
      good: Array<{ text: string; why: string }>;
      bad: Array<{ text: string; why: string; better: string }>;
    };
  };
  /** Analysis metadata */
  analysis: {
    samplesAnalyzed: number;
    totalWords: number;
    tokensUsed: { input: number; output: number };
    confidence: number;
  };
}

const LEARN_SYSTEM_PROMPT = `You are a brand voice analyst. Your job is to analyze sample content and extract a comprehensive style guide.

Given sample texts from a brand, identify:

1. TONE ATTRIBUTES
   - What emotional qualities does the writing convey? (e.g., confident, friendly, professional, playful)
   - Weight each attribute 0.0-1.0 based on how strongly it appears

2. VOCABULARY PATTERNS
   - What specific words or phrases does this brand prefer?
   - What words seem to be avoided?
   - Any industry-specific terminology?

3. WRITING PATTERNS TO AVOID (doNot)
   - Clichés or phrases that seem intentionally avoided
   - Structures or patterns not used (e.g., exclamation points, questions in headers)

4. GOOD vs BAD EXAMPLES
   - Extract 3-5 good examples directly from the samples
   - Generate 3-5 "bad" examples that would violate the voice, with corrections

Return a JSON object with this exact structure:
{
  "tone": {
    "summary": "A 1-2 sentence description of the overall voice",
    "attributes": [
      { "name": "confident", "weight": 0.8, "description": "Uses direct statements, avoids hedging" }
    ]
  },
  "vocabulary": {
    "rules": [
      { "preferred": "help", "avoid": ["assist", "aid"], "reason": "More conversational" }
    ],
    "forbidden": ["leverage", "synergy", "utilize"]
  },
  "doNot": [
    { "pattern": "!", "reason": "Brand avoids exclamation points", "suggestion": "Use periods for measured tone" }
  ],
  "examples": {
    "good": [
      { "text": "Example from samples", "why": "Demonstrates confidence and clarity" }
    ],
    "bad": [
      { "text": "Bad example", "why": "Too formal", "better": "Corrected version" }
    ]
  },
  "confidence": 0.85
}

Be specific and actionable. Extract real patterns from the samples, don't just generate generic rules.`;

/**
 * Analyze sample content and generate a custom style pack
 */
export async function learnVoice(options: LearnVoiceOptions): Promise<LearnedVoice> {
  const { samples, brandName, industry = 'general', context, apiKey } = options;

  const effectiveApiKey = apiKey || process.env.ANTHROPIC_API_KEY;
  
  if (!effectiveApiKey) {
    throw new Error('Learning voice requires an Anthropic API key. Set ANTHROPIC_API_KEY environment variable or pass apiKey option.');
  }

  if (samples.length === 0) {
    throw new Error('At least one sample text is required');
  }

  // Prepare samples for analysis
  const sampleText = samples
    .map((s, i) => `--- Sample ${i + 1} ---\n${s.trim()}`)
    .join('\n\n');
  
  const totalWords = samples.reduce((sum, s) => sum + s.split(/\s+/).length, 0);

  const userPrompt = `Analyze the following content samples from "${brandName}" (industry: ${industry}).

${context ? `Additional context: ${context}\n\n` : ''}SAMPLES:

${sampleText}

Based on these samples, extract the brand voice rules. Be specific - reference actual patterns you see in the samples.`;

  // Call Claude API
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 60000); // 60s timeout for analysis

  let response: Response;
  try {
    response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': effectiveApiKey,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: 'claude-3-5-sonnet-20241022',
        max_tokens: 4096,
        system: LEARN_SYSTEM_PROMPT,
        messages: [
          { role: 'user', content: userPrompt }
        ],
      }),
      signal: controller.signal,
    });
  } catch (err) {
    if (err instanceof Error && err.name === 'AbortError') {
      throw new Error('Voice learning request timed out after 60 seconds');
    }
    throw err;
  } finally {
    clearTimeout(timeout);
  }

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Claude API error: ${response.status} - ${error}`);
  }

  const data = await response.json() as {
    content: Array<{ type: string; text: string }>;
    usage: { input_tokens: number; output_tokens: number };
  };

  const responseText = data.content[0]?.text?.trim() || '';
  
  // Extract JSON from response (handle markdown code blocks)
  let jsonStr = responseText;
  const jsonMatch = responseText.match(/```(?:json)?\s*([\s\S]*?)```/);
  if (jsonMatch) {
    jsonStr = jsonMatch[1].trim();
  }

  let parsed: {
    tone: LearnedVoice['voice']['tone'];
    vocabulary: LearnedVoice['voice']['vocabulary'];
    doNot: LearnedVoice['voice']['doNot'];
    examples: LearnedVoice['voice']['examples'];
    confidence: number;
  };

  try {
    parsed = JSON.parse(jsonStr);
  } catch {
    throw new Error('Failed to parse voice analysis response');
  }

  // Generate pack name from brand name
  const packName = brandName
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');

  return {
    packName,
    displayName: brandName,
    manifest: {
      name: brandName,
      version: '1.0.0',
      description: `Custom style pack for ${brandName}`,
      industry,
    },
    voice: {
      tone: parsed.tone,
      vocabulary: parsed.vocabulary,
      doNot: parsed.doNot,
      examples: parsed.examples,
    },
    analysis: {
      samplesAnalyzed: samples.length,
      totalWords,
      tokensUsed: {
        input: data.usage?.input_tokens || 0,
        output: data.usage?.output_tokens || 0,
      },
      confidence: parsed.confidence || 0.7,
    },
  };
}

/**
 * Generate YAML files for a learned voice pack
 */
export function generatePackFiles(learned: LearnedVoice): { manifest: string; voice: string } {
  const manifestYaml = `# ${learned.displayName} Style Pack
# Generated by StyleMCP Learn My Voice

name: ${learned.manifest.name}
version: ${learned.manifest.version}
description: ${learned.manifest.description}
industry: ${learned.manifest.industry}
`;

  const voiceYaml = `# Voice configuration for ${learned.displayName}
# Generated by StyleMCP Learn My Voice

tone:
  summary: "${learned.voice.tone.summary.replace(/"/g, '\\"')}"
  attributes:
${learned.voice.tone.attributes.map(a => `    - name: ${a.name}
      weight: ${a.weight}
      description: "${a.description.replace(/"/g, '\\"')}"`).join('\n')}

vocabulary:
  rules:
${learned.voice.vocabulary.rules.map(r => `    - preferred: "${r.preferred}"
      avoid: [${r.avoid.map(a => `"${a}"`).join(', ')}]
      reason: "${r.reason.replace(/"/g, '\\"')}"`).join('\n')}
  forbidden:
${learned.voice.vocabulary.forbidden.map(f => `    - "${f}"`).join('\n')}

doNot:
${learned.voice.doNot.map(d => `  - pattern: "${d.pattern.replace(/"/g, '\\"')}"
    reason: "${d.reason.replace(/"/g, '\\"')}"
    suggestion: "${d.suggestion.replace(/"/g, '\\"')}"`).join('\n')}

examples:
  good:
${learned.voice.examples.good.map(e => `    - text: "${e.text.replace(/"/g, '\\"')}"
      why: "${e.why.replace(/"/g, '\\"')}"`).join('\n')}
  bad:
${learned.voice.examples.bad.map(e => `    - text: "${e.text.replace(/"/g, '\\"')}"
      why: "${e.why.replace(/"/g, '\\"')}"
      better: "${e.better.replace(/"/g, '\\"')}"`).join('\n')}
`;

  return { manifest: manifestYaml, voice: voiceYaml };
}

/**
 * Check if voice learning is available
 */
export function isLearnVoiceAvailable(): boolean {
  return !!process.env.ANTHROPIC_API_KEY;
}
