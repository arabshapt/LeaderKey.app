#!/usr/bin/env node

import fs from "node:fs/promises";
import process from "node:process";
import {
  buildActionCatalog,
  executeDispatch,
  fastMatch,
  planDispatch,
  readBenchRows,
  readFrontmostBundleId,
  retrieveActions,
  runBench,
  type DispatchRequest,
  type DispatchScope,
  type PlannerKind,
} from "@leaderkey/dispatcher-core";
import { defaultConfigDirectory } from "@leaderkey/config-core";

function usage(): string {
  return `LeaderKey Dispatcher

Usage:
  leaderkey-dispatcher index [--catalog file | --config-dir dir] [--out file]
  leaderkey-dispatcher match [flags] "close this tab"
  leaderkey-dispatcher retrieve [flags] "kill tab"
  leaderkey-dispatcher plan [flags] "duplicate tab and copy current url"
  leaderkey-dispatcher execute [flags] "run confetti" [--dry-run|--execute] [--allow-destructive]
  leaderkey-dispatcher bench [flags] --dataset fixtures/bench.jsonl

Flags:
  --catalog file
  --config-dir dir
  --scope frontmost|global|all
  --bundle-id id
  --include-global
  --planner none|llama|ollama|groq|gemini|openai|openrouter|fireworks|together|deepinfra|perplexity|compatible
  --model name
  --llama-url url
  --ollama-url url
  --groq-api-key key
  --gemini-api-key key
  --openai-api-key key
  --openrouter-api-key key
  --fireworks-api-key key
  --together-api-key key
  --deepinfra-api-key key
  --perplexity-api-key key
  --planner-base-url url
  --always-plan
  --context-json json
  --pretty
`;
}

function readFlag(args: string[], flag: string): string | undefined {
  const index = args.indexOf(flag);
  if (index < 0) {
    return undefined;
  }
  return args[index + 1];
}

function hasFlag(args: string[], flag: string): boolean {
  return args.includes(flag);
}

function positional(args: string[]): string[] {
  const result: string[] = [];
  for (let index = 0; index < args.length; index += 1) {
    const value = args[index]!;
    if (value.startsWith("--")) {
      if (!["--include-global", "--pretty", "--dry-run", "--execute", "--allow-destructive", "--always-plan"].includes(value)) {
        index += 1;
      }
      continue;
    }
    result.push(value);
  }
  return result;
}

function print(value: unknown, pretty: boolean): void {
  process.stdout.write(`${JSON.stringify(value, null, pretty ? 2 : 0)}\n`);
}

async function requestFromArgs(args: string[], transcript: string): Promise<DispatchRequest> {
  const scope = (readFlag(args, "--scope") ?? "frontmost") as DispatchScope;
  let bundleId = readFlag(args, "--bundle-id");
  const catalogPath = readFlag(args, "--catalog");
  const contextJson = readFlag(args, "--context-json");
  if (!bundleId && !catalogPath && scope === "frontmost") {
    bundleId = await readFrontmostBundleId().catch(() => undefined);
  }

  return {
    bundleId,
    catalogPath,
    configDirectory: readFlag(args, "--config-dir") ?? defaultConfigDirectory(),
    context: contextJson ? JSON.parse(contextJson) as DispatchRequest["context"] : undefined,
    execute: hasFlag(args, "--execute") && !hasFlag(args, "--dry-run"),
    allowDestructive: hasFlag(args, "--allow-destructive"),
    alwaysPlan: hasFlag(args, "--always-plan"),
    deepinfraApiKey: readFlag(args, "--deepinfra-api-key"),
    geminiApiKey: readFlag(args, "--gemini-api-key"),
    groqApiKey: readFlag(args, "--groq-api-key"),
    fireworksApiKey: readFlag(args, "--fireworks-api-key"),
    includeGlobal: hasFlag(args, "--include-global"),
    llamaUrl: readFlag(args, "--llama-url"),
    model: readFlag(args, "--model"),
    openaiApiKey: readFlag(args, "--openai-api-key"),
    openrouterApiKey: readFlag(args, "--openrouter-api-key"),
    ollamaUrl: readFlag(args, "--ollama-url"),
    perplexityApiKey: readFlag(args, "--perplexity-api-key"),
    plannerBaseURL: readFlag(args, "--planner-base-url"),
    planner: (readFlag(args, "--planner") ?? "none") as PlannerKind,
    togetherApiKey: readFlag(args, "--together-api-key"),
    scope,
    transcript,
  };
}

async function main(): Promise<void> {
  const [, , command, ...args] = process.argv;
  const pretty = hasFlag(args, "--pretty");

  if (!command || command === "help" || command === "--help" || command === "-h") {
    process.stdout.write(usage());
    return;
  }

  if (command === "index") {
    const catalog = await buildActionCatalog({
      bundleId: readFlag(args, "--bundle-id"),
      catalogPath: readFlag(args, "--catalog"),
      configDirectory: readFlag(args, "--config-dir") ?? defaultConfigDirectory(),
      includeGlobal: hasFlag(args, "--include-global"),
      scope: (readFlag(args, "--scope") ?? "frontmost") as DispatchScope,
    });
    const output = {
      entries: catalog.entries,
      fingerprint: catalog.fingerprint,
      source: catalog.source,
    };
    const outPath = readFlag(args, "--out");
    if (outPath) {
      await fs.writeFile(outPath, JSON.stringify(output, null, 2));
      return;
    }
    print(output, pretty);
    return;
  }

  const transcript = positional(args).join(" ").trim();

  if (command === "bench") {
    const dataset = readFlag(args, "--dataset");
    if (!dataset) {
      throw new Error("bench requires --dataset");
    }
    const rows = await readBenchRows(dataset);
    const request = await requestFromArgs(args, "");
    print(await runBench(request, rows), pretty);
    return;
  }

  if (!transcript) {
    throw new Error(`${command} requires a transcript`);
  }

  if (command === "retrieve") {
    const request = await requestFromArgs(args, transcript);
    const catalog = await buildActionCatalog(request);
    print({
      candidates: retrieveActions(catalog, transcript, 12),
      fingerprint: catalog.fingerprint,
    }, pretty);
    return;
  }

  if (command === "match") {
    const request = await requestFromArgs(args, transcript);
    const catalog = await buildActionCatalog(request);
    print(fastMatch(catalog, transcript).plan, pretty);
    return;
  }

  if (command === "plan") {
    const request = await requestFromArgs(args, transcript);
    const result = await planDispatch(request);
    print({
      plan: result.plan,
      validation: result.validation,
    }, pretty);
    return;
  }

  if (command === "execute") {
    const request = await requestFromArgs(args, transcript);
    const result = await executeDispatch(request);
    print(result, pretty);
    return;
  }

  throw new Error(`Unknown command: ${command}`);
}

main().catch((error) => {
  process.stderr.write(`${error instanceof Error ? error.stack ?? error.message : String(error)}\n`);
  process.exitCode = 1;
});
