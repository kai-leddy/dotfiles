# Global preferences

- Prefer Rust-based equivalents of Unix core utilities when available:
  - Use `rg` instead of `grep` for searching.
  - Use `fd` instead of `find` for locating files.
  - Use `bat` instead of `cat` for viewing text files.
- Check that a preferred tool is installed before using it, and fall back to the standard Unix utility when it is unavailable or when its semantics are a better fit (for example, scripts requiring strict POSIX portability).
- When a request names multiple distinct tasks in one message, add each as an entry in the `todo` tool right away, even if individually small — track them as separate items regardless of size.
- When current web content or external facts are required, use the official Firecrawl MCP through `codemode`; discover its tools with `searchTools()` only when web research is actually needed.
- When completing a task requires checking documentation for a tool, library, or language to get it right, use context7 (`ctx7_library` then `ctx7_docs`) rather than relying on memory.
