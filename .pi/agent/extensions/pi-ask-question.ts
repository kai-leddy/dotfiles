import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

type Question = {
	question: string;
	type: "choice" | "text";
	choices?: string[];
	default?: string;
	placeholder?: string;
};

type Answer = { question: string; type: Question["type"]; answer: string | null };

// Kept dependency-free: Pi accepts a JSON Schema-compatible object here.
const Parameters = {
	type: "object",
	properties: {
		questions: {
			type: "array",
			description: "Questions to ask, in order. Use choice for a finite list and text for free-form input.",
			items: {
				type: "object",
				properties: {
					question: { type: "string", description: "The question shown to the user" },
					type: { type: "string", enum: ["choice", "text"] },
					choices: { type: "array", items: { type: "string" }, description: "Required for choice questions" },
					default: { type: "string" },
					placeholder: { type: "string" },
				},
				required: ["question", "type"],
				additionalProperties: false,
			},
		},
	},
	required: ["questions"],
	additionalProperties: false,
} as any;

function resultText(answers: Answer[], cancelled = false): string {
	return JSON.stringify({ answers, cancelled }, null, 2);
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "ask_user_question",
		label: "Ask user question",
		description: "Ask the user for information instead of guessing. Supports mixed multiple-choice and free-form questions.",
		parameters: Parameters,
		executionMode: "sequential",
		renderCall(args, theme) {
			const questions = ((args as { questions?: Question[] }).questions ?? []) as Question[];
			const lines = questions
				.filter((question): question is Question => Boolean(question?.question))
				.map((question) => theme.fg("accent", `? ${question.question}`));
			return new Text([theme.fg("dim", "asking the user a question"), ...lines].join("\n"), 0, 0);
		},
		renderResult(result, _options, theme, context) {
			const details = result.details as { answers?: Answer[]; cancelled?: boolean } | undefined;
			const answers = details?.answers ?? [];
			if (!answers.length) {
				const text = result.content.find((item) => item.type === "text")?.text ?? "No answer";
				return new Text(theme.fg(context.isError ? "error" : "warning", text), 0, 0);
			}

			const lines = answers.map((answer) => theme.fg("success", `→ ${answer.answer || "—"}`));
			if (details?.cancelled) lines.push(theme.fg("warning", "Cancelled"));
			return new Text(lines.join("\n"), 0, 0);
		},
		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const questions = (params as { questions?: Question[] }).questions ?? [];
			if (ctx.mode !== "tui") {
				return { content: [{ type: "text", text: "User input is unavailable outside interactive TUI mode." }], details: { answers: [], cancelled: true }, isError: true };
			}
			if (!questions.length) {
				return { content: [{ type: "text", text: "No questions were provided." }], details: { answers: [], cancelled: true }, isError: true };
			}

			const answers: Answer[] = [];
			try {
				for (let index = 0; index < questions.length; index++) {
					const q = questions[index];
					if (!q || typeof q.question !== "string") continue;

					let answer: string | undefined;
					if (q.type === "choice") {
						const choices = Array.isArray(q.choices) ? q.choices.filter((v): v is string => typeof v === "string") : [];
						if (!choices.length) continue;
						answer = await ctx.ui.select(q.question, choices, { signal: _signal });
					} else {
						answer = await ctx.ui.input(q.question, q.placeholder ?? q.default, { signal: _signal });
					}
					if (answer === undefined) {
						return { content: [{ type: "text", text: resultText(answers, true) }], details: { answers, cancelled: true } };
					}
					answers.push({ question: q.question, type: q.type, answer: answer || q.default || "" });
				}
				return { content: [{ type: "text", text: resultText(answers) }], details: { answers, cancelled: false } };
			} catch (error) {
				return { content: [{ type: "text", text: resultText(answers, true) }], details: { answers, cancelled: true, error: String(error) } };
			}
		},
	});
}
