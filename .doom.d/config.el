;;; ~/.doom.d/config.el -*- lexical-binding: t; eval: (flycheck-mode -1); -*-

;; Global variables for configuration
(setq display-line-numbers-type 'relative ; enable relative line numbers
      doom-font (font-spec :family "FantasqueSansM Nerd Font" :size 16)
      doom-unicode-font (font-spec :family "FantasqueSansM Nerd Font" :size 16)
      doom-big-font-increment 2 ; big-font mode doesn't need to be THAT big
      ns-use-thin-smoothing t ; better anti-aliasing on MacOS
      scroll-margin 4
      ;company-idle-delay 0.01
      flycheck-idle-change-delay 3
      flycheck-check-syntax-automatically '(save mode-enabled)
      ;company-backends '(:separate company-yasnippet company-capf)
      rustic-lsp-server 'rust-analyzersetq
      eglot-events-buffer-size 0 ; disable eglot events buffer (turn this off to debug language servers)
      ;; prescient-filter-method '(literal fuzzy regex)
      projectile-track-known-projects-automatically nil
      ;; use primary instead of clipboard by default
      select-enable-clipboard nil
      select-enable-primary t
      ;; only live-update markdown previews on save
      grip-update-after-change nil
      ;; enable gravatars in git commits
      magit-revision-show-gravatars '("^Author:     " . "^Commit:     "))

;; Try to improve the garbage collection situation
(after! gcmh
  (setq gcmh-high-cons-threshold 67108864)) ; 64mb

(setq-hook! 'eglot-managed-mode-hook
  ;; show hovered point docs before function signature docs
  eldoc-documentation-functions '(eglot-hover-eldoc-function eglot-signature-eldoc-function))

;; custom mode definitions for filenames
(appendq! auto-mode-alist
          '(("Tiltfile" . python-mode)))

;; Basic mappings
(map!
 ;; split lines with K
 :n "K" #'indent-new-comment-line
 ;; swap between latest 2 *project* buffers with backspace
 :n "DEL" #'projectile-project-buffers-other-buffer
 ;; move lines up and down with meta+{j,k}
 :n "M-j" #'move-line-down
 :n "M-k" #'move-line-up
 ;; swap ' and ` to allow using ' to goto exact position
 :n "'" #'evil-goto-mark
 :n "`" #'evil-goto-mark-line
 ;; use 'SPC r' to rotate values (true/false etc)
 :n "SPC r" #'rotate-text)

;; Additional leader mappings
(map! :leader
      :desc "Run shell command" "!" #'projectile-run-shell-command-in-root
      (:prefix "p"
       ;; Save multiple project buffers
       :desc "Save project files" "s" #'projectile-save-project-buffers)
      (:prefix "b"
       ;; save multiple open buffers
       :desc "Save some buffers" "s" #'save-some-buffers)
      (:prefix "i"
       ;; insert an emoji
       :desc "Emoji" "e" #'emojify-insert-emoji)
      (:prefix "o"
       ;; open an Eshell (no fish features, but better integration)
       :desc "Shell (eshell)" "s" #'eshell
       :desc "Undo Tree" "u" #'undo-tree-visualize))

(use-package! doom-themes
  :init
  (setq doom-theme 'doom-monokai-spectrum))

(use-package! react-snippets :after yasnippet)
(use-package! jest-snippets :after yasnippet)

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

;; fix regex matching when using counsel-rg for project search
(after! ivy-prescient
  (setf (alist-get 'counsel-rg ivy-re-builders-alist) #'ivy--regex-plus))

;; disable LSP formatting for all JS & TS buffers (let prettier do it)
(setq-hook!
    '(typescript-mode-hook js2-mode-hook rjsx-mode-hook typescript-tsx-mode-hook json-mode-hook)
  +format-with-lsp nil)

;; try to get magit-todos to work with magit-gitflow (UNTESTED)
(add-hook! 'magit-mode-hook #'magit-todos-mode)

;; enable emojis everywhere :tada:
(add-hook! 'after-init-hook #'global-emojify-mode)

;; TODO: I might not need this anymore with Eglot
;; Disable auto formatting (& LSP) of yaml for helm charts
(add-hook! 'yaml-mode-hook
  (let ((is-helm-yaml (locate-dominating-file default-directory "Chart.yaml")))
    (when is-helm-yaml
      (add-hook! 'lsp-mode-hook :local
        (setq
         +format-with :none
         lsp-managed-mode nil
         )
        (lsp-managed-mode -1)
        ))))

;; fix format-all not respecting the .envrc environment
(after! format-all (advice-add 'format-all-buffer :around #'envrc-propagate-environment))

;; Make eglot use tsserver for as much as possible
(after! eglot
  :config
  (prependq! eglot-server-programs '(((typescript-tsx-mode typescript-mode js-mode rjsx-mode) . ("typescript-language-server" "--stdio")))))

;;; Setup for Github Copilot
;; accept completion from copilot and fallback to company
(defun +kai/autocomplete ()
  (interactive)
  (or (copilot-accept-completion)
      (corfu-complete)
      (if (fboundp '+web/indent-or-yas-or-emmet-expand)
          (+web/indent-or-yas-or-emmet-expand))
      ))
      ;; (company-indent-or-complete-common nil)))

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (("C-TAB" . 'copilot-accept-completion-by-word)
         ("C-<tab>" . 'copilot-accept-completion-by-word)
         :map evil-insert-state-map
         ("<tab>" . '+kai/autocomplete)
         ("TAB" . '+kai/autocomplete)
         ;; :map company-active-map
         ;; ("<tab>" . '+kai/autocomplete)
         ;; ("TAB" . '+kai/autocomplete)
         :map corfu-map
         ("<tab>" . '+kai/autocomplete)
         ("TAB" . '+kai/autocomplete)))

(provide 'config)
;;; config.el ends here
