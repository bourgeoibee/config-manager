(setq package-enable-at-startup nil
      inhibit-startup-screen t
      read-file-name-completion-ignore-case t
      c-default-style "linux"
      custom-safe-themes t)
(setq-default display-line-numbers 'relative)

(menu-bar-mode 1)
(tool-bar-mode 0)
(toggle-frame-maximized)
(set-frame-font "JetBrains Mono-14")
(load-theme 'gruber-darker t)
(show-paren-mode t)

(package-initialize)
(require 'package)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))

;;(add-to-list 'load-path "~/.config/emacs/packages/")

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
;;(use-package evil)
(use-package rust-mode)
(use-package lsp-mode)
(use-package magit)
(use-package tree-sitter)
(use-package gruber-darker-theme)
;;(use-package smex)
(use-package cmake-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(gruber-darker-theme cmake-mode use-package tree-sitter rust-mode magit lsp-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
