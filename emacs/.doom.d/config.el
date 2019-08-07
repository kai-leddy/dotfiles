;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

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
 )

;; Additional leader mappings
(map! :leader
      (:prefix "p"
        ;; Save multiple project buffers
        :desc "Save project files" "s" #'projectile-save-project-buffers
        )
      (:prefix "b"
        ;; save multiple open buffers
        :desc "Save some buffers" "s" #'save-some-buffers
        )
      (:prefix "o"
        ;; open an Eshell (no fish features, but better integration)
        :desc "Shell (eshell)" "s" #'eshell))

(def-package! doom-themes
  :init
  (setq doom-theme 'doom-molokai))

(def-package! react-snippets
  :defer t)

;; Setup org mode stuff
(after! org
  (setq org-directory "~/Dropbox/org")
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

;; make projectile not save node_module caches as projects
(after! projectile
  (setq projectile-globally-ignored-directories
        (append '(".cache") projectile-globally-ignored-directories)))