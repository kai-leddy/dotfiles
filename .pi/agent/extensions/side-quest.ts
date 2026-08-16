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

type SubagentEvent = {
  id?: string;
  request_id?: string;
  side_quest_id?: string;
  description?: string;
  result?: unknown;
  error?: unknown;
  status?: string;
};

type ActiveRpcQuest = {
  task: string;
  sideQuestId: string;
  agentId?: string;
  updateStatus: (running: number) => void;
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

function eventText(value: unknown): string | undefined {
  if (typeof value === "string") return value;
  if (value && typeof value === "object") {
    const result = value as { text?: unknown; result?: unknown; message?: unknown };
    if (typeof result.text === "string") return result.text;
    if (typeof result.result === "string") return result.result;
    if (typeof result.message === "string") return result.message;
  }
  return value === undefined ? undefined : String(value);
}

export default function (pi: ExtensionAPI) {
  let running = 0;
  let subagentsReady = false;
  const activeRpcQuests = new Map<string, ActiveRpcQuest>();

  const completeQuest = (
    quest: ActiveRpcQuest,
    failed: boolean,
    output: string,
  ) => {
    if (!activeRpcQuests.has(quest.sideQuestId)) return;
    activeRpcQuests.delete(quest.sideQuestId);
    running--;
    quest.updateStatus(running);
    pi.appendEntry("side-quest", {
      task: quest.task,
      status: failed ? "failed" : "completed",
      output: truncateOutput(output || (failed ? "(subagent failed)" : "(no output)")),
    } satisfies SideQuestEntry);
  };

  // The ready event is the capability probe. The RPC was intentionally kept
  // event-based so this extension remains optional and does not require the
  // subagents package as a hard import-time dependency.
  pi.events.on("subagents:ready", () => {
    subagentsReady = true;
  });

  pi.events.on("subagents:created", (raw: unknown) => {
    const event = (raw ?? {}) as SubagentEvent;
    for (const quest of activeRpcQuests.values()) {
      if (
        event.side_quest_id === quest.sideQuestId ||
        event.request_id === quest.sideQuestId ||
        event.description === `Side quest (${quest.sideQuestId})`
      ) {
        quest.agentId = event.id;
        break;
      }
    }
  });

  const handleTerminalEvent = (raw: unknown, failed: boolean) => {
    const event = (raw ?? {}) as SubagentEvent;
    for (const quest of activeRpcQuests.values()) {
      const matches =
        (quest.agentId && event.id === quest.agentId) ||
        event.side_quest_id === quest.sideQuestId ||
        event.request_id === quest.sideQuestId ||
        event.description === `Side quest (${quest.sideQuestId})`;
      if (!matches) continue;

      const output = eventText(failed ? event.error : event.result) ?? "";
      completeQuest(quest, failed || event.status === "error", output);
      break;
    }
  };

  pi.events.on("subagents:completed", (event: unknown) => handleTerminalEvent(event, false));
  pi.events.on("subagents:failed", (event: unknown) => handleTerminalEvent(event, true));

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

      const sideQuestId = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;

      if (subagentsReady) {
        const quest: ActiveRpcQuest = {
          task,
          sideQuestId,
          updateStatus: (count) =>
            ctx.ui.setStatus("side-quest", count ? `Side quest running (${count})` : undefined),
        };
        activeRpcQuests.set(sideQuestId, quest);

        try {
          pi.events.emit("subagents:rpc:spawn", {
            prompt: task,
            description: `Side quest (${sideQuestId})`,
            subagent_type: "general-purpose",
            run_in_background: true,
          });
          return;
        } catch (error) {
          activeRpcQuests.delete(sideQuestId);
          running--;
          ctx.ui.notify(`Subagents RPC unavailable; using standalone Pi process (${String(error)})`, "warning");
        }
      } else {
        ctx.ui.notify("Subagents system not loaded; using standalone Pi process", "warning");
      }

      // Compatibility fallback for sessions where pi-subagents is not loaded.
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
