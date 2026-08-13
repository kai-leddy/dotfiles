import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import { basename } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

const MAX_OUTPUT_BYTES = 50 * 1024;

type SideQuestEntry = {
  task: string;
  status: "running" | "completed" | "failed";
  output?: string;
};

type PiEvent = {
  type?: string;
  message?: {
    role?: string;
    content?: Array<{ type?: string; text?: string }>;
  };
};

function assistantText(event: PiEvent): string | undefined {
  if (event.type !== "message_end" || event.message?.role !== "assistant") return;
  return event.message.content?.find((part) => part.type === "text")?.text;
}

function truncateOutput(output: string): string {
  return Buffer.byteLength(output) <= MAX_OUTPUT_BYTES
    ? output
    : `${Buffer.from(output).subarray(0, MAX_OUTPUT_BYTES).toString()}\n\n[Output truncated]`;
}

function getPiInvocation(args: string[]): { command: string; args: string[] } {
  const currentScript = process.argv[1];
  if (currentScript && !currentScript.startsWith("/$bunfs/root/") && existsSync(currentScript)) {
    return { command: process.execPath, args: [currentScript, ...args] };
  }

  if (!/^(node|bun)(\.exe)?$/.test(basename(process.execPath).toLowerCase())) {
    return { command: process.execPath, args };
  }

  return { command: "pi", args };
}

export default function (pi: ExtensionAPI) {
  let running = 0;

  pi.registerEntryRenderer("side-quest", (entry, _options, theme) => {
    const data = entry.data as SideQuestEntry;
    const icon = data.status === "running" ? "…" : data.status === "completed" ? "✓" : "✗";
    const color = data.status === "failed" ? "error" : data.status === "completed" ? "success" : "warning";
    let text = theme.fg(color, `${icon} Side quest: ${data.status}`);
    text += `\n${theme.fg("dim", data.task)}`;
    if (data.output) text += `\n\n${data.output}`;
    return new Text(text, 0, 0);
  });

  pi.registerCommand("side-quest", {
    description: "Run an unrelated task in an isolated Pi subagent",
    handler: async (args, ctx) => {
      const task = args.trim();
      if (!task) {
        ctx.ui.notify("Usage: /side-quest <task>", "warning");
        return;
      }

      pi.appendEntry("side-quest", { task, status: "running" } satisfies SideQuestEntry);
      running++;
      ctx.ui.setStatus("side-quest", `Side quest running (${running})`);

      const invocation = getPiInvocation(["--mode", "json", "-p", "--no-session", task]);
      const child = spawn(invocation.command, invocation.args, {
        cwd: ctx.cwd,
        stdio: ["ignore", "pipe", "pipe"],
      });
      let output = "";
      let stderr = "";
      let buffer = "";
      let finished = false;

      const finish = (code: number | null, error?: string) => {
        if (finished) return;
        finished = true;
        running--;
        ctx.ui.setStatus("side-quest", running ? `Side quest running (${running})` : undefined);
        const failed = error || code !== 0;
        pi.appendEntry("side-quest", {
          task,
          status: failed ? "failed" : "completed",
          output: truncateOutput(output || error || stderr || "(no output)"),
        } satisfies SideQuestEntry);
      };

      const processLine = (line: string) => {
        try {
          const text = assistantText(JSON.parse(line) as PiEvent);
          if (text) output = text;
        } catch {
          // Ignore non-JSON output from the child process.
        }
      };

      child.stdout.on("data", (data: Buffer) => {
        buffer += data.toString();
        const lines = buffer.split("\n");
        buffer = lines.pop() ?? "";
        lines.forEach(processLine);
      });
      child.stderr.on("data", (data: Buffer) => (stderr += data));
      child.once("error", (error) => finish(null, error.message));
      child.once("close", (code) => {
        if (buffer) processLine(buffer);
        finish(code);
      });
    },
  });
}
