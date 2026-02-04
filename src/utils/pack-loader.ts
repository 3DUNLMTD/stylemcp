import { readFile, stat } from 'fs/promises';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import * as yaml from 'js-yaml';
import {
  Pack,
  PackManifest,
  PackManifestSchema,
  VoiceSchema,
  CopyPatternsSchema,
  CTARulesSchema,
  TokensSchema,
  TestSuiteSchema,
  Voice,
  CopyPatterns,
  CTARules,
  Tokens,
  TestSuite,
} from '../schema/index.js';

export interface LoadPackOptions {
  packPath: string;
  /** Skip cache and force reload from disk */
  noCache?: boolean;
}

export interface PackLoadResult {
  pack: Pack;
  errors: string[];
  /** Whether the result was served from cache */
  cached?: boolean;
}

// ─────────────────────────────────────────────────────────────────────────────
// Pack Cache - reduces disk I/O for repeated validations
// ─────────────────────────────────────────────────────────────────────────────

interface CacheEntry {
  result: PackLoadResult;
  manifestMtime: number;
  cachedAt: number;
}

const CACHE_TTL_MS = 60_000; // 1 minute
const CACHE_MAX_SIZE = 20;
const packCache = new Map<string, CacheEntry>();

const AVAILABLE_PACKS_TTL_MS = 30_000; // 30 seconds

type AvailablePacksCache = { names: string[]; cachedAt: number; dirMtime: number };
let availablePacksCache: AvailablePacksCache | null = null;
let availablePacksInFlight: Promise<string[]> | null = null;

async function getManifestMtime(packPath: string): Promise<number> {
  try {
    const manifestPath = join(packPath, 'manifest.yaml');
    const stats = await stat(manifestPath);
    return stats.mtimeMs;
  } catch {
    return 0;
  }
}

function isCacheValid(entry: CacheEntry, currentMtime: number): boolean {
  const now = Date.now();
  const age = now - entry.cachedAt;
  // Invalid if TTL expired or manifest was modified
  return age < CACHE_TTL_MS && entry.manifestMtime === currentMtime;
}

function pruneCache(): void {
  if (packCache.size <= CACHE_MAX_SIZE) return;
  // Remove oldest entries (FIFO - Map maintains insertion order)
  const excess = packCache.size - CACHE_MAX_SIZE;
  const keys = Array.from(packCache.keys()).slice(0, excess);
  keys.forEach(k => packCache.delete(k));
}

/** Clear the pack cache (useful for testing or after file changes) */
export function clearPackCache(): void {
  packCache.clear();
  availablePacksCache = null;
  availablePacksInFlight = null;
}

/** Get cache stats for monitoring */
export function getPackCacheStats(): { size: number; maxSize: number; ttlMs: number } {
  return { size: packCache.size, maxSize: CACHE_MAX_SIZE, ttlMs: CACHE_TTL_MS };
}

async function loadYamlFile<T>(filePath: string, schema: { parse: (data: unknown) => T }): Promise<T> {
  const content = await readFile(filePath, 'utf-8');
  const data = yaml.load(content);
  return schema.parse(data);
}

async function loadJsonFile<T>(filePath: string, schema: { parse: (data: unknown) => T }): Promise<T> {
  const content = await readFile(filePath, 'utf-8');
  const data = JSON.parse(content);
  return schema.parse(data);
}

export async function loadPack(options: LoadPackOptions): Promise<PackLoadResult> {
  const { packPath, noCache } = options;
  const errors: string[] = [];

  // Check cache first (unless noCache is set)
  if (!noCache) {
    const cached = packCache.get(packPath);
    if (cached) {
      const currentMtime = await getManifestMtime(packPath);
      if (isCacheValid(cached, currentMtime)) {
        return { ...cached.result, cached: true };
      }
      // Cache invalid, remove stale entry
      packCache.delete(packPath);
    }
  }

  // Load manifest
  const manifestPath = join(packPath, 'manifest.yaml');
  let manifest: PackManifest;
  try {
    manifest = await loadYamlFile(manifestPath, PackManifestSchema);
  } catch (err) {
    throw new Error(`Failed to load manifest: ${err instanceof Error ? err.message : err}`);
  }

  const files = manifest.files;

  // Load all pack components in parallel for faster initial loads
  const [voiceResult, copyPatternsResult, ctaRulesResult, tokensResult, testsResult] = await Promise.allSettled([
    loadYamlFile(join(packPath, files.voice), VoiceSchema),
    loadYamlFile(join(packPath, files.copyPatterns), CopyPatternsSchema),
    loadYamlFile(join(packPath, files.ctaRules), CTARulesSchema),
    loadJsonFile(join(packPath, files.tokens), TokensSchema),
    loadYamlFile(join(packPath, files.tests), TestSuiteSchema),
  ]);

  // Extract results with fallbacks for failures
  let voice: Voice;
  if (voiceResult.status === 'fulfilled') {
    voice = voiceResult.value;
  } else {
    errors.push(`Failed to load voice: ${voiceResult.reason instanceof Error ? voiceResult.reason.message : voiceResult.reason}`);
    voice = VoiceSchema.parse({ name: 'default', tone: { attributes: [] }, vocabulary: { rules: [] } });
  }

  let copyPatterns: CopyPatterns;
  if (copyPatternsResult.status === 'fulfilled') {
    copyPatterns = copyPatternsResult.value;
  } else {
    errors.push(`Failed to load copy patterns: ${copyPatternsResult.reason instanceof Error ? copyPatternsResult.reason.message : copyPatternsResult.reason}`);
    copyPatterns = CopyPatternsSchema.parse({ name: 'default', patterns: [] });
  }

  let ctaRules: CTARules;
  if (ctaRulesResult.status === 'fulfilled') {
    ctaRules = ctaRulesResult.value;
  } else {
    errors.push(`Failed to load CTA rules: ${ctaRulesResult.reason instanceof Error ? ctaRulesResult.reason.message : ctaRulesResult.reason}`);
    ctaRules = CTARulesSchema.parse({ name: 'default', categories: [] });
  }

  let tokens: Tokens;
  if (tokensResult.status === 'fulfilled') {
    tokens = tokensResult.value;
  } else {
    errors.push(`Failed to load tokens: ${tokensResult.reason instanceof Error ? tokensResult.reason.message : tokensResult.reason}`);
    tokens = TokensSchema.parse({ name: 'default' });
  }

  let tests: TestSuite;
  if (testsResult.status === 'fulfilled') {
    tests = testsResult.value;
  } else {
    errors.push(`Failed to load tests: ${testsResult.reason instanceof Error ? testsResult.reason.message : testsResult.reason}`);
    tests = TestSuiteSchema.parse({ name: 'default', tests: [] });
  }

  const result: PackLoadResult = {
    pack: {
      manifest,
      voice,
      copyPatterns,
      ctaRules,
      tokens,
      tests,
    },
    errors,
    cached: false,
  };

  // Cache the result
  const manifestMtime = await getManifestMtime(packPath);
  packCache.set(packPath, {
    result,
    manifestMtime,
    cachedAt: Date.now(),
  });
  pruneCache();

  return result;
}

export function getPacksDirectory(): string {
  // Get the packs directory relative to this file
  const currentDir = dirname(fileURLToPath(import.meta.url));
  return join(currentDir, '..', '..', 'packs');
}

export async function listAvailablePacks(): Promise<string[]> {
  const { readdir } = await import('fs/promises');
  const packsDir = getPacksDirectory();

  // If a scan is already running, await it to avoid duplicate FS reads.
  if (availablePacksInFlight) return availablePacksInFlight;

  const now = Date.now();

  // Use directory mtime as an invalidation signal so adding/removing packs doesn't
  // get stuck behind the TTL.
  let dirMtime = 0;
  try {
    dirMtime = (await stat(packsDir)).mtimeMs;
  } catch {
    dirMtime = 0;
  }

  if (
    availablePacksCache &&
    now - availablePacksCache.cachedAt < AVAILABLE_PACKS_TTL_MS &&
    availablePacksCache.dirMtime === dirMtime
  ) {
    return availablePacksCache.names;
  }

  availablePacksInFlight = (async () => {
    try {
      const entries = await readdir(packsDir, { withFileTypes: true });
      const names = entries.filter(e => e.isDirectory()).map(e => e.name);
      // Re-stat to capture mtime after reading in case it changed mid-scan.
      let freshDirMtime = dirMtime;
      try {
        freshDirMtime = (await stat(packsDir)).mtimeMs;
      } catch {
        freshDirMtime = 0;
      }
      availablePacksCache = { names, cachedAt: Date.now(), dirMtime: freshDirMtime };
      return names;
    } catch {
      availablePacksCache = null;
      return [];
    } finally {
      availablePacksInFlight = null;
    }
  })();

  return availablePacksInFlight;
}
