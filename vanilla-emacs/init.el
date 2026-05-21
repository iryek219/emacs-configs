;;; init.el --- My Emacs configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Personal Emacs configuration.

;;; Code:


(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))


(setq package-quickstart-file
      (expand-file-name "package-quickstart.el" user-emacs-directory))


;; vertico
(straight-use-package 'vertico)
(add-hook 'after-init-hook #'vertico-mode)

;; orderless
(straight-use-package 'orderless)
(setq completion-styles '(orderless basic)
      completion-category-defaults nil
      completion-category-overrides '((file (styles partial-completion))))

;; marginalia
(straight-use-package 'marginalia)

;; corfu - in-buffer completion pop-up
(straight-use-package 'corfu)

;; project
(straight-use-package 'project)

;; --- LSP via built-in Eglot ---
(use-package eglot
  :straight nil     ; built into Emacs 29+; don't fetch from a recipe
  :hook ((rust-ts-mode
          python-ts-mode
          html-ts-mode
          css-ts-mode) . eglot-ensure)
  :config
  ;; HTMx lives inside HTML; the HTML language server handles it fine.
  (add-to-list 'eglot-server-programs
               '(rust-ts-mode . ("rust-analyzer"))))

;; --- Tree-sitter language grammars ---
(setq treesit-language-source-alist
      '((rust   "https://github.com/tree-sitter/tree-sitter-rust")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (html   "https://github.com/tree-sitter/tree-sitter-html")
        (css    "https://github.com/tree-sitter/tree-sitter-css")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript")))
;; Run M-x treesit-install-language-grammar once per language,
;; or evaluate: (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist))

;; Route classic modes to their tree-sitter versions
(setq major-mode-remap-alist
      '((rust-mode   . rust-ts-mode)
        (python-mode . python-ts-mode)
        (css-mode    . css-ts-mode)
        (mhtml-mode  . html-ts-mode)
        (html-mode   . html-ts-mode)))

(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))
(setq treesit-font-lock-level 3)  ; max detail=4; default is 3

;; --- Project tree sidebar ---
(use-package treemacs :bind ("<f8>" . treemacs))

;; magit
(straight-use-package 'magit)

;; projectile
(straight-use-package 'projectile)
(autoload 'projectile-mode "projectile" nil t)
(autoload 'projectile-command-map "projectile" nil t)
(add-hook 'after-init-hook #'projectile-mode)

(global-set-key (kbd "C-c p") 'projectile-command-map)

(with-eval-after-load 'projectile
   (setq projectile-completion-system 'default))


;; which-key
(straight-use-package 'which-key)
(autoload 'which-key-mode "which-key" nil t)
(add-hook 'after-init-hook #'which-key-mode)

(with-eval-after-load 'which-key
  (setq which-key-idle-delay 0.5))

;; fly-check
(straight-use-package 'flycheck)
(autoload 'flycheck-mode "flycheck" nil t)
(defun my-enable-flycheck ()
  (flycheck-mode 1))

(add-hook 'prog-mode-hook #'my-enable-flycheck)
(add-hook 'text-mode-hook #'my-enable-flycheck)

(with-eval-after-load 'flycheck
  (setq flycheck-check-syntax-automatically
	'(save mode-enabled)))

;; company
(straight-use-package 'company)
(autoload 'company-mode "company" nil t)
(defun my-enable-company ()
  (company-mode 1))

(add-hook 'prog-mode-hook #'my-enable-company)
(add-hook 'text-mode-hook #'my-enable-company)

(with-eval-after-load 'company
  (setq company-idle-delay 0.2)
  (setq company-minimum-prefix-length 2))

(straight-use-package 'geiser)
(setq geiser-default-implementation '((scheme . guile)))
(add-hook 'scheme-mode-hook 'geiser-mode)
;; [중요] Geiser가 load된 후 키 바인등 적용(에러방지)
(with-eval-after-load 'geiser-mode
  (define-key geiser-mode-map (kbd "C-c C-r") 'geiser-restart))

(straight-use-package 'geiser-guile)

(straight-use-package 'paredit)
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)
(add-hook 'lisp-mode-hook 'paredit-mode)
(add-hook 'scheme-mode-hook 'paredit-mode)
(add-hook 'clojure-mode-hook 'paredit-mode)

;; Apply a theme so that rainbow-delimiters is more effective
(straight-use-package 'modus-themes)
(load-theme 'modus-vivendi t)  ;; dark

;; rainbow-delimters
(straight-use-package 'rainbow-delimiters)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(custom-set-faces
 '(rainbow-delimiters-depth-1-face ((t (:foreground "#ff6c6b"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "#98be65"))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "#da8548"))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "#51afef"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "#c678dd")))))

;;; --- Sensible defaults ---
(setq inhibit-startup-screen t)              ;; skip splash screen
(setq ring-bell-function 'ignore)            ;; no beeps
(setq make-backup-files nil)                 ;; no foo~ files
(setq auto-save-default nil)                 ;; no #foo# files
(setq create-lockfiles nil)                  ;; no .#foo files
(setq-default indent-tabs-mode nil)          ;; spaces, not tabs
(setq-default tab-width 4)
(setq scroll-conservatively 101)             ;; smoother scrolling
(setq scroll-margin 3)
(global-auto-revert-mode 1)                  ;; reload changed files
(setq global-auto-revert-non-file-buffers t) ;; also reload dired etc.
(savehist-mode 1)                            ;; remember minibuffer history
(save-place-mode 1)                          ;; remember cursor position
(recentf-mode 1)                             ;; track recent files
(delete-selection-mode 1)                    ;; typing replaces selection
(electric-pair-mode 1)                       ;; auto-pair brackets/quotes
(show-paren-mode 1)                          ;; highlight matching parens
(column-number-mode 1)                       ;; show column in mode line
(setq use-short-answers t)                   ;; y/n instead of yes/no

;; UI cleanup
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;; init.el ends here
