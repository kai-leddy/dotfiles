;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:host github :repo "username/repo"))
;; (package! builtin-package :disable t)

(package! evil-snipe :disable t)
(package! magit-gitflow :disable t)
;; (package! evil-easymotion :disable t)

(package! vmd-mode)
(package! emojify)
(package! react-snippets)
(package! jest-snippets :recipe
  (:host github
   :repo "sei40kr/jest-snippets"
   :files ("*.el" "snippets")))
(package! nvm)

;; Testing out TabNine code completion engine
(package! company-tabnine)
