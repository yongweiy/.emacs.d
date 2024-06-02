;; -*- lexical-binding: t; -*-
;;; Code:
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(setq straight-use-package-by-default t)
(straight-use-package 'use-package)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(codeium/metadata/api_key "28b2b0c1-a5c5-4960-8ec9-efa4414d3aca")
 '(custom-safe-themes
   '("7e068da4ba88162324d9773ec066d93c447c76e9f4ae711ddd0c5d3863489c52" "1a1ac598737d0fcdc4dfab3af3d6f46ab2d5048b8e72bc22f50271fd6d393a00" default))
 '(dafny-prover-foreground-args
   '("/useBaseNameForFileName" "/timeLimit:30" "/vcsCores:1" "/showSnippets:1" "/vcsSplitOnEveryAssert"))
 '(package-selected-packages
   '(exec-path-from-shell doom-modeline ocamlformat tuareg merlin-company dune org-fragtog treemacs-tab-bar minibuffer-header lsp-java company-coq proof-general wordnut synosaurus academic-phrases pdf-tools ivy-bibtex org-roam-bibtex org-ref auctex-latexmk auctex vulpea org-inline-pdf dap-mode yaml which-key vlf use-package undo-tree treemacs-projectile treemacs-persp treemacs-magit treemacs-icons-dired treemacs-evil mini-frame lsp-ui lsp-ivy general flycheck evil-surround doom-themes counsel company all-the-icons))
 '(safe-local-variable-values
   '((eval progn
           (setq-local lsp-mode nil)
           (setq-local lsp-managed-mode nil)
           (setq-local lsp--buffer-workspaces nil)
           (setq-local lsp--buffer-mappings nil)
           (lsp--info "LSP Mode disabled in this directory"))
     (elisp-lint-indent-specs
      (describe . 1)
      (it . 1)
      (thread-first . 0)
      (cl-flet . 1)
      (cl-flet* . 1)
      (org-element-map . defun)
      (org-roam-dolist-with-progress . 2)
      (org-roam-with-temp-buffer . 1)
      (org-with-point-at . 1)
      (magit-insert-section . defun)
      (magit-section-case . 0)
      (org-roam-with-file . 2))
     (elisp-lint-ignored-validators "byte-compile" "package-lint")
     (TeX-command-extra-options . "-shell-escape")
     (eval lsp)
     (eval tuareg-opam-update-env
           (projectile-project-root)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(use-package emacs
  :init
  (setq native-comp-async-report-warnings-errors nil)
  (setq-default indent-tabs-mode nil)
  (setq tab-always-indent 'complete)
  (setq frame-resize-pixelwise t)
  (add-hook 'prog-mode-hook (lambda() (display-line-numbers-mode 1)))
  (add-hook 'text-mode-hook (lambda() (display-line-numbers-mode 1)))
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (electric-pair-mode 1)
  (show-paren-mode 1)
  (recentf-mode 1)
  (savehist-mode 1)
  (scroll-bar-mode -1)
  (setq backup-directory-alist
        `(("." . ,(concat user-emacs-directory "backups"))))
  (setq delete-old-versions t
        kept-new-versions 6
        kept-old-versions 2
        version-control t)
  (set-face-attribute 'show-paren-match-expression nil :background "blue")
  (setq show-paren-style 'parenthesis)
  (setq show-paren-when-point-inside-paren t)
  (setq show-paren-when-point-in-periphery t)
  (defalias 'yes-or-no-p 'y-or-n-p)
  (set-face-attribute 'default nil :height 120)
  (add-to-list 'load-path "~/.emacs.d/borrowed")
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  (setq read-extended-command-predicate
        #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t)
  ;; (add-to-list 'default-frame-alist '(fullscreen . maximized))
  (add-to-list 'default-frame-alist '(undecorated . t))
  (defun slick-cut (beg end)
    (interactive
     (if mark-active
         (list (region-beginning) (region-end))
       (list (line-beginning-position) (line-beginning-position 2)))))

  (advice-add 'kill-region :before #'slick-cut)

  (defun slick-copy (beg end)
    (interactive
     (if mark-active
         (list (region-beginning) (region-end))
       (message "Copied line")
       (list (line-beginning-position) (line-beginning-position 2)))))

  (advice-add 'kill-ring-save :before #'slick-copy))
(use-package org
  :straight nil
  :custom
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil))
(use-package pixel-scroll
  :straight nil
  :init
  (defun pixel-scroll-half-page-down ()
    "Smoothly scroll down half the current window height."
    (interactive)
    (pixel-scroll-precision-interpolate (- (/ (window-text-height nil t) 2))
                                        nil 1))
    (defun pixel-scroll-half-page-up ()
    "Smoothly scroll down half the current window height."
    (interactive)
    (pixel-scroll-precision-interpolate (/ (window-text-height nil t) 2)
                                          nil 1))
  :bind
  ([remap scroll-up-command]   . pixel-scroll-half-page-down)
  ([remap scroll-down-command] . pixel-scroll-half-page-up)
  :custom
  (pixel-scroll-precision-interpolate-page t)
  :init
  (pixel-scroll-precision-mode 1))
(use-package exec-path-from-shell
  :if (daemonp)
  :config
  (exec-path-from-shell-initialize))
(use-package all-the-icons
  :if (display-graphic-p))
(use-package highlight-indent-guides
  :custom
  (highlight-indent-guides-responsive 'stack)
  (highlight-indent-guides-method 'bitmap)
  :config
  (set-face-background 'highlight-indent-guides-odd-face "darkgray")
  (set-face-background 'highlight-indent-guides-even-face "dimgray")
  (set-face-foreground 'highlight-indent-guides-character-face "dimgray")
  ;; (add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
  )
(use-package general
  :config
  (general-define-key
   ;; "C-'" 'term
   ;; "C-s" 'swiper             ; search for string in current buffer
   ;; "M-x" 'counsel-M-x        ; replace default M-x with ivy backend
   :prefix "C-c"
   ;; bind to simple key press
   "a"  '(org-agenda :which-key "org agenda")
   ;; "b"  'ivy-switch-buffer  ; change buffer, chose using ivy
   ;; "/"  'counsel-git-grep   ; find string in git project
   ;; ;; bind to double key press
   ;; "f"  '(:ignore t :which-key "files")
   ;; "ff" 'counsel-find-file  ; find file using ivy
   ;; "fr" 'counsel-recentf    ; find recently edited files
   ;; "p"  '(:ignore t :which-key "projects")
   ;; "pf" 'counsel-git        ; find file in git project
   )
  )
;; (use-package tree-sitter
;;   :config
;;   ;; activate tree-sitter on any buffer containing code for which it has a parser available
;;   (global-tree-sitter-mode)
;;   ;; you can easily see the difference tree-sitter-hl-mode makes for python, ts or tsx
;;   ;; by switching on and off
;;   (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
;; (use-package tree-sitter-langs
;;   :after tree-sitter)
;; (use-package kdl-ts-mode
  ;; :straight (:host github :repo "dataphract/kdl-ts-mode" :files ("*.el")))
(use-package which-key
  :custom
  (which-key-allow-evil-operators nil)
  (which-key-show-operator-state-maps nil)
  :hook (after-init . which-key-mode))
;; almost native packagess
(use-package magit
  :custom
  (magit-save-repository-buffers 'dontask)
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))
(use-package magit-todos
  :after magit
  :config (magit-todos-mode 1))
(use-package prescient
  :config
  (prescient-persist-mode))
;; company 
;; (use-package company
;;   :config
;;   (global-company-mode)
;;   (setq lsp-completion-provider :capf))
;; (use-package company-box
;;   :hook (company-mode . company-box-mode))
;; (use-package company-prescient
;;   :after company prescient
;;   :config
;;   (company-prescient-mode))
(use-package ace-window
  :config
  (global-set-key (kbd "M-o") 'ace-window))
(use-package corfu
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode))
(use-package nerd-icons-corfu
  :requires corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))
(use-package smartparens
  :hook ((prog-mode text-mode markdown-mode) . smartparens-strict-mode)
  :config
  ;; load default config
  (require 'smartparens-config)
  (sp-use-smartparens-bindings))

;; load large file
(use-package vlf )
(use-package hs
  :hook
  (prog-mode . hs-minor-mode))
(use-package undo-tree
  :diminish
  :init
  ;; Prevent undo tree files from polluting your git repo
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
  :config
  (turn-on-undo-tree-mode)
  (global-undo-tree-mode 1))

(when nil
  (use-package evil
    :after undo-tree
    :config
    (evil-mode 1)
    (evil-set-undo-system 'undo-tree)
    (define-key evil-normal-state-map (kbd "M-.") nil)
    (define-key evil-normal-state-map (kbd "C-.") nil)
    ;; (define-key evil-motion-state-map (kbd "TAB") nil)
    (define-key evil-motion-state-map (kbd "SPC") nil)
    (define-key evil-motion-state-map (kbd "RET") nil))
  (use-package evil-surround
    :config
    ;; this macro was copied from here: https://stackoverflow.com/a/22418983/4921402
    (defmacro define-and-bind-quoted-text-object (name key start-regex end-regex)
      (let ((inner-name (make-symbol (concat "evil-inner-" name)))
            (outer-name (make-symbol (concat "evil-a-" name))))
        `(progn
           (evil-define-text-object ,inner-name (count &optional beg end type)
             (evil-select-paren ,start-regex ,end-regex beg end type count nil))
           (evil-define-text-object ,outer-name (count &optional beg end type)
             (evil-select-paren ,start-regex ,end-regex beg end type count t))
           (define-key evil-inner-text-objects-map ,key #',inner-name)
           (define-key evil-outer-text-objects-map ,key #',outer-name))))

    (define-and-bind-quoted-text-object "pipe" "|" "|" "|")
    (define-and-bind-quoted-text-object "slash" "/" "/" "/")
    (define-and-bind-quoted-text-object "asterisk" "*" "*" "*")
    (define-and-bind-quoted-text-object "dollar" "$" "\\$" "\\$") ;; sometimes your have to escape the regex
    (global-evil-surround-mode 1))
  (use-package evil-org
    :after org
    :hook (org-mode . evil-org-mode)
    :config
    (require 'evil-org-agenda)
    (evil-org-agenda-set-keys))
  )

;; only here because I need ivy-bibtex
(use-package ivy
  :init
  (setq ivy-use-virtual-buffers t
     ivy-use-selectable-prompt t
     ivy-count-format "(%d/%d) ")
  :config
  (ivy-mode 0))
;; (use-package swiper)
;; (use-package counsel)
(use-package avy
  :config
  (global-set-key (kbd "M-g w") 'avy-goto-word-1)
  (global-set-key (kbd "M-g g") 'avy-goto-line))
;; (use-package catppuccin-theme
;;   :custom
;;   (catppuccin-flavor 'frappe)
;;   ;; workaround for https://github.com/catppuccin/emacs/issues/121
;;   :hook (server-after-make-frame . catppuccin-reload))
(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one-light t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))
(use-package doom-modeline
  :config (doom-modeline-mode 1))

(use-package activity-watch-mode
  :custom
  (activity-watch-mode-line-format "👀 %s")
  :config
  (global-activity-watch-mode))

;; minibuffer front-end
(use-package vertico

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  :config
  (vertico-mode)
  (setq vertico-cycle t)
  (setq vertico-sort-function #'vertico-sort-history-alpha)
  )
;; minibuffer completion provider
(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ("C-c f f" . find-file)
         ("C-c f r" . consult-recent-file)
         ("C-c b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-c m" . consult-mode-command)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ("<help> a" . consult-apropos)            ;; orig. apropos-command
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flycheck)               ;; Alternative: consult-flycheck
         ;; ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ;; ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic previe
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key (kbd "M-."))
  ;; (setq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme
   :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-recent-file
   consult--source-project-recent-file
   :preview-key "M-.")

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; (kbd "C-+")

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;; There are multiple reasonable alternatives to chose from.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 3. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 4. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  )
(use-package consult-lsp :after consult lsp)
(use-package wgrep)
;; minibuffer completion backend
(use-package orderless
  :after vertico
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))
;; minibuffer annotations
(use-package marginalia
  :config
  (marginalia-mode))
;; minibuffer actions
(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("M-." . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))
;; bring in consult-specific embark actions
(use-package embark-consult
  :after (embark consult)
  :demand t ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; (use-package tramp
;;   :straight (:type built-in)
;;   :config
;;   (eval-after-load 'tramp '(setenv "SHELL" "/bin/bash"))
;;   (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
;;   (put #'tramp-dissect-file-name 'tramp-suppress-trace t)
;;   (defun tramp-ensure-dissected-file-name (vec-or-filename)))
(use-package projectile
  :init
  ;; (defcustom projectile-project-root-functions `()
    ;; '(projectile-root-local
    ;;   projectile-root-top-down
    ;;   projectile-root-bottom-up
    ;;   projectile-root-top-down-recurring)
    ;; "A list of functions for finding project roots."
    ;; :group 'projectile
    ;; :type '(repeat function))
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map)))

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
  :after (treemacs)
  :ensure t
  :config (treemacs-set-scope-type 'Tabs))

(use-package yasnippet-snippets)
(use-package yasnippet
  :after yasnippet-snippets
  :config (yas-global-mode)
  :custom
  (yas-snippet-dirs '("~/.emacs.d/straight/repos/yasnippet-snippets/snippets")))

(use-package eglot
  ;; :hook ((python-mode tuareg-mode TeX-mode rust-mode scala-mode). eglot-ensure)
  :custom
  (eglot-events-buffer-size 0)
  :config
  (add-to-list 'eglot-server-programs
               '((latex-mode tex-mode context-mode texinfo-mode bibtex-mode) . ("texlab"))))
(use-package consult-eglot
  :after (consult eglot))
(use-package flycheck
  :init (global-flycheck-mode))

;; python
;; (use-package pet
;;   :hook (python-mode . pet-mode))
(use-package python)
(use-package python-black)
(use-package lsp-pyright)
(use-package poetry)
(use-package anaconda-mode)

(use-package direnv
  :config
  (direnv-mode))
(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "M-l")
  :custom
  (lsp-idle-delay 0.200)
  (gc-cons-threshold 100000000)
  (read-process-output-max (* 1024 1024)) ;; 1mb
  (lsp-enable-indentation nil)
  (lsp-keep-workspace-alive nil)
  (lsp-modeline-workspace-status-enable t)
  (lsp-lens-enable nil)
  ;; python
  (lsp-pylsp-plugins-black-enabled t)
  ;; texlab
  :config
  (lsp-enable-which-key-integration t)
  (define-key lsp-mode-map (kbd "M-l") lsp-command-map)
  :hook ((python-mode tuareg-mode TeX-mode rust-mode java-mode haskell-mode) . lsp-deferred)
  :commands (lsp lsp-deferred))

(defun my/disable-lsp-in-subdir ()
  "Disable lsp-mode in the current buffer if it's under a specific directory."
  (let ((disable-lsp-subdir "~/Desktop/PL-playground/HATch/data/"))  ; replace with the actual path
    (when (and lsp-mode
               (string-prefix-p (expand-file-name disable-lsp-subdir)
                                (expand-file-name default-directory)))
      (lsp-disconnect)
      (lsp--info "LSP Mode disabled for this buffer"))))

(add-hook 'lsp-mode-hook #'my/disable-lsp-in-subdir)


;; optionally
(use-package lsp-ui
  :requires flycheck
  :custom
  (lsp-us-doc-delay 0.500)
  (lsp-ui-sideline-show-diagnositcs t)
  :commands lsp-ui-mode)
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
(use-package dap-mode
  :after lsp-mode
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode)
  :config (dap-auto-configure-mode))
;; Posframe is a pop-up tool that must be manually installed for dap-mode
(use-package posframe)
(use-package ccls
  :hook ((c-mode c++-mode objc-mode cuda-mode) .
         (lambda () (require 'ccls) (lsp))))
;; --- java ---
(use-package lsp-java)
;; (use-package dap-java)
;; --------------------------- ORG ------------------------------
;; does not work (add-hook 'org-mode (plist-put org-format-latex-options :scale 2.0))

(use-package org
  :straight (:type built-in)
  :init
  (defun org-journal-find-location ()
    ;; Open today's journal, but specify a non-nil prefix argument in order to
    ;; inhibit inserting the heading; org-capture will insert the heading.
    (org-journal-new-entry t)
    (unless (eq org-journal-file-type 'daily)
      (org-narrow-to-subtree))
    (goto-char (point-max)))
  (defun babel-ansi ()
    (when-let ((beg (org-babel-where-is-src-block-result nil nil)))
      (save-excursion
        (goto-char beg)
        (when (looking-at org-babel-result-regexp)
          (let ((end (org-babel-result-end))
                (ansi-color-context-region nil))
            (ansi-color-apply-on-region beg end))))))
  :custom
  (org-directory "~/Dropbox/org")
  (org-default-notes-file (concat org-directory "/refile.org"))
  (org-agenda-files '("~/Dropbox/org" "~/Dropbox/org-journal"))
  (org-refile-targets '((nil :maxlevel . 3)
                        (org-agenda-files :maxlevel . 3)))
  (org-src-tab-acts-natively t)
  (org-confirm-babel-evaluate nil)
  ;; Todo keywords. Change these to your liking
  (org-todo-keywords
   '((sequence "MAYBE(m)" "WAITING(w@/!)" "NEXT(n!)" "|" "DONE(d!)" "CANCELLED(c@)")))
  (org-capture-templates
   '(("m" "Maybe" entry (file+headline org-default-notes-file "Maybe")
      "* MAYBE %?")
     ("w" "Waiting" entry (file+headline org-default-notes-file "Waiting")
      "* WAITING %?")
     ("s" "Scheduled" entry (file+headline org-default-notes-file "Scheduled")
      "* %?\nSCHEDULED: %^t")
     ("d" "Deadline" entry (file+headline org-default-notes-file "Deadline")
      "* %?\nDEADLINE: %^t")
     ("n" "Next" entry (file+headline org-default-notes-file "Next")
      "* NEXT %?")
     ("j" "Journal entry" plain (function org-journal-find-location)
      "** %?"
      :clock-in t :clock-resume t)
     ("p" "Protocol" entry (file+headline org-default-notes-file "Inbox")
      "* %^{Title}\nSource: %U, [[%:link][%:description]]\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
     ("L" "Protocol Link" entry (file+headline org-default-notes-file "Inbox")
      "* %?[[%:link][%:description]] \nCaptured On: %U")
     ))
  (org-tags-column 0)
  (org-tag-alist '((:startgroup . nil)
                   ("@school" . ?s) ("@home" . ?h)
                   ("@corec" . ?t)
                   (:endgroup . nil)
                   (:startgroup . nil)
                   ("research" . ?r) ("meet" . ?m)
                   ("customize" . ?c) ("paper" . ?p)
                   (:endgroup . nil)
                   ))
  (org-log-into-drawer t)
  (org-clock-persistence-insinuate t)
  (org-clock-into-drawer t)
  (org-log-reschedule 'time)
  (org-startup-folded t)
  (org-startup-indented t)
  (org-startup-with-inline-images t)
  (org-startup-with-latex-preview t)
  (org-pretty-entities t)
  (org-hide-emphasis-markers t)
  (org-export-with-sub-superscripts '{})
  (org-use-sub-superscripts '{})
  (org-image-actual-width '(1000))
  ;; (setq org-image-actual-width (/ (display-pixel-width) 2))
  :config
  (require 'org-protocol)
  (global-set-key (kbd "C-c l") #'org-store-link)
  (global-set-key (kbd "C-c a") #'org-agenda)
  (global-set-key (kbd "C-c c") #'org-capture)
  (setq org-format-latex-options
        (plist-put (plist-put org-format-latex-options :scale 3.0)
                   :background "Transparent"))
  (dolist (face '((org-document-title . 1.5)
                  (org-level-1 . 1.3)
                  (org-level-2 . 1.2)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Monaco" :weight 'medium :height (cdr face)))
  ;; load path
  (add-to-list 'load-path "~/.emacs.d/ob-z3-smt2")
  (require 'ob-z3-smt2) ;; local
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((R . t)
     (ocaml . t)
     (shell . t)
     (python .t)
     (sqlite .t)
     (z3-smt2 .  t)))
  (defvar org-babel-eval-verbose t
    "A non-nil value makes `org-babel-eval' display")
  (defun gsgx/org-roam-create-note-from-headline ()
    "Create an Org-roam note from the current headline if it doesn't
exist without jumping to it"
    (let* ((title (nth 4 (org-heading-components)))
           ;; Read in the name of the node, with the title filled in
           ;; TODO: How can I just use the title without user input?
           (node (org-roam-node-read title)))
      ;; Skip the node if it already exists
      (if (org-roam-node-file node)
          (message "Skipping %s, node already exists" title)
        ;; Without this the subsequent kills seem to be grouped together, not
        ;; sure why
        (kill-new "")
        ;; Cut the subtree from the original file
        (org-cut-subtree)
        ;; Create the new capture file
        (org-roam-capture- :node node)
        ;; Paste in the subtree
        (org-paste-subtree)
        ;; Removing the heading from new node
        (kill-whole-line)
        ;; Finalizing the capture will save and close the capture buffer
        (org-capture-finalize nil)
        ;; Because we've deleted a subtree, we need the following line to make the
        ;; `org-map-entries' call continue from the right place
        (setq org-map-continue-from
              (org-element-property :begin (org-element-at-point))))))
  ;; (defun gsgx/org-roam-create-note-from-headlines ()
  ;;   (interactive)
  ;;   (if (region-active-p)
  ;;       ;; `region-start-level' means we'll map over only headlines that are at
  ;;       ;; the same level as the first headline in the region. This may or may not
  ;;       ;; be what you want
  ;;       (org-map-entries
  ;;        'gsgx/org-roam-create-note-from-headline t 'region-start-level)
  ;;     ;; If no region was selected, just create the note from the current headline
  ;;     (gsgx/org-roam-create-note-from-headline)))

  (defun bg-org-fill-paragraph-with-link-nobreak-p ()
    "Do not allow `fill-paragraph' to break inside the middle of Org mode links."
    (and (assq :link (org-context)) t))
  :hook
  (org-mode . visual-line-mode)
  (org-mode . (lambda ()
                (add-to-list 'fill-nobreak-predicate 'texmathp)
                (add-to-list 'fill-nobreak-predicate 'bg-org-fill-paragraph-with-link-nobreak-p)
                ))
  (org-babel-after-execute . babel-ansi)
  ;; (org-babel-after-execute-hook . org-display-inline-images)
  ;; :hook (org-babel-eval . org-redisplay-inline-images)
  )
(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode))
(use-package org-transclusion
  :after org
  :general
  (:keymaps 'org-mode-map
            "C-c t" 'org-transclusion-mode))
(use-package org-phscroll
  :straight (:host github :repo "misohena/phscroll" :files ("*.el")))
(use-package org-download
  :custom
  (org-download-method 'attach))
(use-package org-present
  :requires org
  ;; :general
  ;; (:keymaps 'org-mode-map
  ;;           "C-c C-p" 'org-present)
  :bind (:map org-present-mode-keymap
              ("C-c C-j" . org-present-next)
              ("C-c C-k" . org-present-prev))
  :hook ((org-present-mode . (lambda ()
                               (org-present-big)
                               (org-display-inline-images)
                               (org-present-hide-cursor)
                               ;; (setq visual-fill-column-center-text nil)
                               ;; (setq org-image-actual-width '(1000))
                               ))
         (org-present-mode-quit . (lambda ()
                                    (org-present-small)
                                    (org-display-inline-images)
                                    (org-present-show-cursor)
                                    (setq visual-fill-column-center-text t)
                                    ;; (setq org-image-actual-width '(600))
                                    ))))
(use-package org-inline-pdf
  :hook ((org-mode . org-inline-pdf-mode))
  )
(use-package org-fragtog
  :hook ((org-mode . org-fragtog-mode)))
;; (use-package org-journal
;;   :init
;;   ;; Change default prefix key; needs to be set before loading org-journal
;;   (setq org-journal-prefix-key "C-c j ")
;;   :custom
;;   (org-journal-file-type 'daily)
;;   (org-journal-enable-agenda-integration nil)
;;   :general
;;   ("C-c t" 'org-journal-open-current-journal-file)
;;   :config
;;   (setq org-journal-dir "~/Dropbox/org-journal/"
;;         org-journal-date-format "%A, %d %B %Y")
;;   :hook
;;   (org-journal-mode . auto-revert-mode))
;; https://mpas.github.io/posts/2021/03/16/2021-03-16-time-tracking-with-org-mode-and-sum-time-per-tag/
(defun convert-org-clocktable-time-to-hhmm (time-string)
  "Converts a time string to HH:MM"
  (if (> (length time-string) 0)
      (progn
        (let* ((s (s-replace "*" "" time-string))
               (splits (split-string s ":"))
               (hours (car splits))
               (minutes (car (last splits)))
               )
          (if (= (length hours) 1)
              (format "0%s:%s" hours minutes)
            (format "%s:%s" hours minutes))))
    time-string))
(use-package orgtbl-aggregate)
(use-package ox-hugo
  :after ox)
;; (use-package citar
;;   :bind (("C-c r" . citar-open)
;;          :map minibuffer-local-map
;;          ("M-b" . citar-insert-preset))
;;   :custom
;;   (citar-bibliography '("~/Documents/paper.bib")))
;; (use-package citar-org-roam
;;   :after citar org-roam
;;   :no-require
;;   :config (citar-org-roam-mode)
;;   (citar-register-notes-source
;;    'orb-citar-source (list :name "Org-Roam Notes"
;;                            :category 'org-roam-node
;;                            :items #'citar-org-roam--get-candidates
;;                            :hasitems #'citar-org-roam-has-notes
;;                            :open #'citar-org-roam-open-note
;;                            :create #'orb-citar-edit-note
;;                            :annotate #'citar-org-roam--annotate))
;;   (setq citar-notes-source 'orb-citar-source))

;; http://user42.tuxfamily.org/nobreak-fade/index.html
;; prevent breaks at certain points during "paragraph filling"
;; (use-package nobreak-fade
;;   :straight (:host github :repo "emacsmirror/nobreak-fade")
;;   :config (nobreak-fade-tex-math-add))
;; (require 'nobreak-fade)
;; (autoload 'nobreak-fade-single-letter-p "nobreak-fade")
;; (add-hook 'fill-nobreak-predicate 'nobreak-fade-single-letter-p)

;; TODO stop working for some reason
;; (defun bg-org-fill-paragraph-with-link-nobreak-p ()
;;   "Do not allow `fill-paragraph' to break inside the middle of Org mode links."
;;   (and (assq :link (org-context)) t))
;; (add-hook 'fill-nobreak-predicate 'bg-org-fill-paragraph-with-link-nobreak-p)

;; (defun fill-open-link-nobreak-p ()
;;   "Don't break a line after an unclosed \"[[link \"."
;;   (save-excursion
;;     (skip-chars-backward " ")
;;     (let ((opoint (point))
;;           spoint inside)
;;       (save-excursion
;;         (beginning-of-line)
;;         (setq spoint (point)))
;;        (when (re-search-backward "\\[\\[" spoint t)
;;         ;; (message "found") (sit-for 2)
;;         (unless (re-search-forward "\\]\\]" opoint t)
;;           (setq inside t)))
;;       inside)))
;; (add-hook 'fill-nobreak-predicate '(fill-open-link-nobreak-p))

;; (defun odd-number-tilde-this-paragraph-so-far ()
;;   (oddp (how-many "~" (save-excursion (backward-paragraph) (point)) (point))))
;; (add-hook 'fill-nobreak-predicate '(odd-number-tilde-this-paragraph-so-far))

;; https://kitchingroup.cheme.cmu.edu/blog/2016/06/16/Copy-formatted-org-mode-text-from-Emacs-to-other-applications/
(defun formatted-copy ()
  "Export region to HTML, and copy it to the clipboard."
  (interactive)
  (save-window-excursion
    (let* ((buf (org-export-to-buffer 'html "*Formatted Copy*" nil nil t t))
           (html (with-current-buffer buf (buffer-string))))
      (with-current-buffer buf
        (shell-command-on-region
         (point-min)
         (point-max)
         "textutil -stdin -format html -convert rtf -stdout | pbcopy"))
      (kill-buffer buf))))

;; vulpea is a wrapper for org-roam, used for integration with org-agenda here
;; (use-package vulpea
;;   :after org
;;   :config
;;   (add-to-list 'org-tags-exclude-from-inheritance "roam-agenda")
;;   (defun vulpea-buffer-p ()
;;     "Return non-nil if the currently visited buffer is a note."
;;     (and buffer-file-name
;;          (string-prefix-p
;;           (expand-file-name (file-name-as-directory org-roam-directory))
;;           (file-name-directory buffer-file-name))))

;;   (defun vulpea-project-p ()
;;     "Return non-nil if current buffer has any todo entry.

;; TODO entries marked as done are ignored, meaning the this
;; function returns nil if current buffer contains only completed
;; tasks."
;;     (seq-find                                 ; (3)
;;      (lambda (type)
;;        (eq type 'todo))
;;      (org-element-map                         ; (2)
;;          (org-element-parse-buffer 'headline) ; (1)
;;          'headline
;;        (lambda (h)
;;          (org-element-property :todo-type h)))))

;;   (defun vulpea-project-update-tag (&optional arg)
;;     "Update PROJECT tag in the current buffer."
;;     (interactive "P")
;;     (when (and (not (active-minibuffer-window))
;;                (vulpea-buffer-p))
;;       (save-excursion
;;         (goto-char (point-min))
;;         (let* ((tags (vulpea-buffer-tags-get))
;;                (original-tags tags))
;;           (if (vulpea-project-p)
;;               (setq tags (cons "roam-agenda" tags))
;;             (setq tags (remove "roam-agenda" tags)))

;;           ;; cleanup duplicates
;;           (setq tags (seq-uniq tags))

;;           ;; update tags if changed
;;           (when (or (seq-difference tags original-tags)
;;                     (seq-difference original-tags tags))
;;             (apply #'vulpea-buffer-tags-set tags))))))

;;   (defun vulpea-project-files ()
;;     "Return a list of note files containing 'project' tag." ;
;;     (seq-uniq
;;      (seq-map
;;       #'car
;;       (org-roam-db-query
;;        [:select [nodes:file]
;;                 :from tags
;;                 :left-join nodes
;;                 :on (= tags:node-id nodes:id)
;;                 :where (like tag (quote "%\"roam-agenda\"%"))]))))

;;   (defun vulpea-agenda-files-update (&rest _)
;;     "Update the value of `org-agenda-files'."
;;     (setq org-agenda-files (cons "~/org-mode/dailies" 'vulpea-project-files)))

;;   (add-hook 'find-file-hook #'vulpea-project-update-tag)
;;   (add-hook 'before-save-hook #'vulpea-project-update-tag)

;;   (advice-add 'org-agenda :before #'vulpea-agenda-files-update)
;;   (advice-add 'org-todo-list :before #'vulpea-agenda-files-update)
;;   )

;; --------------------- org-roam --------------
(use-package org-roam
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/org-roam")
  (org-roam-completion-everywhere t)
  (org-roam-dailies-capture-templates
   '(("d" "default" entry "* %<%I:%M %p>: %?"
      :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))
  :general
  ("C-c n"  '(:ignore t :which-key "org-roam")
   "C-c n l" 'org-roam-buffer-toggle
   "C-c n L" 'org-toggle-link-display
   "C-c n f" 'org-roam-node-find
   "C-c n i" 'org-roam-node-insert
   "C-c n g" 'org-roam-graph
   "C-c n c" 'org-roam-capture
   "C-c n a" 'org-roam-alias-add
   "C-c n t" 'org-roam-tag-add
   "C-c n r" 'org-roam-refile
   "C-c n d"  '(:ignore t :which-key "org-roam-dailies")
   "C-c n d y" 'org-roam-dailies-capture-yesterday
   "C-c n d Y" 'org-roam-dailies-goto-yesterday
   "C-c n d d" 'org-roam-dailies-capture-today
   "C-c n d D" 'org-roam-dailies-goto-today
   "C-c n d t" 'org-roam-dailies-capture-tomorrow
   "C-c n d T" 'org-roam-dailies-goto-tomorrow
   "C-c n d f" 'org-roam-dailies-capture-date
   "C-c n d F" 'org-roam-dailies-goto-date)
  :config
  ;; (setq org-roam-capture-templates
  ;;    '(;; ... other templates
  ;;      ;; bibliography note template
  ;;      ("r" "bibliography reference" plain "%?"
  ;;       :target
  ;;       (file+head "${citekey}.org" "#+title: ${title}\n")
  ;;       :unnarrowed t)))
  ;; If using org-roam-protocol
  ;; (require 'org-roam-dailies)
  ;; (require 'org-roam-protocol)
  (org-roam-db-autosync-mode))

(use-package org-ref)
(use-package org-roam-bibtex
  :after org-roam org-ref
  :config
  (org-roam-bibtex-mode))
(use-package ivy-bibtex
  :after ivy org-roam-bibtex
  :bind
  ("C-c r" . ivy-bibtex)
  :config
  ;; https://github.com/tmalsburg/helm-bibtex
  (setq bibtex-completion-additional-search-fields '(journal booktitle))
  (setq bibtex-completion-display-formats
        '((article       . "${=has-pdf=:1}${=has-note=:1} ${=type=:3} ${year:4} ${author:36} ${title:*} ${journal:40}")
          (inbook        . "${=has-pdf=:1}${=has-note=:1} ${=type=:3} ${year:4} ${author:36} ${title:*} Chapter ${chapter:32}")
          (incollection  . "${=has-pdf=:1}${=has-note=:1} ${=type=:3} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
          (inproceedings . "${=has-pdf=:1}${=has-note=:1} ${=type=:3} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
          (t             . "${=has-pdf=:1}${=has-note=:1} ${=type=:3} ${year:4} ${author:36} ${title:*}")))
  (setq bibtex-completion-bibliography "~/Documents/paper.bib")
  (setq bibtex-completion-notes-path "~/org-roam/")
  ;; default is to open pdf - change that to insert citation
  (setq bibtex-completion-pdf-field "file")
  ;; (setq ivy-bibtex-default-action #'ivy-bibtex-insert-citation)
  (setq ivy-bibtex-default-action 'ivy-bibtex-edit-notes)
  ;; (ivy-set-actions
  ;;  'ivy-bibtex
  ;;  '(("p" ivy-bibtex-open-any "Open PDF, URL, or DOI")
  ;;    ("e" ivy-bibtex-edit-notes "Edit notes")))
  (defun bibtex-completion-open-pdf-external (keys &optional fallback-action)
    (let ((bibtex-completion-pdf-open-function
           (lambda (fpath) (start-process "okular" "*ivy-bibtex-okular*" "okular" fpath))))
      (bibtex-completion-open-pdf keys fallback-action)))

  (ivy-bibtex-ivify-action bibtex-completion-open-pdf-external ivy-bibtex-open-pdf-external)

  (ivy-add-actions
   'ivy-bibtex
   '(("P" ivy-bibtex-open-pdf-external "Open PDF file in external viewer (if present)")))
  (setq bibtex-completion-pdf-symbol "⌘")
  (setq bibtex-completion-notes-symbol "✎"))

(use-package reftex
  :config
  (setq reftex-cite-prompt-optional-args t)) ; Prompt for empty optional arguments in cite

(use-package latex
  :straight auctex
  :init
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-PDF-mode t
        TeX-source-correlate-method 'synctex
        TeX-source-correlate-mode t
        TeX-source-correlate-start-server t

        TeX-view-program-selection
        '(((output-dvi has-no-display-manager) "dvi2tty")
          ((output-dvi style-pstricks) "dvips and gv")
          (output-dvi "xdvi")
          (output-pdf "Okular")
          (output-pdf "PDF Tools")
          (output-html "xdg-open"))
        ;; TeX-view-program-list '(("Okular" "okular --unique \"file:$$o#src:$$n $$f\""))
        )
  (setq-default TeX-master nil)

  (add-hook 'LaTeX-mode-hook 'visual-line-mode)
  (add-hook 'LaTeX-mode-hook 'flyspell-mode)
  (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)

  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  ;; (add-hook 'LaTeX-mode-hook 'turn-on-cdlatex)
  ;; (add-hook 'LaTeX-mode-hook 'xenops-mode)
  (add-hook 'TeX-after-compilation-finished-functions
            #'TeX-revert-document-buffer)
  (setq reftex-plug-into-AUCTeX t)
  :custom
  (preview-auto-reveal-p t)
  (texmathp-tex-commands '(("mathpar" env-on)
                           ("Infer" arg-on)))
  (preview-scale-from-face 1.0))
(use-package lsp-latex
  :straight (:host github :repo "ROCKTAKEY/lsp-latex")
  :config
  (setq lsp-latex-build-on-save t)
  (setq lsp-latex-forward-search-executable "okular")
  (setq lsp-latex-forward-search-args '("--unique" "file:%p#src:%l%f")))
(use-package evil-tex
  :after evil
  :hook (LaTeX-mode . evil-tex-mode)
  :general
  (:states 'normal :keymaps 'evil-tex-mode-map
            "[ e" 'LaTeX-find-matching-begin
            "] e" 'LaTeX-find-matching-end))
(use-package cdlatex :after latex)
;; (use-package xenops :after latex)
(use-package auctex-latexmk
  :after latex
  :custom (auctex-latexmk-inherit-TeX-PDF-mode t)
  :config (auctex-latexmk-setup))

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-tools-install)
  ;; :bind ("C-c C-g" . pdf-sync-forward-search)
  :config
  (setq mouse-wheel-follow-mouse t)
  ;; (setq pdf-view-resize-factor 1.10)
  )

;; writing tool
(use-package academic-phrases)

(use-package synosaurus
  :diminish synosaurus-mode
  :init    (synosaurus-mode)
  :config  (setq synosaurus-choose-method 'popup) ;; 'ido is default.
  (global-set-key (kbd "M-#") 'synosaurus-choose-and-replace)
  )

(use-package wordnut
  :bind ("M-!" . wordnut-lookup-current-word))
;; ;; ------------- auctex --------------
;; (use-package latex
;;   :ensure auctex
;;   :config
;;   (setq TeX-auto-save t
;;      TeX-parse-self t
;;      TeX-PDF-mode t
;;      TeX-view-program-list '(("okular"))
;;      )
;;   (use-package auctex-latexmk
;;     :commands (auctex-latexmk-setup)
;;     :config
;;     (setq auctex-latexmk-inherit-TeX-PDF-mode t))
;;   (use-package company-auctex 
;;     :commands (company-auctex-init)
;;     )
;;   )

;; ----- coq -----
(use-package proof-general
  :config
  ;; copied from https://github.com/ProofGeneral/PG/issues/430#issuecomment-604317650
  (general-define-key :states 'normal :keymaps '(coq-mode-map)
                      "C-r" 'coq-redo
                      "u" 'coq-undo)

  (defun pg-in-protected-region-p ()
    (< (point) (proof-queue-or-locked-end)))

  (defmacro coq-wrap-edit (action)
    `(if (or (not proof-locked-span)
             (equal (proof-queue-or-locked-end) (point-min)))
         (,action)
       (,action)
       (when (pg-in-protected-region-p)
         (proof-goto-point))))

  (defun coq-redo ()
    (interactive)
    (coq-wrap-edit undo-tree-redo))

  (defun coq-undo ()
    (interactive)
    (coq-wrap-edit undo-tree-undo))

  (add-hook 'coq-mode-hook #'undo-tree-mode)
  )

(use-package company-coq
  :hook (coq-mode . company-coq-mode)
  )

;; --------


;; ;; ---------------------------- ocaml ----------------------------
;; ## added by OPAM user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
;; ## end of OPAM user-setup addition for emacs / base ## keep this line
(use-package tuareg
  :custom
  (tuareg-opam-insinuate t)
  :config
  (require 'ocamldebug)
  :hook (before-save . lsp-format-buffer))
(use-package dune
  :config
  (require 'dune-watch)
  (require 'dune-flymake))
(use-package dune-format)
;; ;; TODO: add hook to load correct path
;; ;; (add-to-list 'load-path "/home/slark/sis-lambda/sis/_opam/share/emacs/site-lisp")
;; ;; Make company aware of merlin
;; (add-hook 'tuareg-mode-hook #'merlin-mode)
;; (add-hook 'caml-mode-hook #'merlin-mode)
;; (with-eval-after-load 'company
;;   (add-to-list 'company-backends 'merlin-company-backend))
;; (use-package flycheck-ocaml
;;   :config
;;   (add-hook 'tuareg-mode-hook
;;             (lambda ()
;;               ;; disable Merlin's own error checking
;;               (setq-local merlin-error-after-save nil)
;;               ;; enable Flycheck checker
;;               (flycheck-ocaml-setup))))
;; (use-package merlin
;;   :config
;;   (add-hook 'tuareg-mode-hook #'merlin-mode)
;;   (add-hook 'merlin-mode-hook #'company-mode))
;; (use-package merlin-company  :after merlin)
;; (use-package merlin-iedit  :after merlin)
;; (use-package ocamlformat
;;   :custom (ocamlformat-enable 'enable-outside-detected-project)
;;   :hook (before-save . ocamlformat-before-save))
;; (use-package merlin-eldoc
;;   :after merlin
;;   :custom
;;   (eldoc-echo-area-use-multiline-p t) ; use multiple lines when necessary
;;   ;; (merlin-eldoc-max-lines 8)          ; but not more than 8
;;   (merlin-eldoc-type-verbosity 'max)  ; don't display verbose types
;;   (merlin-eldoc-function-arguments t) ; don't show function arguments
;;   (merlin-eldoc-doc t)                ; don't show the documentation
;;   (merlin-eldoc-occurrences nil)
;;   :bind (:map merlin-mode-map
;;               ("C-c m p" . merlin-eldoc-jump-to-prev-occurrence)
;;               ("C-c m n" . merlin-eldoc-jump-to-next-occurrence))
;;   :hook ((tuareg-mode reason-mode caml-mode) . merlin-eldoc-setup))

;; ----------------------------- rust -----------------------------
(use-package poly-markdown)
(use-package rustic
  :after poly-markdown
  :init
  (setq rustic-cargo-run-use-comint t)
  :custom
  (rustic-lsp-client 'lsp)
  (rustic-cargo-run-use-comint t)
  (poly-rustic-cargo-compilation-hostmode 'poly-markdown-hostmode)
  (rustic-format-trigger 'on-save))

;; ----------------------------- typescript -----------------------------
(use-package typescript-mode
  :after tree-sitter lsp-mode
  :custom (typescript-indent-level 2)
  :config
  ;; we choose this instead of tsx-mode so that eglot can automatically figure out language for server
  ;; see https://github.com/joaotavora/eglot/issues/624 and https://github.com/joaotavora/eglot#handling-quirky-servers
  (define-derived-mode typescriptreact-mode typescript-mode
    "TypeScript TSX")

  ;; use our derived mode for tsx files
  (add-to-list 'auto-mode-alist '("\\.tsx?\\'" . typescriptreact-mode))
  ;; by default, typescript-mode is mapped to the treesitter typescript parser
  ;; use our derived mode to map both .tsx AND .ts -> typescriptreact-mode -> treesitter tsx
  (add-to-list 'tree-sitter-major-mode-language-alist '(typescriptreact-mode . tsx))
  :hook (typescript-mode . lsp-deferred))
;; great tree-sitter-based indentation for typescript/tsx, css, json
(use-package tsi
  :straight (:host github :repo "orzechowskid/tsi.el")
  :after tree-sitter
  ;; define autoload definitions which when actually invoked will cause package to be loaded
  :commands (tsi-typescript-mode tsi-json-mode tsi-css-mode)
  :init
  (add-hook 'typescript-mode-hook (lambda () (tsi-typescript-mode 1)))
  (add-hook 'json-mode-hook (lambda () (tsi-json-mode 1)))
  (add-hook 'css-mode-hook (lambda () (tsi-css-mode 1)))
  (add-hook 'scss-mode-hook (lambda () (tsi-scss-mode 1))))


;; ---------------------------- scala -----------------------------
(use-package scala-mode
  :mode "\\.s\\(cala\\|bt\\)$"
  :interpreter ("scala" . scala-mode))
(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
   ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
   (setq sbt:program-options '("-Dsbt.supershell=false")))
(use-package lsp-metals)

(use-package codeium
  :straight '(:type git :host github :repo "Exafunction/codeium.el")
  :init
  ;; use globally
  ;; (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)
  ;; or on a hook
  ;; (add-hook 'tuareg-mode-hook
  ;;     (lambda ()
  ;;         (setq-local completion-at-point-functions '(codeium-completion-at-point))))
  ;; 
  ;; if you want multiple completion backends, use cape (https://github.com/minad/cape):
  ;; (add-hook 'python-mode-hook
  ;;     (lambda ()
  ;;         (setq-local completion-at-point-functions
  ;;             (list (cape-super-capf #'codeium-completion-at-point #'lsp-completion-at-point)))))
  ;; an async company-backend is coming soon!

  ;; codeium-completion-at-point is autoloaded, but you can
  ;; optionally set a timer, which might speed up things as the
  ;; codeium local language server takes ~0.2s to start up
  ;; (add-hook 'emacs-startup-hook
  ;;  (lambda () (run-with-timer 0.1 nil #'codeium-init)))

  ;; :defer t ;; lazy loading, if you want
  :config
  (setq use-dialog-box nil) ;; do not use popup boxes

  ;; if you don't want to use customize to save the api-key
  ;; (setq codeium/metadata/api_key "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")

  ;; get codeium status in the modeline
  (setq codeium-mode-line-enable
        (lambda (api) (not (memq api '(CancelRequest Heartbeat AcceptCompletion)))))
  (add-to-list 'mode-line-format '(:eval (car-safe codeium-mode-line)) t)
  ;; alternatively for a more extensive mode-line
  ;; (add-to-list 'mode-line-format '(-50 "" codeium-mode-line) t)

  ;; use M-x codeium-diagnose to see apis/fields that would be sent to the local language server
  (setq codeium-api-enabled
        (lambda (api)
          (memq api '(GetCompletions Heartbeat CancelRequest GetAuthToken RegisterUser auth-redirect AcceptCompletion))))
  ;; you can also set a config for a single buffer like this:
  ;; (add-hook 'python-mode-hook
  ;;     (lambda ()
  ;;         (setq-local codeium/editor_options/tab_size 4)))

  ;; You can overwrite all the codeium configs!
  ;; for example, we recommend limiting the string sent to codeium for better performance
  (defun my-codeium/document/text ()
    (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (min (+ (point) 1000) (point-max))))
  ;; if you change the text, you should also change the cursor_offset
  ;; warning: this is measured by UTF-8 encoded bytes
  (defun my-codeium/document/cursor_offset ()
    (codeium-utf8-byte-length
     (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (point))))
  (setq codeium/document/text 'my-codeium/document/text)
  (setq codeium/document/cursor_offset 'my-codeium/document/cursor_offset))

(use-package copilot
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("dist" "*.el"))
  :general
  (copilot-completion-map
   "C-f" #'copilot-accept-completion
   "C-e" #'copilot-accept-completion-by-line
   "M-f" #'copilot-accept-completion-by-word
   "M-n" #'copilot-next-completion
   "M-p" #'copilot-previous-completion)
  :config
  (add-to-list 'copilot-indentation-alist '(tuareg-mode 2))
  :hook
  (prog-mode . copilot-mode)
  (copilot-mode . (lambda ()
                    (setq-local copilot--indent-warning-printed-p t))))
  
;; (defun my/copilot-tab ()
;;   (interactive)
;;   (or (copilot-accept-completion)
;;       (indent-for-tab-command)))

;; (with-eval-after-load 'copilot
;;   (evil-define-key 'insert copilot-mode-map
;;     (kbd "<tab>") #'my/copilot-tab))

(use-package chatgpt
  :straight (:host github :repo "joshcho/ChatGPT.el" :files ("dist" "*.el"))
  :init
  (require 'python)
  (setq chatgpt-repo-path "~/.emacs.d/straight/repos/ChatGPT.el/")
  :bind ("C-c q" . chatgpt-query)
  :config
  (unless (boundp 'python-interpreter)
    (defvaralias 'python-interpreter 'python-shell-interpreter)))

(use-package ob-chatgpt
  :straight (:host github :repo "suonlight/ob-chatgpt" :files ("dist" "*.el"))
  :after org chatgpt)

(use-package vterm
  :general
  ("C-'" #'vterm)
  (vterm-mode-map "C-q" #'vterm-send-next-key))

(defun re+sexp-search-forward (regexp bound noerror)
  "Search forward for REGEXP (like `re-search-forward')
but with appended sexp."
  (when (re-search-forward regexp bound noerror)
    (let ((md (match-data))
      bsub esub)
      (setq bsub (1+ (scan-sexps (goto-char (scan-sexps (point) 1)) -1))
        esub (1- (point)))
      (setcar (cdr md) (set-marker (make-marker) (point)))
      (setq md (append md (list (set-marker (make-marker) bsub)
                (set-marker (make-marker) esub))))
      (set-match-data md)
      (point))))

(defun query-replace-re+sexp ()
  "Like `query-replace-regexp' but at each match it includes the trailing sexps
into the match as an additional subexpression (the last one)."
  (interactive)
  (let ((replace-re-search-function 're+sexp-search-forward)) (call-interactively 'query-replace-regexp)))

(use-package boogie-friends
  :after flycheck
  :config
  (setq flycheck-inferior-dafny-executable "~/Desktop/PL-playground/dafny/DafnyServer")
  (setq flycheck-dafny-executable "~/Desktop/PL-playground/dafny/dafny")
  (setq dafny-verification-backend 'server)
  ;; (setq dafny-verification-backend nil)
  )

(use-package racket-mode
  :mode "\\.rkt\\'")

(use-package solidity-mode
  :after solidity-flycheck
  :general
  (solidity-mode-map "C-c C-g" #'solidity-estimate-gas-at-point)
  :custom
  (solidity-flycheck-solc-checker-active t)
  (solidity-flycheck-solium-checker-active t))
(use-package solidity-flycheck)
(use-package company-solidity
  :after solidity-mode)

;; haskell
(use-package haskell-mode)
(use-package lsp-haskell
  :config
  (setf lsp-haskell-server-path "~/.ghcup/bin/haskell-language-server-wrapper"))
(use-package json-mode)

(use-package graphviz-dot-mode
  :mode "\\.dot\\'"
  :custom (graphviz-dot-indent-width 2))

;; https://stackoverflow.com/questions/23378271/how-do-i-display-ansi-color-codes-in-emacs-for-any-mode
(defun ansi-color-after-scroll (window start)
  "Used by ansi-color-mode minor mode"
  (ansi-color-apply-on-region start (window-end window t) t))

(define-minor-mode ansi-color-mode
  "A very primitive minor mode to view log files containing ANSI color codes.

Pros: this minor mode runs `ansi-color-apply-on-region' lazily,
i.e. only the visible part of the buffer. Hence, it does NOT
freeze Emacs even if the log file is huge.

Cons: a) when the minor code is toggled off, it does not undo
what has already been ansi colorized. b) assumes the buffer
content etc. does not change. c) jumping to random places within
the buffer may incur incorrect/incomplete colorization.

How to install: put this code into your init.el, then evaluate it or
restart Emacs for the code to take effect.

How to use: in the log buffer of need run `M-x ansi-color-mode'.
Alternatively, feel free to enable this minor mode via mode hooks
so that you needn't enable it manually.

-- lgfang
"
  :global nil
  :lighter ""
  (if ansi-color-mode
      (progn 
        (ansi-color-apply-on-region (window-start) (window-end) t)
        (add-hook 'window-scroll-functions 'ansi-color-after-scroll 80 t))
    (remove-hook 'window-scroll-functions 'ansi-color-after-scroll t)))

(provide 'init)
;;; init.el ends here
