;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:host github :repo "username/repo"))
;; (package! builtin-package :disable t)

(package! evil-snipe :disable t)
;; (package! evil-easymotion :disable t)

;; Unpin all LSP packages so we run the latest
(unpin! (:tools lsp))

(package! nvm)
(package! emojify)
(package! react-snippets)
(package! jest-snippets :recipe
  (:host github
   :repo "sei40kr/jest-snippets"
   :files ("*.el" "snippets")))
(package! copilot :recipe
  (:host github
   :repo "zerolfx/copilot.el"
   :files ("*.el" "dist")))
