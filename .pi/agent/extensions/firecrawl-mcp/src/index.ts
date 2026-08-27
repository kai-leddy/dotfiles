import { createRequire } from "node:module";
import { dirname, join } from "node:path";
import { pathToFileURL } from "node:url";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { z } from "zod";
import { zodToJsonSchema } from "zod-to-json-schema";

// Wraps @neuralmux/omp-firecrawl (unchanged, full fork: scrape, search, map, crawl,
// crawl_status, crawl_cancel, batch_scrape, batch_scrape_status, extract — 9 tools)
// behind a 2-tool list_tools/call_tool facade so only 2 schemas hit the per-turn
// context instead of 9. Original tool logic/behavior is untouched; we just capture
// its registerTool() calls into a private registry instead of exposing them directly.
//
// omp-firecrawl is a declared dependency (package.json) so `npm install` here keeps
// it pinned and present, independent of settings.json's top-level packages list.

const require = createRequire(import.meta.url);
const OMP_FIRECRAWL_ROOT = dirname(require.resolve("@neuralmux/omp-firecrawl/package.json"));
const TOOL_FILES = ["scrape", "search", "map", "crawl", "batch-scrape", "extract"];

type CapturedTool = {
  name: string;
  description: string;
  parameters: z.ZodTypeAny;
  execute: (
    toolCallId: string,
    params: unknown,
    signal: AbortSignal | undefined,
    onUpdate: unknown,
    ctx: ExtensionContext,
  ) => Promise<unknown>;
};

export default async function (pi: ExtensionAPI) {
  const registry = new Map<string, CapturedTool>();

  // Fake ExtensionAPI handed to the original register(pi) functions: registerTool
  // is captured locally instead of reaching the model; everything else (commands,
  // events, zod) is forwarded to the real pi so unrelated behavior is preserved.
  const shim = {
    zod: { z },
    registerTool(def: CapturedTool) {
      registry.set(def.name, def);
    },
    registerCommand: pi.registerCommand.bind(pi),
    on: pi.on.bind(pi),
  } as unknown as ExtensionAPI;

  for (const file of TOOL_FILES) {
    const url = pathToFileURL(join(OMP_FIRECRAWL_ROOT, "src", "tools", `${file}.ts`)).href;
    const mod = (await import(url)) as { register: (pi: ExtensionAPI) => void };
    mod.register(shim);
  }

  pi.registerTool({
    name: "list_tools",
    label: "Firecrawl: List tools",
    description:
      "List available Firecrawl tools (scrape, search, map, crawl, batch scrape, extract) with their parameter schemas. Call this before call_tool if you don't already know the exact tool name and arguments.",
    parameters: { type: "object", properties: {}, additionalProperties: false } as any,
    executionMode: "sequential",
    async execute() {
      const tools = Array.from(registry.values()).map((t) => ({
        name: t.name,
        description: t.description,
        parameters: zodToJsonSchema(t.parameters),
      }));
      return { content: [{ type: "text", text: JSON.stringify(tools, null, 2) }] };
    },
  });

  pi.registerTool({
    name: "call_tool",
    label: "Firecrawl: Call tool",
    description:
      "Invoke one Firecrawl tool by name with arguments (e.g. firecrawl_scrape, firecrawl_search, firecrawl_map, firecrawl_crawl, firecrawl_batch_scrape, firecrawl_extract). Use list_tools first to see available names and parameter schemas.",
    parameters: {
      type: "object",
      properties: {
        name: { type: "string", description: "Tool name from list_tools, e.g. firecrawl_scrape." },
        arguments: { type: "object", description: "Arguments matching that tool's parameter schema." },
      },
      required: ["name", "arguments"],
      additionalProperties: false,
    } as any,
    executionMode: "sequential",
    async execute(
      toolCallId: string,
      params: { name: string; arguments?: unknown },
      signal: AbortSignal | undefined,
      onUpdate: unknown,
      ctx: ExtensionContext,
    ) {
      const tool = registry.get(params.name);
      if (!tool) {
        const names = Array.from(registry.keys()).join(", ");
        return {
          content: [{ type: "text", text: `Unknown tool "${params.name}". Available: ${names}` }],
          isError: true,
        };
      }
      let parsed: unknown;
      try {
        parsed = tool.parameters.parse(params.arguments ?? {});
      } catch (error) {
        return { content: [{ type: "text", text: `Invalid arguments: ${String(error)}` }], isError: true };
      }
      return tool.execute(toolCallId, parsed, signal, onUpdate, ctx) as Promise<any>;
    },
  });
}
