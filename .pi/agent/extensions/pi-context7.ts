import { execFileSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const CREDENTIALS_PATH = join(homedir(), ".config", "context7", "credentials.json");
const MAX_OUTPUT = 100_000;

/**
 * Read CONTEXT7_API_KEY from credentials file, or return undefined.
 * The CLI auto-discovers this file, but passing it as an env var guarantees it works.
 */
function getApiKey(): string | undefined {
  try {
    const data = JSON.parse(readFileSync(CREDENTIALS_PATH, "utf8")) as {
      access_token?: string;
      token_type?: string;
      scope?: string;
    };
    return data.access_token;
  } catch {
    return undefined;
  }
}

/** Run `npx ctx7@latest <args>` and return stdout. */
function runCtx7(args: string[]): string {
  const env: Record<string, string | undefined> = { ...process.env };
  const apiKey = getApiKey();
  if (apiKey) env.CONTEXT7_API_KEY = apiKey;

  try {
    const stdout = execFileSync("npx", ["ctx7@latest", ...args], {
      env,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
      timeout: 30_000,
      maxBuffer: MAX_OUTPUT,
    });
    return stdout.trim();
  } catch (error: unknown) {
    const err = error as { stderr?: string; stdout?: string; message?: string };
    const stderr = err.stderr?.toString().trim() ?? "";
    const stdout = err.stdout?.toString().trim() ?? "";
    const message = err.message ?? String(error);
    // Quota errors from Context7 look like "Monthly quota reached"
    if (
      stderr.toLowerCase().includes("quota") ||
      message.toLowerCase().includes("quota")
    ) {
      return `**Context7 quota exhausted.**\n${stderr || "Monthly quota reached — authenticate with 'npx ctx7@latest login' or set CONTEXT7_API_KEY."}`;
    }
    return `Error: ${message}\n${stderr || stdout ? `\n${stderr || stdout}` : ""}`.trim();
  }
}

const LibraryParameters = {
  type: "object",
  properties: {
    name: {
      type: "string",
      description:
        "Library or package name to resolve (e.g. 'React', 'Next.js', 'Prisma')",
    },
    query: {
      type: "string",
      description:
        "Search/context query that affects result ranking (e.g. 'How to clean up useEffect')",
    },
  },
  required: ["name", "query"],
  additionalProperties: false,
} as any;

const DocsParameters = {
  type: "object",
  properties: {
    libraryId: {
      type: "string",
      description:
        "Library ID in /org/project format (e.g. '/facebook/react'). Resolve unknown IDs with ctx7_library first.",
    },
    query: {
      type: "string",
      description:
        "Documentation query — one topic, descriptive (e.g. 'useEffect cleanup function with async')",
    },
  },
  required: ["libraryId", "query"],
  additionalProperties: false,
} as any;

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "ctx7_library",
    label: "Context7: Resolve library",
    description:
      "Resolve a library or package name to a Context7 library ID. Run this FIRST before ctx7_docs to find the correct /org/project ID.",
    parameters: LibraryParameters,
    executionMode: "sequential",
    async execute(
      _toolCallId,
      params: { name?: string; query?: string },
      _signal,
      _onUpdate,
      _ctx,
    ) {
      const name = params.name ?? "";
      const query = params.query ?? "";
      if (!name || !query) {
        return {
          content: [
            { type: "text", text: "Both 'name' and 'query' are required." },
          ],
          isError: true,
        };
      }
      const output = runCtx7(["library", name, query]);
      return { content: [{ type: "text", text: output }] };
    },
  });

  pi.registerTool({
    name: "ctx7_docs",
    label: "Context7: Query docs",
    description:
      "Query documentation for a resolved library ID. Use ctx7_library first to find the /org/project ID.",
    parameters: DocsParameters,
    executionMode: "sequential",
    async execute(
      _toolCallId,
      params: { libraryId?: string; query?: string },
      _signal,
      _onUpdate,
      _ctx,
    ) {
      const libraryId = params.libraryId ?? "";
      const query = params.query ?? "";
      if (!libraryId || !query) {
        return {
          content: [
            { type: "text", text: "Both 'libraryId' and 'query' are required." },
          ],
          isError: true,
        };
      }
      const output = runCtx7(["docs", libraryId, query]);
      return { content: [{ type: "text", text: output }] };
    },
  });
}