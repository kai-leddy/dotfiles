;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Global variables for configuration
(setq display-line-numbers-type 'relative ; enable relative line numbers
      doom-font (font-spec :family "FantasqueSansMono Nerd Font" :size 17)
      doom-big-font-increment 4 ; big-font mode doesn't need to be THAT big
      scroll-margin 4
      company-minimum-prefix-length 1 ; recommended for lsp-mode
      company-idle-delay 0.0 ; recommended for lsp-mode
      flycheck-javascript-eslint-executable "eslint_d"
      rustic-lsp-server 'rust-analyzer
      prescient-filter-method '(literal fuzzy)
      projectile-track-known-projects-automatically nil)

;; Random useful functions
(defun +kai/toggle-prev-buffer ()
  "Toggle between the current and previous buffer"
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) t)))

;; Basic mappings
(map!
 ;; split lines with K
 :n "K" #'indent-new-comment-line
 ;; swap between latest 2 buffers with backspace
 :n "DEL" #'+kai/toggle-prev-buffer
 ;; move lines up and down with meta+{j,k}
 :n "M-j" #'move-line-down
 :n "M-k" #'move-line-up
 ;; change window with ctrl+{h,j,k,l}
 :n "C-h" #'evil-window-left
 :n "C-j" #'evil-window-down
 :n "C-k" #'evil-window-up
 :n "C-l" #'evil-window-right
 ;; swap ' and ` to allow using ' to goto exact position
 :n "'" #'evil-goto-mark
 :n "`" #'evil-goto-mark-line
 )

;; Additional leader mappings
(map! :leader
      :desc "Run shell command" "!" #'projectile-run-shell-command-in-root
      (:prefix "p"
        ;; Save multiple project buffers
        :desc "Save project files" "s" #'projectile-save-project-buffers
        )
      (:prefix "b"
        ;; save multiple open buffers
        :desc "Save some buffers" "s" #'save-some-buffers
        )
      (:prefix "i"
        ;; insert an emoji
        :desc "Emoji" "e" #'emojify-insert-emoji
        )
      (:prefix "o"
        ;; open an Eshell (no fish features, but better integration)
        :desc "Shell (eshell)" "s" #'eshell
        :desc "Undo Tree" "u" #'undo-tree-visualize))

(use-package! doom-themes
  :init
  (setq doom-theme 'doom-molokai))

(use-package! react-snippets :after yasnippet)
(use-package! jest-snippets :after yasnippet)

;; Make rjsx-mode work for .tsx files
(use-package! rjsx-mode
  :init
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . rjsx-mode)))

(use-package! vmd-mode
  :commands vmd-mode
  :init
  (map! :map markdown-mode-map
        (:localleader
          "v" #'vmd-mode)))

;; Setup org mode stuff
(after! org
  (setq org-directory "~/org")
  (setq org-agenda-files (list org-directory))
  (setq org-capture-templates
        '(("t" "Todo" entry
           (file+headline +org-capture-todo-file "Inbox")
           "* TODO %?\n%i\n%a" :prepend t :kill-buffer t)
          ("n" "Notes" entry
           (file+headline +org-capture-notes-file "Inbox")
           "* %u %?\n%i\n%a" :prepend t :kill-buffer t)))
  (setq org-agenda-prefix-format
        '((agenda . " %i %-12:c%?-12t% s")
          (todo . " %i %10:c%l")
          (tags . " %i %-12:c")
          (search . " %i %-12:c")))
  (map! :map org-mode-map
        :localleader
        "x" #'org-archive-subtree
        "X" #'org-archive-all-done)
  )

(after! ox-latex
  ;(add-to-list 'org-latex-packages-alist '("" "minted"))
  (setq org-latex-tables-booktabs t)
  (setq org-latex-listings 'minted)
  (setq org-latex-pdf-process
        '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f")))

;; make projectile not save node_module caches as projects
(after! projectile
  (setq projectile-globally-ignored-directories
        (append '(".cache") projectile-globally-ignored-directories)))

;; enable eslint auto formatting for all JS & TS buffers
(add-hook!
 '(typescript-mode-hook js2-mode-hook rjsx-mode-hook)
 #'eslintd-fix-mode)

;; try to get magit-todos to work with magit-gitflow (UNTESTED)
(add-hook! 'magit-gitflow-mode-hook #'magit-todos-mode)

;; enable emojis everywhere :tada:
(add-hook! 'after-init-hook #'global-emojify-mode)

;; Disable auto formatting of yaml for helm charts
(add-hook! 'yaml-mode-hook
  (when (locate-dominating-file default-directory "Chart.yaml")
      (setq +format-with :none)))

;; Disable auto formatting when using markdown vmd-mode
(add-hook! 'vmd-mode-hook
  (setq +format-with (if vmd-mode :none nil)))

;; overwrite prettier formatter to not send 'parser' cli option
(set-formatter! 'prettier
  '("prettier"
    ("--stdin-filepath" "%s" buffer-file-name)))

(after! (flycheck rjsx-mode typescript-mode js2-mode)
  (set-next-checker! 'rjsx-mode 'lsp 'javascript-eslint 'append)
  (set-next-checker! 'js2-mode 'lsp 'javascript-eslint 'append)
  (set-next-checker! 'typescript-mode 'lsp 'javascript-eslint 'append))
