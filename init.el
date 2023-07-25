(setq package-enable-at-startup nil)

(defun fullscreen (&optional f)
  (interactive)
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
             '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
             '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0)))
(fullscreen)

;; Encoding and Envs
(prefer-coding-system 'utf-8)

(add-to-list 'default-frame-alist '(font . "JetBrains Mono"))
(set-face-attribute 'default t :font "JetBrains Mono")

;; Feature Mode
(column-number-mode t)                       ;; 在 Mode line 上显示列号
(tool-bar-mode 0) (menu-bar-mode 0) (scroll-bar-mode 0)
(toggle-scroll-bar -1)
(global-auto-revert-mode t)                  ;; 当另一程序修改了文件时，让 Emacs 及时刷新 Buffer
;; (toggle-frame-fullscreen)

;; File Operation
(setq tab-width 4
      inhibit-splash-screen t                ;; hide welcome screen
      mouse-drag-copy-region nil
      initial-scratch-message nil
      sentence-end-double-space nil
      make-backup-files nil                  ;; 关闭文件自动备份
      auto-save-default nil)
(setq-default indent-tabs-mode -1)

;; History
(savehist-mode 1)
(setq savehist-file "~/.emacs.d/.savehist")
(setq history-length t)
(setq history-delete-duplicates t)
(setq savehist-save-minibuffer-history 1)
(setq savehist-additional-variables
      '(kill-ring
        search-ring
        regexp-search-ring))

;; Performance
(if (not (display-graphic-p))
    (progn
      ;; 增大垃圾回收的阈值，提高整体性能（内存换效率）
      (setq gc-cons-threshold (* 8192 8192 8 8))
      ;; 增大同LSP服务器交互时的读取文件的大小
      (setq read-process-output-max (* 1024 1024 1024 8)) ;; 1024MB
      ))
;; Don’t compact font caches during GC.
(setq inhibit-compacting-font-caches t)

;; Titlebar
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark))

(set-face-background 'vertical-border (face-background 'default))
(set-face-foreground 'vertical-border "grey")

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

(straight-use-package 'use-package)
(setq use-package-always-ensure t)

(use-package org
  :straight t
  :ensure t
  :mode ("\\.org\\'" . org-mode)
  :config
  (define-key org-mode-map (kbd "C-c C-r") verb-command-map)
  ;; Refresh org-agenda after rescheduling a task.
  (defun org-agenda-refresh ()
    "Refresh all `org-agenda' buffers."
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (derived-mode-p 'org-agenda-mode)
          (org-agenda-maybe-redo)))))
  (defadvice org-schedule (after refresh-agenda activate)
    "Refresh org-agenda."
    (org-agenda-refresh))
  ;; Log time a task was set to DONE.
  (setq org-log-done (quote time))
  ;; Don't log the time a task was rescheduled or redeadlined.
  (setq org-log-redeadline nil)
  (setq org-log-reschedule nil)
  (setq org-read-date-prefer-future 'time))

(use-package all-the-icons
  :straight (all-the-icons :type git :host github :repo "domtronn/all-the-icons.el")
  :if (display-graphic-p))

(use-package transient
  :straight t
  :ensure t)

(use-package good-scroll
  :straight t
  :ensure t
  :if window-system          ;; 在图形化界面时才使用这个插件
  :init (good-scroll-mode))

(use-package centaur-tabs
  :straight t
  :ensure t
  :demand
  :config
  (centaur-tabs-mode t)
  (setq centaur-tabs-set-icons t
        centaur-tabs-set-bar 'over
        centaur-tabs-show-navigation-buttons t
        x-underline-at-descent-line t
        centaur-tabs-set-modified-marker t
        centaur-tabs-gray-out-icons 'buffer
        centaur-tabs-cycle-scope 'tabs
        centaur-tabs-style "chamfer")
  :hook
  (dired-mode . centaur-tabs-local-mode)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward))

(setq confirm-kill-emacs #'yes-or-no-p)      ;; 在关闭 Emacs 前询问是否确认关闭，防止误触
(electric-pair-mode t)                       ;; 自动补全括号
(add-hook 'prog-mode-hook #'hs-minor-mode)   ;; 编程模式下，可以折叠代码块
(global-display-line-numbers-mode 1)         ;; 在 Window 显示行号
(setq display-line-numbers-type 'relative)   ;; （可选）显示相对行号

(global-set-key (kbd "C-z") 'undo)
(global-unset-key (kbd "C-x C-z"))
(global-set-key (kbd "C-M-z") 'linum-mode)
(global-set-key (kbd "C-M-/") 'comment-or-uncomment-region)
(global-set-key (kbd "C-<tab>") 'find-file-at-point)
(define-key global-map (kbd "<mouse-8>") (kbd "M-w"))
(define-key global-map (kbd "<mouse-9>") (kbd "C-y"))
(fringe-mode '(10 . 10))
(setq-default cursor-type 'bar
              blink-cursor-interval 0.7
              blink-cursor-blinks 8)

(defalias 'yes-or-no-p 'y-or-n-p)
;; (desktop-save-mode 1) ;; auto save window
(setq backward-delete-char-untabify-method nil)
(define-minor-mode show-trailing-whitespace-mode "Show trailing whitespace."
  :init-value nil
  :lighter nil
  (progn (setq show-trailing-whitespace show-trailing-whitespace-mode)))
(define-minor-mode require-final-newline-mode "Require final newline."
  :init-value nil
  :lighter nil
  (progn (setq require-final-newline require-final-newline-mode)))
(add-hook 'prog-mode-hook 'show-trailing-whitespace-mode)
(add-hook 'prog-mode-hook 'require-final-newline-mode)
(add-hook 'prog-mode-hook #'(lambda () (indent-tabs-mode -1)))

;; Window Management
(use-package winum
  :straight t
  :ensure t
  :config (winum-mode))

(use-package ligature
  :straight t
  :ensure t
  :config
  (ligature-set-ligatures 't '("www"))
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://"))
  (global-ligature-mode t))

(use-package list-unicode-display
  :straight t
  :ensure t)

;; hydra
(use-package hydra
  :straight t
  :ensure t)

(use-package use-package-hydra
  :straight t
  :after hydra
  :ensure t)

;; Theme
(use-package color-identifiers-mode
  :straight t
  :ensure t
  :init
  (global-color-identifiers-mode))

(use-package doom-themes
  :straight t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  (doom-themes-treemacs-theme "doom-colors")
  :config
  ;; FIXME: These below are now global. We should patch doom
  ;;        themes to let them display correctly in terminal.
  ;; (defun new-frame-setup (frame)
  ;;   (if (display-graphic-p frame)
  (load-theme 'doom-tomorrow-day t)
  (if (display-graphic-p)
    (progn
      (doom-themes-visual-bell-config)
      (doom-themes-neotree-config)
      (doom-themes-treemacs-config)
      (doom-themes-org-config)))
  ;;     (disable-theme 'doom-tomorrow-day)))
  ;; (mapc 'new-frame-setup (frame-list))
  ;; (add-hook 'after-make-frame-functions 'new-frame-setup)
  (let ((line (face-attribute 'mode-line :underline)))
    (set-face-attribute 'mode-line          nil :overline   line)
    (set-face-attribute 'mode-line-inactive nil :overline   line)
    (set-face-attribute 'mode-line-inactive nil :underline  line)
    (set-face-attribute 'mode-line          nil :box        nil)
    (set-face-attribute 'mode-line-inactive nil :box        nil)
    (set-face-attribute 'mode-line-inactive nil :background "#f9f2d9")))

(use-package moody
  :straight t
  :ensure t
  :config
  (setq x-underline-at-descent-line t)
  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode)
  (moody-replace-eldoc-minibuffer-message-function))

(use-package minions
  :straight t
  :ensure t)

(use-package catppuccin-theme
  :straight t
  :ensure t
  :config
  (setq catppuccin-flavor 'latte) ;; or 'latte, 'macchiato, or 'mocha
  (catppuccin-reload))

;; Dired
(use-package dired-single
  :straight t
  :ensure t
  :config
  (defun my-dired-init ()
    "Bunch of stuff to run for dired, either immediately or when it's
   loaded."
    ;; <add other stuff here>
    (define-key dired-mode-map [remap dired-find-file]
                'dired-single-buffer)
    (define-key dired-mode-map [remap dired-mouse-find-file-other-window]
                'dired-single-buffer-mouse)
    (define-key dired-mode-map [remap dired-up-directory]
                'dired-single-up-directory)))

  ;; if dired's already loaded, then the keymap will be bound
  (if (boundp 'dired-mode-map)
      ;; we're good to go; just add our bindings
      (my-dired-init)
    ;; it's not loaded yet, so add our bindings to the load-hook
    (with-eval-after-load 'dired-mode (my-dired-init)))

(use-package dirvish
  :straight t
  :ensure t
  :config (dirvish-override-dired-mode))

;; Ivy tool set
(use-package ivy
  :straight t
  :ensure t
  :diminish ivy-mode
  :hook
  ((after-init . ivy-mode)
   (after-init . counsel-mode))
  :config
  (define-key global-map (kbd "C-x b") 'ivy-switch-buffer)
  (define-key global-map (kbd "C-c v") 'ivy-push-view)
  (define-key global-map (kbd "C-c V") 'ivy-pop-view)
  (setq ivy-initial-inputs-alist nil)         ;; Don't start searches with ^
  :custom
  (ivy-use-virtual-buffers t)
  (enable-recursive-minibuffers t)
  (ivy-count-format "(%d/%d) "))

(use-package counsel
  :straight t
  :ensure t
  :config
  (define-key global-map (kbd "M-x") 'counsel-M-x)
  (define-key global-map (kbd "C-x C-f") 'counsel-find-file)
  (define-key global-map (kbd "M-y") 'counsel-yank-pop)
  (define-key global-map (kbd "<f1> f") 'counsel-describe-function)
  (define-key global-map (kbd "<f1> v") 'counsel-describe-variable)
  (define-key global-map (kbd "<f1> l") 'counsel-find-library)
  (define-key global-map (kbd "<f2> i") 'counsel-info-lookup-symbol)
  (define-key global-map (kbd "<f2> u") 'counsel-unicode-char)
  (define-key global-map (kbd "<f2> j") 'counsel-set-variable))

(use-package swiper
  :straight t
  :ensure t
  :config (define-key global-map (kbd "C-s") 'swiper-isearch))

(use-package ivy-rich
  :straight t
  :ensure t
  :hook (ivy-mode . ivy-rich-mode)
  :config
  (setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line))

(use-package workgroups2
  :straight t
  :ensure t)

(use-package workroom
  :straight t
  :ensure t)

(use-package projectile
  :straight t
  :ensure t
  :bind (("C-c p" . projectile-command-map))
  :config
  (projectile-mode +1)
  (setq projectile-mode-line "Projectile")
  (setq projectile-completion-system 'ivy)
  (setq projectile-track-known-projects-automatically nil))

(use-package counsel-projectile
  :straight t
  :ensure t
  :after projectile
  :config (counsel-projectile-mode))

(use-package treemacs
  :straight t
  :ensure t
  :defer t
  :config
  ;; (treemacs-tag-follow-mode)
  (treemacs-project-follow-mode)
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ;; ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag))
  (:map treemacs-mode-map
	("/" . treemacs-advanced-helpful-hydra)))

(use-package treemacs-projectile
  :straight t
  :ensure t
  :after (treemacs projectile))

(use-package treemacs-icons-dired
  :straight t
  :ensure t
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
  :straight t
  :after (treemacs)
  :ensure t
  :config (treemacs-set-scope-type 'Tabs))

(use-package imenu-list
  :straight t
  :ensure t
  :bind
  ("<f9>" . imenu-list-smart-toggle)
  :custom-face
  (imenu-list-entry-face-1 ((t (:foreground "black"))))
  :custom
  (imenu-list-focus-after-activation nil)
  (imenu-list-auto-resize t))

(use-package minimap
  :straight t
  :ensure t
  :custom
  (minimap-major-modes '(prog-mode))
  (minimap-window-location 'right)
  (minimap-update-delay 0.2)
  (minimap-minimum-width 20)
  :config
  (global-set-key (kbd "<f5>") 'minimap-create)
  (global-set-key (kbd "<f6>") 'minimap-kill)
  (custom-set-faces
   '(minimap-active-region-background
     ((((background dark)) (:background "#555555555555"))
      (t (:background "#C847D8FEFFFF"))) :group 'minimap)))

;; multiple-cursors
(use-package multiple-cursors
  :straight t
  :ensure t
  :after hydra
  :bind
  (("C-x C-h m" . hydra-multiple-cursors/body)
   ("C-S-<mouse-1>" . mc/toggle-cursor-on-click))
  :hydra (hydra-multiple-cursors
		  (:hint nil)
		  "
Up^^             Down^^           Miscellaneous           % 2(mc/num-cursors) cursor%s(if (> (mc/num-cursors) 1) \"s\" \"\")
------------------------------------------------------------------
 [_p_]   Prev     [_n_]   Next     [_l_] Edit lines  [_0_] Insert numbers
 [_P_]   Skip     [_N_]   Skip     [_a_] Mark all    [_A_] Insert letters
 [_M-p_] Unmark   [_M-n_] Unmark   [_s_] Search      [_q_] Quit
 [_|_] Align with input CHAR       [Click] Cursor at point"
		  ("l" mc/edit-lines :exit t)
		  ("a" mc/mark-all-like-this :exit t)
		  ("n" mc/mark-next-like-this)
		  ("N" mc/skip-to-next-like-this)
		  ("M-n" mc/unmark-next-like-this)
		  ("p" mc/mark-previous-like-this)
		  ("P" mc/skip-to-previous-like-this)
		  ("M-p" mc/unmark-previous-like-this)
		  ("|" mc/vertical-align)
		  ("s" mc/mark-all-in-region-regexp :exit t)
		  ("0" mc/insert-numbers :exit t)
		  ("A" mc/insert-letters :exit t)
		  ("<mouse-1>" mc/add-cursor-on-click)
		  ;; Help with click recognition in this hydra
		  ("<down-mouse-1>" ignore)
		  ("<drag-mouse-1>" ignore)
		  ("q" nil)))

;; Dashboard
(use-package dashboard
  :straight t
  :ensure t
  :config
  (setq dashboard-banner-logo-title "Yuzuki.Cat") ;; 个性签名，随读者喜好设置
  (setq dashboard-projects-backend 'projectile) ;; 读者可以暂时注释掉这一行，等安装了 projectile 后再使用
  (setq dashboard-startup-banner 'nil) ;; 也可以自定义图片
  (setq dashboard-items '((recents  . 0)   ;; 显示多少个最近文件
        		  (bookmarks . 0)  ;; 显示多少个最近书签
        		  (projects . 10))) ;; 显示多少个最近项目
  (dashboard-setup-startup-hook))

(use-package revert-buffer-all
  :straight t
  :ensure t)

(use-package loc-changes
  :straight t
  :ensure t)

(use-package smartparens
  :straight t
  :ensure t
  :config
  (require 'smartparens-config)
  ;; Always start smartparens mode in js-mode.
  (add-hook 'js-mode-hook #'smartparens-mode))

;; Zoxide find file
(use-package zoxide
  :straight t
  :ensure t
  :hook ((find-file
          counsel-find-file) . zoxide-add))

(use-package fzf
  :straight t
  :ensure t
  :bind (("C-c f" . fzf-directory)
         ("C-c s" . fzf-grep)
         ("C-c S-f" . fzf-git)
         ("C-c S-s" . fzf-git-grep)))

;; Regex replace
(use-package anzu
  :straight t
  :ensure t
  :bind ("C-r" . anzu-query-replace-regexp))

(use-package git-gutter
  :straight t
  :ensure t

  :custom
  (git-gutter:modified-sign "~")
  (git-gutter:added-sign    "+")
  (git-gutter:deleted-sign  "-")
  :custom-face
  (git-gutter:modified ((t (:background "#f1fa8c"))))
  (git-gutter:added    ((t (:background "#50fa7b"))))
  (git-gutter:deleted  ((t (:background "#ff79c6"))))
  :config
  (global-git-gutter-mode +1))

;; Undo tree
(use-package undo-tree
  :straight t
  :ensure t
  :delight
  :diminish undo-tree-mode
  :init (global-undo-tree-mode)
  :after hydra
  :bind ("C-x C-h u" . hydra-undo-tree/body)
  :hydra (hydra-undo-tree (:hint nil)
  "
  _p_: undo  _n_: redo _s_: save _l_: load   "
  ("p"   undo-tree-undo)
  ("n"   undo-tree-redo)
  ("s"   undo-tree-save-history)
  ("l"   undo-tree-load-history)
  ("u"   undo-tree-visualize "visualize" :color blue)
  ("q"   nil "quit" :color blue))
  :config
  (setq undo-tree-visualizer-timestamps t
        undo-tree-visualizer-diff t
        undo-tree-auto-save-history nil))

(use-package magit
  :straight t
  :ensure t
  :bind ("C-x g g" . magit-status)
  ("C-x g b" . magit-blame)
  ("C-x g d" . magit-diff-buffer-file))

;; Spell check and auto fill
(use-package flycheck
  :straight t
  :ensure t
  :config
  (setq truncate-lines nil) ;; 如果单行信息很长会自动换行
  :hook
  (prog-mode . flycheck-mode))

;; mwim
(use-package mwim
  :straight t
  :ensure t
  :config
  :bind
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line))

(use-package hl-todo
  :straight t
  :ensure t
  :hook (prog-mode . hl-todo-mode)
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold)
          ("DEBUG"      error bold))))

;; Rainbow
(use-package rainbow-mode
  :straight t
  :ensure t
  :config
  (progn
    (defun @-enable-rainbow ()
      (rainbow-mode t))
    (add-hook 'prog-mode-hook '@-enable-rainbow)))

(use-package rainbow-delimiters
  :straight t
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode)
  :config
  (progn
    (defun @-enable-rainbow-delimiters ()
      (rainbow-delimiters-mode t))
    (add-hook 'prog-mode-hook '@-enable-rainbow-delimiters)))

;; 自动清除 whitespace
(use-package ws-butler
  :straight t
  :ensure t
  :hook ((text-mode . ws-butler-mode)
	 (prog-mode . ws-butler-mode)))

(use-package popup
  :straight t
  :ensure t)

(use-package clippy
  :straight t
  :ensure t
  :config
  (setq clippy-tip-show-function #'clippy-popup-tip-show))

;; Parentheses and highlight TODO
(add-hook 'prog-mode-hook #'show-paren-mode) ;; 编程模式下，光标在括号上时高亮另一个括号
(setq show-paren-style 'parenthesis)

;; Language modes
(use-package cargo-mode
  :straight t
  :ensure t
  :config
  (add-hook 'rust-mode-hook 'cargo-minor-mode))

(use-package csv-mode
  :straight t
  :ensure t)

(use-package dockerfile-mode
  :straight t
  :ensure t)

(use-package docker-compose-mode
  :straight t
  :ensure t)

(use-package dotenv-mode
  :straight t
  :ensure t
  :config(require 'dotenv-mode) ; unless installed from a package
  (add-to-list 'auto-mode-alist '("\\.env\\..*\\'" . dotenv-mode)) ;; for optionally supporting additional file extensions such as `.env.test' with this major mode
  ) ; unless installed from a package
(add-to-list 'auto-mode-alist '("\\.env\\..*\\'" . dotenv-mode)) ;; for optionally supporting additional file extensions such as `.env.test' with this major mode

(use-package elixir-mode
  :straight t
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.elixir2\\'" . elixir-mode))
  ;; Create a buffer-local hook to run elixir-format on save, only when we enable elixir-mode.
  (add-hook 'elixir-mode-hook
            (lambda () (add-hook 'before-save-hook 'elixir-format nil t)))
  (add-hook 'elixir-format-hook (lambda ()
                                  (if (projectile-project-p)
                                      (setq elixir-format-arguments
                                            (list "--dot-formatter"
                                                  (concat (locate-dominating-file buffer-file-name ".formatter.exs") ".formatter.exs")))
                                    (setq elixir-format-arguments nil)))))

(use-package elixir-ts-mode
  :straight t
  :ensure t)
(use-package elm-mode
  :straight t
  :ensure t)

(add-hook 'go-mode-hook 'lsp-bridge)

(use-package go-mode
  :straight t
  :ensure t
  :config
  (setenv "PATH" (concat (getenv "PATH") ":/etc/profiles/per-user/yuzuki/bin/go"))
  (autoload 'go-mode "go-mode" nil t)
  (add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode)))

(use-package flymake-go-staticcheck
  :straight t
  :ensure t
  :config
  (add-hook 'go-mode-hook #'flymake-go-staticcheck-enable)
  (add-hook 'go-mode-hook #'flymake-mode))

(use-package graphql-mode
  :straight t
  :ensure t)

(use-package js2-mode
  :straight t
  :ensure t)

(use-package json-mode
  :straight t
  :ensure t
  )

(use-package kotlin-mode
  :straight t
  :ensure t)

(use-package kotlin-ts-mode
  :straight t
  :ensure t)

(use-package lua-mode
  :straight t
  :ensure t)

(use-package markdown-mode
  :straight t
  :ensure t
  :hook (markdown-mode . (lambda ()
			   (dolist (face '((markdown-header-face-1 . 1.2)
			                   (markdown-header-face-2 . 1.1)
					   (markdown-header-face-3 . 1.0)))
			     (set-face-attribute (car face) nil :weight 'normal :height (cdr face)))))
  :config
  (setq markdown-command "multimarkdown"))

(use-package markdown-preview-mode
  :straight t
  :ensure t)

(use-package mermaid-mode
  :straight t
  :ensure t)

(use-package verb
  :straight t
  :ensure t)

(use-package org-inline-anim
  :straight t
  :ensure t
  :after org
  :config
  (add-hook 'org-mode-hook #'org-inline-anim-mode))

(use-package org-modern
  :straight t
  :ensure t
  :after org
  :config
  (add-hook 'org-mode-hook #'org-modern-mode)
  (add-hook 'org-agenda-finalize-hook #'org-modern-agenda)
  (setq
   ;; Edit settings
   org-auto-align-tags nil
   org-tags-column 0
   org-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t

   ;; Org styling, hide markup etc.
   org-hide-emphasis-markers t
   org-pretty-entities t
   org-ellipsis "…"

   ;; Agenda styling
   org-agenda-tags-column 0))
(setq safe-local-variable-values
   (quote
    ((buffer-read-only . 1))))

(use-package khalel
  :straight t
  :ensure t
  :after org
  :config
  (setq khalel-khal-command "/home/yuzuki/.local/bin/khal")
  (setq khalel-vdirsyncer-command "/home/yuzuki/.local/bin/vdirsyncer")
  (setq khalel-import-org-file (concat org-directory "/" "calendar.org"))
  (setq khalel-import-org-file-confirm-overwrite nil)
  (setq khalel-import-start-date "-365d")
  (setq khalel-import-end-date "+90d")
  (khalel-add-capture-template))

(use-package org-habit-stats
  :straight t
  :ensure t
  :after org)

(use-package org-tidy
  :straight t
  :ensure t
  :after (org)
  :ensure t
  :config
  (add-hook 'org-mode-hook #'org-tidy-mode))

(use-package org-ref
  :straight t
  :ensure t
  :after (org)
  :config
  (define-key org-mode-map (kbd "C-c ]") 'org-ref-insert-link))

(use-package ivy-bibtex
  :straight t
  :ensure t
  :after (org))

(use-package citar
  :straight t
  :ensure t
  :no-require
  :custom
  (org-cite-global-bibliography '("/home/yuzuki/bib/references.bib"))
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (citar-bibliography org-cite-global-bibliography)
  ;; optional: org-cite-insert is also bound to C-c C-x C-@
  :bind
  (:map org-mode-map :package org ("C-c b" . #'org-cite-insert)))

(use-package embark
  :straight t
  :ensure t)

(use-package citar-embark
  :straight t
  :ensure t
  :after citar embark
  :no-require
  :config (citar-embark-mode))

(use-package org-roam
  :straight t
  :ensure t
  :after org
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/org"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  ;; (require 'org-roam-protocol)
  )

(use-package org-roam-bibtex
  :straight t
  :ensure t
  :after org-roam org-ref) ; optional: if using Org-ref v2 or v3 citation links

(use-package org-ivy-search
  :straight t
  :ensure t
  :config
  (setq org-agenda-files '("~/workspace/org/"))
  (global-set-key (kbd "C-c o") #'org-ivy-search-vie))

(use-package org-recur
  :straight t
  :ensure t
  :after org
  :hook ((org-mode . org-recur-mode)
         (org-agenda-mode . org-recur-agenda-mode))
  :demand t
  :config
  (define-key org-recur-mode-map (kbd "C-c d") 'org-recur-finish)
  ;; Rebind the 'd' key in org-agenda (default: `org-agenda-day-view').
  (define-key org-recur-agenda-mode-map (kbd "d") 'org-recur-finish)
  (define-key org-recur-agenda-mode-map (kbd "C-c d") 'org-recur-finish)
  (setq org-recur-finish-done t
        org-recur-finish-archive t))
(defun get-auth-info (host user)
  (let ((info (nth 0 (auth-source-search
                      :host host
                      :user user
                      :require '(:secret)
                      :create t))))
    (if info
        (let ((secret (plist-get info :secret)))
          (if (functionp secret)
              (funcall secret)
            secret))
      nil)))

(use-package org-ai
  :straight t
  :ensure t
  :ensure t
  :commands (org-ai-mode
             org-ai-global-mode)
  :init
  (add-hook 'org-mode-hook #'org-ai-mode) ; enable org-ai in org-mode
  (org-ai-global-mode) ; installs global keybindings on C-c M-a
  :config
  (setq org-ai-openai-api-token "sk-YOUR_OPENAI_API_KEY")
  (setq org-ai-default-chat-model "gpt-4") ; if you are on the gpt-4 beta:
  (org-ai-install-yasnippets)) ; if you are using yasnippet and want `ai` snippets

(use-package org-mime
  :straight t
  :ensure t
  :after (org)
  :config
  (add-hook 'message-send-hook 'org-mime-confirm-when-no-multipart)
  (add-hook 'message-mode-hook
            (lambda ()
              (local-set-key (kbd "C-c M-o") 'org-mime-htmlize)))
  (add-hook 'org-mode-hook
            (lambda ()
              (local-set-key (kbd "C-c M-o") 'org-mime-org-buffer-htmlize)))
  ;; the following can be used to nicely offset block quotes in email bodies
  (add-hook 'org-mime-html-hook
            (lambda ()
              (org-mime-change-element-style
               "blockquote" "border-left: 2px solid gray; padding-left: 4px;")))
  (setq org-mime-export-options '(:with-latex dvipng
                                :section-numbers nil
                                :with-author nil
                                :with-toc nil))
  (add-hook 'org-mime-plain-text-hook
          (lambda ()
            (while (re-search-forward "\\\\" nil t)
              (replace-match "")))))

(use-package apel
  :straight t)
(use-package flim
  :straight t)
(use-package semi
  :straight t)

(use-package wanderlust
  :straight t
  :ensure t)

;; autoload configuration
(autoload 'wl "wl" "Wanderlust" t)
(autoload 'wl-other-frame "wl" "Wanderlust on new frame." t)
(autoload 'wl-draft "wl-draft" "Write draft with Wanderlust." t)

;; For non ascii-characters in folder-names
(setq elmo-imap4-use-modified-utf7 t)

(setq elmo-imap4-default-server "imap.gmail.com"
      elmo-imap4-default-user "dawei.jiang@nowhere.co.jp"
      elmo-imap4-default-authenticate-type 'xoauth2
      elmo-imap4-default-port '993
      elmo-imap4-default-stream-type 'ssl)

(setq wl-smtp-connection-type 'starttls
      wl-smtp-posting-port 587
      wl-smtp-authenticate-type "xoauth2"
      wl-smtp-posting-user "dawei.jiang@nowhere.co.jp"
      wl-smtp-posting-server "smtp.gmail.com"
      wl-local-domain "gmail.com"
      wl-message-id-domain "smtp.gmail.com")
(setq elmo-localdir-folder-path "~/Maildir")
(setq wl-summary-incorporate-marks '("N" "U" "!" "A" "F" "$"))
(defun wl-summary-overview-entity-compare-by-rdate (x y)
  (not (wl-summary-overview-entity-compare-by-date x y)))

(defun wl-summary-sort-by-rdate ()
  (interactive)
  (wl-summary-rescan "rdate")
  (goto-char (point-min)))

(defadvice wl-summary-rescan (after wl-summary-rescan-move-cursor activate)
  (if (string-match "^r" (ad-get-arg 0))
      (goto-char (point-min))))

;; sort the summary
(defun my-wl-summary-sort-hook ()
  (wl-summary-rescan "rdate"))

(add-hook 'wl-summary-prepared-hook 'my-wl-summary-sort-hook)

(add-hook
 'mime-view-mode-hook
 '(lambda ()
    "Disable 'v' for mime-play."
    ;; Key bindings
    (local-set-key [?v] () )
    ))

(remove-hook 'wl-message-redisplay-hook 'bbdb-wl-get-update-record)

(setq
 ;; All system folders (draft, trash, spam, etc) are placed in the
 ;; [Gmail]-folder, except inbox. "%" means it's an IMAP-folder
 wl-default-folder "%inbox"
 wl-draft-folder   "%[Gmail]/Drafts"
 wl-trash-folder   "%[Gmail]/Trash"
 wl-spam-folder    "%[Gmail]/Spam"
 wl-sent-folder    "%[Gmail]/Sent"

 ;; The below is not necessary when you send mail through Gmail's SMTP server,
 ;; see https://support.google.com/mail/answer/78892?hl=en&rd=1
 ;; wl-fcc            "%[Gmail]/Sent"

 wl-from "Yuzuki <dawei.jiang@nowhere.co.jp>"  ; Our From: header field
 wl-fcc-force-as-read t           ; Mark sent mail (in the wl-fcc folder) as read
 wl-default-spec "%")             ; For auto-completion

(setq elmo-search-default-engine 'mu)

;; ignore  all fields
(setq wl-message-ignored-field-list '("^.*:"))

;; ..but these five
(setq wl-message-visible-field-list
'("^To:"
  "^Cc:"
  "^From:"
  "^Subject:"
  "^Date:"))

(if (boundp 'mail-user-agent)
    (setq mail-user-agent 'wl-user-agent))
(if (fboundp 'define-mail-user-agent)
    (define-mail-user-agent
      'wl-user-agent
      'wl-user-agent-compose
      'wl-draft-send
      'wl-draft-kill
      'mail-send-hook))

;; Use ~/.mailrc
(defun my-wl-address-init ()
  (wl-local-address-init)
  (setq wl-address-completion-list
        (append wl-address-completion-list (build-mail-aliases))))
(setq wl-address-init-function 'my-wl-address-init)

;;Only save draft when I tell it to (C-x C-s or C-c C-s):
(setq wl-auto-save-drafts-interval nil)

(setq mime-edit-split-message nil)

;;Cobbled together from posts by Erik Hetzner & Harald Judt to
;; wl-en@lists.airs.net by Jonathan Groll (msg 4128)
(defun mime-edit-insert-multiple-files ()
  "Insert MIME parts from multiple files."
  (interactive)
  (let ((dir default-directory))
    (let ((next-file (expand-file-name
                      (read-file-name "Insert file as MIME message: "
		      dir))))
      (setq file-list (file-expand-wildcards next-file))
      (while (car file-list)
        (mime-edit-insert-file (car file-list))
        (setq file-list (cdr file-list))))))
(global-set-key "\C-c\C-x\C-a" 'mime-edit-insert-multiple-files)

;; (setq wl-draft-send-mail-function 'wl-draft-send-mail-with-sendmail)
(setq plstore-cache-passphrase-for-symmetric-encryption t)
(setq mime-header-accept-quoted-encoded-words t)
(setq wl-stay-folder-window t)

(defun dmj/wl-send-html-message ()
  "Send message as html message.
  Convert body of message to html using
  `org-export-region-as-html'."
  (require 'org)
  (save-excursion
    (let (beg end html text)
      (goto-char (point-min))
      (re-search-forward "^--text follows this line--$")
      ;; move to beginning of next line
      (beginning-of-line 2)
      (setq beg (point))
      (if (not (re-search-forward "^--\\[\\[" nil t))
          (setq end (point-max))
        ;; line up
        (end-of-line 0)
        (setq end (point)))
      ;; grab body
      (setq text (buffer-substring-no-properties beg end))
      ;; convert to html
      (with-temp-buffer
        (org-mode)
        (insert text)
        ;; handle signature
        (when (re-search-backward "^-- \n" nil t)
          ;; preserve link breaks in signature
          (insert "\n#+BEGIN_VERSE\n")
          (goto-char (point-max))
          (insert "\n#+END_VERSE\n")
          ;; grab html
          (setq html (org-export-region-as-html
                      (point-min) (point-max) t 'string))))
      (delete-region beg end)
      (insert
       (concat
	"--" "<<alternative>>-{\n"
	"--" "[[text/plain]]\n" text
        "--" "[[text/html]]\n"  html
	"--" "}-<<alternative>>\n")))))

(defun dmj/wl-send-html-message-toggle ()
  "Toggle sending of html message."
  (interactive)
  (setq dmj/wl-send-html-message-toggled-p
        (if dmj/wl-send-html-message-toggled-p
            nil "HTML"))
  (message "Sending html message toggled %s"
           (if dmj/wl-send-html-message-toggled-p
               "on" "off")))

(defun dmj/wl-send-html-message-draft-init ()
  "Create buffer local settings for maybe sending html message."
  (unless (boundp 'dmj/wl-send-html-message-toggled-p)
    (setq dmj/wl-send-html-message-toggled-p nil))
  (make-variable-buffer-local 'dmj/wl-send-html-message-toggled-p)
  (add-to-list 'global-mode-string
               '(:eval (if (eq major-mode 'wl-draft-mode)
                           dmj/wl-send-html-message-toggled-p))))

(defun dmj/wl-send-html-message-maybe ()
  "Maybe send this message as html message.

If buffer local variable `dmj/wl-send-html-message-toggled-p' is
non-nil, add `dmj/wl-send-html-message' to
`mime-edit-translate-hook'."
  (if dmj/wl-send-html-message-toggled-p
      (add-hook 'mime-edit-translate-hook 'dmj/wl-send-html-message)
    (remove-hook 'mime-edit-translate-hook 'dmj/wl-send-html-message)))

(add-hook 'wl-draft-reedit-hook 'dmj/wl-send-html-message-draft-init)
(add-hook 'wl-mail-setup-hook 'dmj/wl-send-html-message-draft-init)
(add-hook 'wl-draft-send-hook 'dmj/wl-send-html-message-maybe)

(setq dmj/wl-send-html-message-toggled-p t)

;; Shut up, I just want to save the thing.
(defun mime-preview-extract-current-entity (&optional ignore-examples)
  "Extract current entity into file (maybe).
It decodes current entity to call internal or external method as
\"extract\" mode.  The method is selected from variable
`mime-acting-condition'."
  (interactive "P")
  (cl-letf (((symbol-function #'mime-play-entity)
             (lambda (entity &optional situation ignored-method)
               (mime-save-content entity situation))))
    (mime-preview-play-current-entity ignore-examples "extract")))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(smtpmail-smtp-server "smtp.gmail.com")
 '(smtpmail-smtp-service 25))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(minimap-active-region-background ((((background dark)) (:background "#555555555555")) (t (:background "#C847D8FEFFFF"))) nil 'minimap))

(use-package org-ql
  :straight t
  :ensure t
  :after (org))

(use-package orgtbl-aggregate
  :straight t
  :ensure t
  :after (org))

(use-package orgtbl-join
  :straight t
  :ensure t
  :after (org)
  :bind ("C-c j" . orgtbl-join)
  :init
  (easy-menu-add-item
   org-tbl-menu '("Column")
   ["Join with another table" orgtbl-join (org-at-table-p)]))

(use-package orgtbl-fit
  :straight t
  :ensure t
  :after (org))

(use-package osm
  :straight t
  :ensure t
  :bind ("C-c m" . osm-prefix-map) ;; Alternative: `osm-home'
  :custom
  (osm-server 'default) ;; Configure the tile server
  (osm-copyright t)     ;; Display the copyright information
  :init
  ;; Load Org link support
  (with-eval-after-load 'org
    (require 'osm-ol)))

(use-package ox-qmd
  :straight t
  :ensure t
  :after (org))

(use-package pandoc-mode
  :straight t
  :ensure t)

(use-package ox-pandoc
  :straight t
  :ensure t)

(use-package ox-spectacle
  :straight t
  :ensure t)
(use-package nix-mode
  :straight t
  :ensure t
  :mode "\\.nix\\'")

(use-package pnpm-mode
  :straight t
  :ensure t)

(use-package poetry
  :straight t
  :ensure t)

(use-package prisma-mode
  :straight t
  :ensure t)
;; (use-package protobuf-mode)
;; (use-package protobuf-ts-mode)

(use-package exec-path-from-shell
  :straight t
  :ensure t
  :if (memq (window-system) '(mac ns))
  :config (exec-path-from-shell-initialize))

(use-package python-mode
  :straight t
  :ensure t)

(use-package python-x
  :straight t
  :ensure t
  :mode "\\.py\\'")

(use-package lsp-jedi
  :straight t
  :ensure t
  :after lsp)

(use-package lsp-pyright
  :straight t
  :ensure t
  :after lsp)

(use-package python-pytest
  :straight t
  :ensure t)

(use-package python-black
  :straight t
  :ensure t)

(use-package python-isort
  :straight t
  :ensure t)

;; (use-package pet
;;   :ensure-system-package (dasel sqlite3)
;;   :config
;;   (add-hook 'python-mode-hook
;;             (lambda ()
;;               (setq-local python-shell-interpreter (pet-executable-find "python")
;;                           python-shell-virtualenv-root (pet-virtualenv-root))
;;               (pet-flycheck-setup)
;;               (flycheck-mode 1)
;;               (setq-local lsp-jedi-executable-command
;;                           (pet-executable-find "jedi-language-server"))

;;               (setq-local lsp-pyright-python-executable-cmd python-shell-interpreter
;;                           lsp-pyright-venv-path python-shell-virtualenv-root)

;;               (lsp)

;;               (setq-local python-pytest-executable (pet-executable-find "pytest"))

;;               (when-let ((black-executable (pet-executable-find "black")))
;;                 (setq-local python-black-command black-executable)
;;                 (python-black-on-save-mode 1))

;;               (when-let ((isort-executable (pet-executable-find "isort")))
;;                 (setq-local python-isort-command isort-executable)
;;                 (python-isort-on-save-mode 1)))))

(use-package python-docstring
  :straight t
  :ensure t)

(use-package numpydoc
  :straight t
  :ensure t
  :bind (:map python-mode-map
              ("C-c C-n" . numpydoc-generate)))

(use-package pyinspect
  :straight t
  :ensure t
  :config
  (define-key python-mode-map (kbd "C-c i") #'pyinspect-inspect-at-point))

(use-package python-cell
  :straight t
  :ensure t
  :config
  (add-hook 'python-mode-hook #'python-cell-mode 1))

(use-package rjsx-mode
  :straight t
  :ensure t)

(use-package rust-mode
  :straight t
  :ensure t
  :config
  (autoload 'rust-mode "rust-mode" nil t)
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
  (add-hook 'rust-mode-hook
            (lambda () (setq indent-tabs-mode nil)))
  (setq rust-format-on-save t)
  (add-hook 'rust-mode-hook
          (lambda () (prettify-symbols-mode))))

(use-package lsp-mssql
  :straight t
  :ensure t
  :config
  (add-hook 'sql-mode-hook 'lsp))

(use-package syntactic-close
  :straight t
  :ensure t)

(use-package lsp-tailwindcss
  :straight t
  :ensure t
  :init
  (setq lsp-tailwindcss-add-on-mode t))

(use-package typescript-mode
  :straight t
  :ensure t
  :config(require 'ansi-color)
  (defun colorize-compilation-buffer ()
    (ansi-color-apply-on-region compilation-filter-start (point-max)))
  (add-hook 'compilation-filter-hook 'colorize-compilation-buffer))

;; if you use treesitter based typescript-ts-mode (emacs 29+)
(use-package tide
  :straight t
  :ensure t
  :after (flycheck)
  :hook ((typescript-ts-mode . tide-setup)
         (tsx-ts-mode . tide-setup)
         (typescript-ts-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save)))

(use-package web-mode
  :straight t
  :ensure t)

(use-package x509-mode
  :straight t
  :ensure t)

(use-package yaml-mode
  :straight t
  :ensure t)

(use-package yaml-pro
  :straight t
  :ensure t
  :config
  (add-hook 'yaml-mode-hook #'yaml-pro-mode))

(use-package pcsv
  :straight t
  :ensure t)

;; PDF
(use-package pdf-tools
  :straight t
  :ensure t
  :config
  (pdf-tools-install)
  ;; Pdf and swiper does not work together
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward-regexp))

(use-package ascii-table
  :straight t
  :ensure t)

(use-package cargo
  :straight t
  :ensure t)

(use-package eldoc
  :straight t
  :ensure t)

(use-package isearch-mb
  :straight t
  :ensure t)

(use-package rg
  :straight t
  :ensure t
  :config
  (rg-enable-default-bindings))

(use-package olivetti
  :straight t
  :ensure t)

(use-package qrencode
  :straight t
  :ensure t)

(use-package request
  :straight t
  :ensure t)

(use-package slime
  :straight t
  :ensure t)

(use-package citre
  :straight t
  :ensure t
  :defer t
  :init
  ;; This is needed in `:init' block for lazy load to work.
  (require 'citre-config)
  ;; Bind your frequently used commands.  Alternatively, you can define them
  ;; in `citre-mode-map' so you can only use them when `citre-mode' is enabled.
  (global-set-key (kbd "C-x c j") 'citre-jump)
  (global-set-key (kbd "C-x c J") 'citre-jump-back)
  (global-set-key (kbd "C-x c p") 'citre-ace-peek)
  (global-set-key (kbd "C-x c u") 'citre-update-this-tags-file)
  :config
  (setq citre-project-root-function #'projectile-project-root
        citre-use-project-root-when-creating-tags t
        citre-prompt-language-for-ctags-command t
        citre-auto-enable-citre-mode-modes '(prog-mode)))

(use-package format-all
  :straight t
  :ensure t
  :hook
  (prog-mode . format-all-mode)
  :custom
  (format-all-show-errors 'warnings))

(use-package symbol-overlay
  :straight t
  :ensure t
  :config
  (global-set-key (kbd "M-i") 'symbol-overlay-put)
  (global-set-key (kbd "M-n") 'symbol-overlay-switch-forward)
  (global-set-key (kbd "M-p") 'symbol-overlay-switch-backward)
  (global-set-key (kbd "<f7>") 'symbol-overlay-mode)
  (global-set-key (kbd "<f8>") 'symbol-overlay-remove-all))

(use-package wrap-region
  :straight t
  :ensure t
  :init
  (wrap-region-mode t))

(use-package yasnippet
  :straight t
  :ensure t
  :hook
  (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all)
  ;; unbind <TAB> completion
  (define-key yas-minor-mode-map [(tab)]        nil)
  (define-key yas-minor-mode-map (kbd "TAB")    nil)
  (define-key yas-minor-mode-map (kbd "<tab>")  nil)
  :bind
  (:map yas-minor-mode-map ("S-<tab>" . yas-expand)))

(use-package yasnippet-snippets
  :straight t
  :ensure t
  :after yasnippet)
