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

(use-package all-the-icons
  :straight (all-the-icons :type git :host github :repo "domtronn/all-the-icons.el")
  :if (display-graphic-p)
)

(use-package transient
  :straight t
  :ensure t
  )

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
  :ensure t
  )

;; hydra
(use-package hydra
  :straight t
  :ensure t
  )

(use-package use-package-hydra
  :straight t
  :after hydra
  :ensure t)

;; Theme
(use-package color-identifiers-mode
  :straight t
  :ensure t
  :init
  (global-color-identifiers-mode)
  )

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
    (set-face-attribute 'mode-line-inactive nil :background "#f9f2d9"))
  )

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
  :ensure t
  )

(use-package catppuccin-theme
  :straight t
  :ensure t
  :config
  (setq catppuccin-flavor 'latte) ;; or 'latte, 'macchiato, or 'mocha
  (catppuccin-reload)
  )

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
  (define-key global-map (kbd "<f2> j") 'counsel-set-variable)
)

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
  :ensure t
  )

(use-package workroom
  :straight t
  :ensure t
  )

(use-package projectile
  :straight t
  :ensure t
  :bind (("C-c p" . projectile-command-map))
  :config
  (projectile-mode +1)
  (setq projectile-mode-line "Projectile")
  (setq projectile-completion-system 'ivy)
  (setq projectile-track-known-projects-automatically nil)
  (diminish 'projectile-mode " 📁"))

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
