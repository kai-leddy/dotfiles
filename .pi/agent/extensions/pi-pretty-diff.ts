import { execFileSync, spawn } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MAX_RENDER_BYTES = 80 * 1024;
type ToolText = { type: "text"; text: string };
type ToolResult = {
  toolName?: string;
  input?: Record<string, unknown>;
  content?: ToolText[];
  details?: { diff?: string; patch?: string };
  isError?: boolean;
};

type ToolContext = { cwd: string };

function commandAvailable(command: string): boolean {
  try {
    execFileSync(command, ["--version"], { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

function truncate(text: string): string {
  if (Buffer.byteLength(text) <= MAX_RENDER_BYTES) return text;
  return `${Buffer.from(text).subarray(0, MAX_RENDER_BYTES).toString()}\n\n[Output truncated]`;
}

function textContent(text: string): ToolText[] {
  return [{ type: "text", text: truncate(text) }];
}

function firstText(result: ToolResult): string {
  return result.content?.filter((part) => part.type === "text").map((part) => part.text).join("\n") ?? "";
}

function run(command: string, args: string[], input: string | undefined, cwd: string): Promise<string | undefined> {
  return new Promise((resolve) => {
    const child = spawn(command, args, { cwd, stdio: ["pipe", "pipe", "ignore"] });
    let output = "";
    let settled = false;
    const finish = (value?: string) => {
      if (settled) return;
      settled = true;
      resolve(value);
    };
    child.stdout.on("data", (chunk: Buffer) => {
      output += chunk.toString();
      if (Buffer.byteLength(output) > MAX_RENDER_BYTES * 2) child.kill();
    });
    child.once("error", () => finish());
    child.once("close", (code) => finish(code === 0 ? output.replace(/\n$/, "") : undefined));
    if (input !== undefined) child.stdin.end(input);
    else child.stdin.end();
  });
}

function lsdListing(path: string | undefined, cwd: string): string | undefined {
  try {
    const args = ["-l"];
    if (path) args.push(path);
    return execFileSync("lsd", args, { cwd, encoding: "utf8", maxBuffer: MAX_RENDER_BYTES }).trimEnd();
  } catch {
    return undefined;
  }
}

function gitDiff(path: string, cwd: string): string | undefined {
  try {
    return execFileSync("git", ["diff", "--no-ext-diff", "--", path], {
      cwd,
      encoding: "utf8",
      maxBuffer: MAX_RENDER_BYTES,
    }).trimEnd();
  } catch {
    return undefined;
  }
}

/**
 * Render built-in Pi tool results with the user's installed terminal tools.
 * The tool_result event is the supported interception point: returning content
 * replaces the default result text without changing tool execution or context.
 */
export default function (pi: ExtensionAPI) {
  pi.on("tool_result", async (event, ctx) => {
    const result = event as ToolResult;
    if (result.isError) return;

    if (result.toolName === "read" && commandAvailable("bat")) {
      const path = typeof result.input?.path === "string" ? result.input.path : undefined;
      if (!path) return;
      const rendered = await run("bat", ["--style=numbers,changes", "--color=always", "--paging=never", path], undefined, (ctx as ToolContext).cwd);
      if (rendered) return { content: textContent(rendered) };
    }

    if (result.toolName === "bash" && commandAvailable("bat")) {
      const output = firstText(result);
      if (!output.trim()) return;
      const rendered = await run("bat", ["--style=plain", "--color=always", "--paging=never", "--language=sh"], output, (ctx as ToolContext).cwd);
      if (rendered) return { content: textContent(rendered) };
    }

    if (result.toolName === "ls" && commandAvailable("lsd")) {
      const path = typeof result.input?.path === "string" ? result.input.path : undefined;
      const rendered = lsdListing(path, (ctx as ToolContext).cwd);
      if (rendered) return { content: textContent(rendered) };
    }

    if ((result.toolName === "edit" || result.toolName === "write") && commandAvailable("delta")) {
      const path = typeof result.input?.path === "string" ? result.input.path : undefined;
      const diff = result.details?.patch || result.details?.diff || (path ? gitDiff(path, (ctx as ToolContext).cwd) : undefined);
      if (!diff?.trim()) return;

      const unified = await run("delta", ["--pager=never"], diff, (ctx as ToolContext).cwd);
      const split = await run("delta", ["--side-by-side", "--pager=never"], diff, (ctx as ToolContext).cwd);
      if (unified || split) {
        const rendered = [unified ? `Unified diff\n${unified}` : "", split ? `Side-by-side diff\n${split}` : ""]
          .filter(Boolean)
          .join("\n\n");
        return { content: textContent(rendered) };
      }
    }
  });
}
