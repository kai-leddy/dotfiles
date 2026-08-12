# Global preferences

- Prefer Rust-based equivalents of Unix core utilities when available:
  - Use `rg` instead of `grep` for searching.
  - Use `fd` instead of `find` for locating files.
  - Use `bat` instead of `cat` for viewing text files.
- Check that a preferred tool is installed before using it, and fall back to the standard Unix utility when it is unavailable or when its semantics are a better fit (for example, scripts requiring strict POSIX portability).
