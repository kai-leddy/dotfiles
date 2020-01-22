;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:fetcher github :repo "username/repo"))
;; (package! builtin-package :disable t)

(package! evil-snipe :disable t)
(package! evil-easymotion :disable t)

(package! exec-path-from-shell)
(package! vmd-mode)
(package! react-snippets)
(package! jest-snippets :recipe
  (:host github
   :repo "sei40kr/jest-snippets"
   :files ("*.el" "snippets")))
