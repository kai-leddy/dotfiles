# Global preferences

- Prefer Rust-based equivalents of Unix core utilities when available:
  - Use `rg` instead of `grep` for searching.
  - Use `fd` instead of `find` for locating files.
  - Use `bat` instead of `cat` for viewing text files.
- Check that a preferred tool is installed before using it, and fall back to the standard Unix utility when it is unavailable or when its semantics are a better fit (for example, scripts requiring strict POSIX portability).
- When a request names multiple distinct tasks in one message, add each as an entry in the `todo` tool right away, even if individually small — track them as separate items regardless of size.
- When current web content or external facts are required, use the official Firecrawl MCP through `codemode`; discover its tools with `searchTools()` only when web research is actually needed.
- When completing a task requires checking documentation for a tool, library, or language to get it right, use context7 (`ctx7_library` then `ctx7_docs`) rather than relying on memory.
- The user's shell is fish (`shellPath` is set to fish in `settings.json`), so the `bash` tool and `!` commands both run fish. Always write terminal commands and scripts in fish syntax, not bash: use `set -x VAR val` instead of `export`, `(cmd)` instead of `$(cmd)`, `; and` / `; or` or `&&` / `||`, `for x in ...; ...; end` instead of `do`/`done`, and `if ...; ...; end` instead of `then`/`fi`. Use `bash -c '...'` only when a script genuinely needs POSIX/bash semantics.
