// vim:foldmethod=marker:foldlevel=0

// Future versions of Hyper may add additional config options,
// which will not automatically be merged into this file.
// See https://hyper.is#cfg for all currently supported options.

module.exports = {
    // key mappings {{{
    keymaps: {
        // Example
        // 'window:devtools': 'cmd+alt+o',
    },
    // }}}
    // Plugins {{{{{{}}}
    // a list of plugins to fetch and install from npm
    // format: [@org/]project[#version]
    // examples:
    //   `hyperpower`
    //   `@company/project`
    //   `project#1.0.1`
    plugins: [
        //"hyperterm-install-devtools",
        "hyperfull",
        "hyperminimal",
        "hyper-final-say" // TODO: make sure this is LAST in this list
    ],

    // in development, you can create a directory under
    // `~/.hyper_plugins/local/` and include it here
    // to load it and avoid it being `npm install`ed
    localPlugins: ["hyper-monokai-deluxe"],
    // }}}
    // Config settings {{{
    config: {
        // Default settings {{{
        // for advanced config flags please refer to https://hyper.is/#cfg
        // Must be one of ['stable', 'canary']
        updateChannel: 'canary',
        cursorShape: 'BLOCK',
        fontSize: 12,
        fontFamily: 'Knack Nerd Font, Menlo, "DejaVu Sans Mono", monospace',
        padding: '18px 0 14px 18px',

        // custom CSS to embed in the main window
        css: '',
        // custom CSS to embed in the terminal window
        termCSS: '',
        // for environment variables
        env: {},
        // set to `false` for no bell
        bell: 'SOUND',
        // if `true`, selected text will automatically be copied to the clipboard
        copyOnSelect: false,
        // if `true`, hyper will be set as the default protocol client for SSH
        defaultSSHApp: true,
        // }}}
        // plugin specific settings {{{
        // settings for the monokai deluxe theme
        monokaiDeluxe: {
            borderWidth: '5px'
        }
        // install react and redux dev tools
        /*
        installDevTools: {
            extensions: [
                'REACT_DEVELOPER_TOOLS',
                'REDUX_DEVTOOLS'
            ],
            forceDownload: false
        },
        */
        // }}}
    },
    // }}}
};
