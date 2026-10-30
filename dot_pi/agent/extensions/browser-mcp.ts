import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Extension registrations reset on reload and new sessions. Enable a browser
// through /mcp only when needed; Pi won't write that choice to mcp.json.
export default function (pi: ExtensionAPI) {
  pi.registerMcpServer("firefox-devtools", {
    command: "npx",
    args: ["-y", "@mozilla/firefox-devtools-mcp@latest", "--tool-preset", "developer"],
    enabled: false,
    exposure: "codemode",
    description: "Control a separate Firefox session and inspect web pages with Firefox DevTools.",
  });

  pi.registerMcpServer("zen-devtools", {
    command: "npx",
    args: [
      "-y",
      "@mozilla/firefox-devtools-mcp@latest",
      "--firefox-path",
      "/Applications/Zen.app/Contents/MacOS/zen",
      "--auto-profile",
      "--tool-preset",
      "developer",
    ],
    enabled: false,
    exposure: "codemode",
    description: "Open a visible Zen session with a persistent dedicated profile for shared browsing and debugging.",
  });
}
