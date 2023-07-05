;;; init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

;; NOTE Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;      documentation. There you'll find information about all of Doom's
;;      modules and what flags they support.

;; NOTE Move your cursor over a module's name (or its flags) and press 'SPC c k'
;;      (or 'C-c g k' for non-vim users) to view its documentation. This works on
;;      flags as well (those symbols that start with a plus).
;;
;;      Alternatively, press 'gd' (or 'C-c g d') on a module to browse its
;;      directory (for easy access to its source code).

(doom! :completion
       ;; (company)  ; code completion engine
       ;; (ivy +icons +prescient +childframe) ; search engine
       (corfu +icons) ; corfu completion engine
       (vertico +icons) ; search engine

       :ui
       doom                   ; what makes DOOM look the way it does
       doom-dashboard         ; a nifty splash screen for Emacs
       hl-todo                ; highlight TODO/FIXME/NOTE tags
       hydra                  ; transient mode keybindings etc
       indent-guides          ; highlighted indent columns
       modeline               ; snazzy, Atom-inspired modeline, plus API
       nav-flash              ; blink the current line after jumping
       ophints                ; highlight the region an operation acts on
       (popup +all +defaults)            ; some default popup handling stuff
       treemacs               ; a project drawer, like neotree but cooler
       (vc-gutter +pretty)              ; vcs diff in the fringe
       vi-tilde-fringe        ; fringe tildes to mark beyond EOB
       workspaces             ; tab emulation, persistence & separate workspaces

       :editor
       (evil +everywhere)     ; come to the dark side, we have cookies
       file-templates         ; auto-snippets for empty files
       fold                   ; (nigh) universal code folding
       (format +onsave)       ; automated prettiness
       multiple-cursors       ; editing in many places at once
       rotate-text            ; cycle region at point between text candidates
       snippets               ; my elves . They type so I don't have to

       :emacs
       (dired +icons) ;  making dired pretty [functional]
       electric               ; smarter, keyword-based electric-indent
       (undo +tree)                   ; persistent, smarter undo for your inevitable mistakes
       vc                     ; version-control and Emacs, sitting in a tree

       :term
       eshell            ; the elisp shell that works everywhere
       vterm             ; the best terminal emulation in Emacs

       :checkers
       (syntax +childframe)                 ; tasing you for every semicolon you forget

       :tools
       ansible
       direnv
       docker
       ;;editorconfig         ; let someone else argue about tabs vs spaces
       (eval +overlay)                   ; run code, run (also, repls)
       ;;gist                 ; interacting with github gists
       lookup                 ; helps you navigate your code and documentation
       (lsp +eglot)
       magit                  ; a git porcelain for Emacs
       rgb                    ; creating color strings
       terraform            ; infrastructure as code
       tree-sitter            ; better, faster parsing & syntax highlighting

       :lang
       ;; (cc +lsp +tree-sitter)                     ; C/C++/Obj-C madness
       data                   ; config/data formats
       emacs-lisp             ; drown in parentheses
       (go +lsp)              ; The hipster dialect
       ;; (java +lsp +tree-sitter)    ; the poster child for carpal tunnel syndrome
       (javascript +lsp +tree-sitter)             ; all(hope(abandon(ye(who(enter(here))))))
       (json +lsp +tree-sitter)              ; At least it ain't XML
       (latex +lsp +latexmk)                  ; writing papers in Emacs has never been so fun
       (lua +lsp)             ; One-based indices? one-based indices
       markdown               ; writing docs for people to ignore
       ;;nix                  ; I hereby declare "nix geht mehr!"
       ;;org                   ; organize your plain life in plain text
       ;; (php +lsp +tree-sitter)                  ; perl's insecure younger brother
       (python +lsp +tree-sitter)                 ; beautiful is better than ugly
       (ruby +lsp +rbenv +tree-sitter)                 ; 1.step {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"}
       (rust +lsp)                   ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
       (sh +fish)             ; she sells {ba,z,fi}sh shells on the C xor
       ;; (swift +lsp +tree-sitter)                ; who asked for emoji variables?
       (web +lsp +tree-sitter)                    ; the tubes
       (yaml +lsp)           ; JSON, but readable

       :os
       macos                ; MacOS-specific commands
       (tty +osc)           ; Make TTY Emacs suck less

       :config
       (default +bindings +smartparens))
