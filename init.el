;;; init.el -*- lexical-binding: t; -*-

(defconst user-home-directory
  (pcase system-type
    ('windows-nt "%userprofile%")
	(otherwise "~"))
  "User Home directory")

(defconst user-data-directory
  (expand-file-name "var" user-emacs-directory)
  "Where to save the emacs data")

(defconst user-config-directory
  (expand-file-name "etc" user-emacs-directory)
  "Where to save the configurations")

(defconst user-module-directory
  (expand-file-name "opt" user-emacs-directory)
  "Where to save the modules")

;; Create directories if necessary
(dolist (type '("data" "config" "module"))
  (let* ((var-name (intern (concat "user-" type "-directory")))
		 (dir (symbol-value var-name)))
    (unless (file-directory-p dir)
	  (make-directory dir))))

;; Basic settings
(setq
 gc-cons-percentage 1.0
 gc-cons-threshold most-positive-fixnum
 package-enable-at-startup nil
 inhibit-compacting-font-caches t
 
 url-proxy-services '(("http" . "127.0.0.1:7890")
                      ("https" . "127.0.0.1:7890"))

 
 ring-bell-function 'ignore
 make-backup-files nil
 mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil))
 mouse-wheel-progressive-speed nil
 next-line-add-newlines t
 confirm-kill-processes nil
 enable-recursive-minibuffers t
 frame-inhibit-implied-resize t
 ad-redefinition-action 'accept
 )

(let ((old-file-name-handler-alist file-name-handler-alist))
  ;; https://emacs.nasy.moe/#%E5%88%9D--early-init-
  (setq-default file-name-handler-alist nil)
  (defun restore--default ()
    "Restore gc setting to default."
    (setq file-name-handler-alist
          (delete-dups (append file-name-handler-alist
                               old-file-name-handler-alist))
          inhibit-trace nil))
  (add-hook 'emacs-startup-hook #'restore--default))

;; ;; packages list
(defconst package-list
  '(("no-littering" . "https://github.com/emacscollective/no-littering")
    ("compat" . "https://github.com/emacsmirror/compat")

    ("modalka" . "https://github.com/mrkkrp/modalka")
    
    ("dash" . "https://github.com/magnars/dash.el")
    ("s" . "https://github.com/magnars/s.el")
    ("f" . "https://github.com/rejeep/f.el")
    
    ("all-the-icons" . "https://github.com/domtronn/all-the-icons.el")
    ("all-the-icons-completion" . "https://github.com/iyefrat/all-the-icons-completion")
    ("kind-all-the-icons" . "https://github.com/Hirozy/kind-all-the-icons")
    
    ("esup" . "https://github.com/jschaf/esup")

    ("circadian" . "https://github.com/guidoschmidt/circadian.el")
    ("one-themes" . "https://github.com/balajisivaraman/emacs-one-themes")
    ("dracula-theme" . "https://github.com/dracula/emacs")
	
    ("rainbow-delimiters" . "https://github.com/Fanael/rainbow-delimiters")
    ("mwim" . "https://github.com/alezost/mwim.el")
    ("winum" . "https://github.com/deb0ch/emacs-winum")

    ("vertico" . "https://github.com/minad/vertico")
    ("orderless" . "https://github.com/oantolin/orderless")
    ("marginalia" . "https://github.com/minad/marginalia")
    ("embark" . "https://github.com/oantolin/embark")
    ("consult" . "https://github.com/minad/consult")

    ("jsonrpc" . "https://github.com/paritytech/jsonrpc/")
    ("jieba" . "https://github.com/cireu/jieba.el")

    ("dirvish" . "https://github.com/alexluigit/dirvish")

    ("corfu" . "https://github.com/minad/corfu")

    ;; ("emacs-htmlize" . "https://github.com/hniksic/emacs-htmlize")
    
    ("alert" . "https://github.com/jwiegley/alert")
    ("org-modern" . "https://github.com/minad/org-modern")
    ("olivetti" . "https://github.com/rnkn/olivetti")
	
    ;; ("org-blog" . "https://github.com/fingerknight/org-blog")

    ("rime" . "https://github.com/DogLooksGood/emacs-rime")
    ("posframe" . "https://github.com/tumashu/posframe")
    
    ("yaml-mode" . "https://github.com/yoshiki/yaml-mode")
    ("markdown-mode" . "https://github.com/jrblevin/markdown-mode")

    ("emacsql" . "https://github.com/magit/emacsql")
    ("excerpt" . "https://github.com/fingerknight/excerpt.el")

    ("denote" . "https://github.com/protesilaos/denote")

    ("org-pomodoro" . "https://github.com/marcinkoziej/org-pomodoro")

    ("persist" . "https://github.com/emacs-straight/persist")
    ("org-drill" . "https://github.com/louietan/org-drill")

    ("elisp-def" . "https://github.com/Wilfred/elisp-def")

    ("phi-search" . "https://github.com/zk-phi/phi-search")

    ("org-journal" . "https://github.com/bastibe/org-journal")

    ("smartparens" . "https://github.com/Fuco1/smartparens")
    )
  "A list of extra packages")

(dolist (item package-list)
  (let* ((pkg (car item))
         (url (cdr item))
         (dir (expand-file-name pkg user-module-directory)))
    (unless (file-exists-p dir)
      (message "Fetching %s..." pkg)
      (mkdir dir)
      (call-process-shell-command
       (format "git --no-pager clone %s %s"
               url
               dir)
       nil nil)
      (message "Fetched %s." pkg))
    (add-to-list 'load-path dir)))

;; bootstrap `setup.el'
(let ((setup-dir (expand-file-name "setup" user-module-directory)))
  (unless (file-exists-p setup-dir)
    (mkdir setup-dir)
    (with-temp-file (expand-file-name "setup.el" setup-dir)
      (url-insert-file-contents
       "https://git.sr.ht/~pkal/setup/blob/master/setup.el")))
  (add-to-list 'load-path setup-dir))

(require 'setup)

(setup-define :doc
  (lambda (&rest _)
    nil)
  :documentation "Document for the setup package.")

(setup-define :defer
  (lambda (&optional time)
    `(run-with-idle-timer ,(or time 1) nil
                          (lambda () (require ',(setup-get 'feature)))))
  :documentation "Delay loading the feature until a certain amount of idle time has passed.")

(setup-define :hooks
  (lambda (slot func)
    `(add-hook (intern (concat ,(symbol-name slot)
                               "-hook"))
               #',func))
  :documentation "Add pairs of hooks."
  :repeatable t)

(setup-define :load-after
    (lambda (features &rest body)
      (let ((body `(progn
                     (require ',(setup-get 'feature))
                     ,@body)))
        (dolist (feature (if (listp features)
                             (nreverse features)
                           (list features)))
          (setq body `(with-eval-after-load ',feature ,body)))
        body))
  :documentation "Load the current feature after FEATURES."
  :indent 1)

(setup-define :load-path
  (lambda (object)
    (when (or (stringp object) (consp object))
      `(add-to-list 'load-path ,object)))
  :documentation "Update load-path."
  :repeatable t)

(setup-define :custom
  (lambda (var val)
    `(customize-set-variable ',var ,val))
  :documentation "Customize variables."
  :debug '(sexp form)
  ;; :after-loaded t
  :repeatable t)

(setup-define :autoload
  (lambda (func)
    (let ((fn (if (memq (car-safe func)
                        '(quote function))
                  (cadr func)
                func)))
      `(unless (fboundp (quote ,fn))
         (autoload (function ,fn) ,(symbol-name (setup-get 'feature)) nil t))))
  :documentation "Autoload COMMAND if not already bound."
  :repeatable t
  :signature '(FUNC ...))

(setup-define :after
  (lambda (feature &rest body)
    `(with-eval-after-load ',feature
       ,@body))
  :documentation "Eval BODY after FEATURE."
  :indent 1)

(setup-define :modalka
  (lambda (key command)
    `(define-key modalka-mode-map ,key ,command))
  :documentation "Bind KEY to COMMAND on Modalka Map."
  :debug '(form sexp)
  :ensure '(kbd func)
  :repeatable t)

(setup-define :bind-into-after
  (lambda (feature-or-map feature &rest rest)
    (let ((keymap (if (string-match-p "-map\\'"
                                      (symbol-name feature-or-map))
                      feature-or-map
                    (intern (format "%s-map" feature-or-map))))
          (body `(',feature with-eval-after-load)))
      (dotimes (i (/ (length rest) 2))
        (push `(define-key ,keymap
                 (kbd ,(format "%s" (nth (* 2 i) rest)))
                 #',(nth (1+ (* 2 i)) rest))
              body))
      (reverse body)))
  :documentation "Bind into keys into the map of FEATURE-OR-MAP after FEATURE.
The arguments REST are handled as by `:bind'.
The whole is wrapped within a `with-eval-after-load'."
  :debug '(sexp sexp &rest form sexp)
  :ensure '(nil nil &rest kbd func)
  :indent 1)

(setup-define :disabled
 #'setup-quit
 :documentation "Unconditionally abort the evaluation of the current body.")

(setup cl-lib
  (:doc "Common Lisp Library")
  (:require cl-lib))

(setup s
  (:doc "String manipulation library")
  (:require s))

(setup f
  (:doc "Modern APIs for working with files and directories")
  (:require f))

(setup esup
  (:doc "A tool to test the statup time cost")
  (:require esup))

(setup all-the-icons
  (:doc "A collection of various Icon Fonts within Emacs")
  (:require all-the-icons
            all-the-icons-completion
            kind-all-the-icons))

(setup no-littering
  (:doc "Help keeping `~/.config/emacs' clean.")
  (:option no-littering-etc-directory user-config-directory
           no-littering-var-directory user-data-directory)
  (:require no-littering)
  (:option auto-save-file-name-transforms `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))
           custom-file (no-littering-expand-etc-file-name "custom.el")
           ac-comphist-file (no-littering-expand-var-file-name "ac-comphist.dat")
           recentf-save-file (no-littering-expand-var-file-name "recentf"))
  (when (fboundp 'startup-redirect-eln-cache)
    (startup-redirect-eln-cache
     (convert-standard-filename
      (no-littering-expand-var-file-name  "eln-cache/")))))

(setup modalka-mode
  (:doc "A building kit to help switch to modal editing in Emacs.")
  (:require modalka)
  (:hook-into minibuffer-mode)
  (:option modalka-global-mode 1)
  (:global "RET" newline-and-indent)
  (:bind-into messages-buffer-mode-map "q" quit-window)
  ;;  Help
  (:modalka "C-p k" describe-key
            "C-p f" describe-function
            "C-p v" describe-variable
            "C-p t" help-with-tutorial
            "C-p m" describe-mode)
  ;; cursor's movement
  (:modalka "C-h" backward-char
            "C-j" next-line
            "C-k" previous-line
            "C-l" forward-char)
  ;; cut and copy
  (:modalka "C-w" kill-ring-save
            "M-w" kill-region)
  ;; mark (temporary)
  (:modalka "C-v C-v" set-mark-command
            "C-v C-h" mark-whole-buffer)
  ;; screen page
  (:modalka "M-r" scroll-up-command
            "M-e" scroll-down-command)
  ;; undo/redo
  (:modalka "C-z" undo
            "M-z" undo-redo)
  ;; adjust screen
  (:modalka "C-t" recenter-top-bottom
            "M-t" move-to-window-line-top-bottom)
  ;; comment
  (:modalka "C-q" comment-line
            "M-t" move-to-window-line-top-bottom)
  ;; save file
  (:modalka "C-s" save-buffer)
  ;; newline
  (defun newline-and-indent-1 ()
    (interactive)
    (end-of-line)
    (newline-and-indent))
  (defun newline-and-indent-2 ()
    (interactive)
    (beginning-of-line)
    (newline-and-indent)
    (previous-line))
  (:modalka "C-o" newline-and-indent-1
            "M-o" newline-and-indent-2))

(setup coding-system
  (:doc "Coding-System settings")
  (:option locale-coding-system 'utf-8)
  (set-language-environment "UTF-8")
  (set-default-coding-systems 'utf-8)
  (set-buffer-file-coding-system 'utf-8-unix)
  (set-clipboard-coding-system 'utf-8-unix)
  (set-file-name-coding-system 'utf-8-unix)
  (set-keyboard-coding-system 'utf-8-unix)
  (set-next-selection-coding-system 'utf-8-unix)
  (set-selection-coding-system 'utf-8-unix)
  (set-terminal-coding-system 'utf-8-unix)
  (prefer-coding-system 'utf-8))

(setup editing-system
  (:doc "Editing-System settings")
  (:option global-visual-line-mode 1
           delete-selection-mode 1
           ;; electric-pair-mode 1
           indent-tabs-mode nil
           tab-width 4)
  (fset 'yes-or-no-p 'y-or-n-p)
  
  (setup mwim
    (:doc "Operations of Cursor moving")
    (:require mwim)
    (:modalka "C-a" mwim-beginning-of-code-or-line
              "C-b" mwim-end-of-code-or-line))

  (setup hideshow
    (:doc "Minor mode cmds to selectively display code/comment blocks")
    (:bind-into-after hs-minor-mode-map hideshow
      "C-c C-v C-c" hs-toggle-hiding
      "C-c C-v C-h" hs-hide-block
      "C-c C-v C-s" hs-show-block
      "C-c C-v C-t" hs-hide-all
      "C-c C-v C-a" hs-show-all
      "C-c C-v C-l" hs-hide-level)
    (:hooks prog-mode hs-minor-mode))

  (setup phi-search
    (:doc "Another incremental search & replace")
    (:require phi-search phi-replace)
    ;; phi-search
    (:modalka "C-." phi-search
              "C-," phi-search-backward)
    (:option phi-search-limit 10000)
    ;; phi-replace
    (:modalka "C-f C-r" phi-replace-query))

  (setup autorevert
    (:doc "Revert buffers when files on disk change")
    (:defer 1)
    (:option global-auto-revert-mode 1))

  (setup savehist
    (:doc "Save minibuffer history")
    (:defer 1)
    (:option savehist-additional-variables '(mark-ring
				                             global-mark-ring
				                             search-ring
				                             regexp-search-ring
				                             extended-command-history)
             savehist-autosave-interval 300
             history-length 1000
             kill-ring-max 300
             history-delete-duplicates t)
    (:option savehist-mode 1))

  (setup saveplace
    (:doc "automatically save place in files")
    (:defer 1)
    (:option save-place-mode 1)))

(setup font
  (:doc "Fonts setting")
  ;; default fonts
  (set-face-attribute 'default nil
		              :font (font-spec :family "FantasqueSansM Nerd Font"
				                       :size 20))

  ;; unicode
  (set-fontset-font t 'unicode
                    (font-spec :family "WenQuanYi Zen Hei Mono"
                               :size 15.0))

  ;; cn
  (set-fontset-font t '(#x4e00 . #x9fff)
		            (font-spec :family "思源宋体"
                               :size 15.0)))

(setup gnus
  (:doc " Gnus Network User Services in Emacs
Some private informations are svaed in `gnus-init-file'")
  (:option gnus-home-directory (no-littering-expand-etc-file-name "gnus")
           gnus-use-full-window nil
	       gnus-use-cache t)
  ;; authorization
  (setup (:require auth-source)
    (add-to-list 'auth-sources (f-expand ".authinfo" gnus-home-directory)))
  ;; Receiver
  (:option gnus-select-method '(nnimap "outlook"
			                           (nnimap-address "outlook.office365.com")
			                           (nnimap-inbox "Inbox")
			                           (nnimap-server-port 993)
			                           (nnimap-stream ssl)))
  ;; Sender
  (:option send-mail-function 'smtpmail-send-it
	       smtpmail-smtp-server "smtp.office365.com"
	       smtpmail-smtp-service 587)

  ;; Mail folder
  (:option nnfolder-directory (no-littering-expand-var-file-name "gnus/Mail")
           gnus-message-archive-group nil)
  ;; Delete mail
  (:option nnmail-expiry-wait 'never
	       nnmail-expiry-target "Deleted Messages")
  ;; Article sorting functions
  (:option gnus-article-sort-functions '(gnus-article-sort-by-most-recent-date
		                                 gnus-article-sort-by-number))
  (:hooks gnus-summary-prepare gnus-summary-sort-by-most-recent-date)
  ;; timeout
  (:option nntp-connection-timeout 10)
  ;; RSS
  (:hooks gnus-group-prepare
          (lambda ()
  	        (--map-when
	         (not (gnus-group-entry (concat "nnrss:"
									        (car it))))
             (let ((title (car it))
                   (href (cdr it)))
               (gnus-group-make-group title '(nnrss ""))
		       (push (list title href title) nnrss-group-alist))
             rss-list)  ; written in `gnus-init-file'
            (nnrss-save-server-data nil)))
  ;; WeCaht hook
  (setup rss-wechat
    (defun my/gnus--wechat-need-fetch (group)
      "Check the gourp's uri. GROUP is a string"
      (let ((uri (cdr (assoc-string group rss-list))))
        (and uri
             (string-match-p "feed.hamibot.com" uri))))
    (defvar my/eww--sig nil)
    (defun my/eww--set-sig ()
      "Set singal when EWW is loaded."
      (setq my/eww--sig t))
    (defun my/gnus-fetch-content-from-wechat ()
      "Fetch content from wechat link in the posts
TODO: Images don't show up, while other sites do."
      (when (and gnus-article-current
                 (string-match-p "^nnrss" (car gnus-article-current))
                 (my/gnus--wechat-need-fetch nnrss-group))
        (save-excursion
          (with-current-buffer gnus-article-buffer
            (re-search-forward "^link$")
            (backward-char)
            (let ((uri (get-text-property (point) 'shr-url))
                  (res ""))
              (save-excursion
                (add-hook 'eww-after-render-hook #'my/eww--set-sig)
                (eww uri)
                (with-timeout (5 nil) ; timeout 5-6 sec
                  (while (not my/eww--sig)
                    (sleep-for 1))
                  (setq res (buffer-string)
                        my/eww--sig nil))
                (remove-hook 'eww-after-render-hook #'my/eww--set-sig))
              (when (length> res 0)
                (read-only-mode -1)
                (delete-lines)
                (insert res)
                (read-only-mode 1)))))
        (quit-window)))
    (:hooks gnus-article-prepare my/gnus-fetch-content-from-wechat))
  )

(setup dirvish
  (:doc "An improved version of the Emacs inbuilt package Dired")
  (:load-path (f-expand "dirvish/extensions" user-module-directory))
  (:require dirvish dirvish-icons dirvish-emerge
            dirvish-quick-access dirvish-subtree)
  (:custom dirvish-quick-access-entries
           '(("h" "~/")
             ("e" "~/.emacs.d/")
             ("g" "~/gh-repo/")
             ("n" "~/Note/")))
  (defun dirvish--truncate-line (&rest _)
    (setq-local truncate-lines t))
  (dirvish-emerge-define-predicate is-dir
    "If item is a directory"
    (equal (car type) 'dir))
  (:option dirvish-use-header-line nil
           dirvish-attributes '(subtree-state all-the-icons file-size)
           delete-by-moving-to-trash t
           dirvish-mode-line-height 21
           dirvish-default-layout nil
           dired-listing-switches
           "-l --almost-all --human-readable --group-directories-first --no-group --time-style=iso"
           dirvish-emerge-groups
           '(("Hidden" (regex . "^\\."))
             ("Directory" (predicate . is-dir))
             ("Documents" (extensions "pdf" "tex" "bib" "epub"))
             ("Video" (extensions "mp4" "mkv" "webm"))
             ("Picture" (extensions "jpg" "png" "svg" "gif"))
             ("Audio" (extensions "mp3" "flac" "wav" "ape" "aac"))
             ("Archive" (extensions "gz" "rar" "zip"))
             ("Org" (extensions "org"))
             ("Emacs Lisp" (extensions "el"))
             ("Python" (extensions "py"))
             ("Files" (regex . ".*"))))
  (:option dirvish-override-dired-mode 1)
  (:hooks dirvish-find-entry dirvish--truncate-line
          dirvish-setup dirvish-emerge-mode)
  (:modalka "C-x C-d" dirvish)
  (:bind-into-after dirvish-mode-map dirvish
    "a" dirvish-quick-access
    "j" dired-next-line
    "k" dired-previous-line
    "f" dired-goto-file
    "b" dired-up-directory
    "n" dirvish-emerge-next-group
    "p" dirvish-emerge-previous-group
    "TAB" dirvish-subtree-toggle
    "M-t" dirvish-layout-toggle))

(setup corfu-mode
  (:doc "An enhancement of completion in-buffer with a small completion popup")
  (:load-path (f-expand "corfu/extensions" user-module-directory))
  (:require corfu corfu-popupinfo
            corfu-history corfu-echo)
  (defun corfu-enable-always-in-minibuffer ()
    "Enable Corfu in the minibuffer if Vertico/Mct are not active."
    (unless (or (bound-and-true-p mct--active)
                (bound-and-true-p vertico--input)
                (eq (current-local-map) read-passwd-map))
      (setq-local corfu-echo-delay nil)
      (corfu-mode 1)
      (corfu-popupinfo-mode 1)))
  (:bind-into-after corfu-map corfu
    "C-j" corfu-next
    "C-h" corfu-previous
    "M-j" corfu-popupinfo-scroll-up
    "M-k" corfu-popupinfo-scroll-down)
  (:hooks minibuffer-setup corfu-enable-always-in-minibuffer)
  (:hook corfu-history-mode corfu-echo-mode)
  (:hook-into prog-mode inferior-emacs-lisp-mode inferior-python-mode)
  (:option corfu-cycle t
           corfu-auto t
           corfu-separator ?\s
           corfu-quit-no-match 'separator
           corfu-preselect-first t
           corfu-auto-prefix 1
           corfu-auto-delay 0.0
           corfu-popupinfo-delay '(0.1 . 0.5)
           ;; Emacs
           tab-always-indent 'complete
           completion-cycle-threshold 3)
  (add-to-list 'corfu-margin-formatters
               #'kind-all-the-icons-margin-formatter))

(setup minibuffer-enhencements
  (:doc "Enhencements of minibuffer,
based on vertico, orderless, marginalia, embark and consult")
  (:load-path (f-expand "vertico/extensions" user-module-directory))
  (:require vertico vertico-directory vertico-mouse
            orderless marginalia embark consult)
  ;; Vertico
  (:option vertico-scroll-margin 0
           vertico-cycle t
           vertico-resize t)
  (:option vertico-mode 1)
  ;; Vertico-Directory
  (:bind-into-after vertico-map vertico
    "RET" vertico-directory-enter
    "DEL" vertico-directory-delete-char
    "C-DEL" vertico-directory-delete-word
    "M-DEL" vertico-directory-up)
  ;; Vertico-Mouse
  (:option vertico-mouse-mode 1)
  ;; Orderless
  (:option completion-styles '(substring orderless
                               partial-completion basic)
           completion-category-defaults nil
           completion-category-overrides nil)
  ;; Marginalia
  (:hooks marginalia-mode all-the-icons-completion-marginalia-setup)
  (:option marginalia-mode 1)
   ;; Embark
  (:option prefix-help-command #'embark-prefix-help-command)
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))
  (:modalka  "C-/" embark-act
             "C-?" embark-dwim)
  ;; Consult
  (:modalka "C-f C-f" consult-line
            "C-f C-l" consult-goto-line
            "C-f C-m" consult-mark
            "C-f C-S-m" consult-global-mark
            "C-f C-d" consult-ripgrep))

(setup gui
  (:doc "GUI settings")
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  (add-to-list 'default-frame-alist '(menu-bar-lines . 0))
  (add-to-list 'default-frame-alist '(tool-bar-lines . 0))
  (add-to-list 'default-frame-alist '(vertical-scroll-bars))
  (:option inhibit-startup-message t
           inhibit-startup-echo-area-message t
           initial-major-mode 'fundamental-mode
           initial-scratch-message nil)
  
  (:with-mode display-line-numbers-mode
    (:doc "Interface for display-line-numbers")
    (:require display-line-numbers)
    (:option display-line-numbers-type 'relative)
    (:hook-into prog-mode)
    (defun set-hl-face ()
      "Set hightline face. Used in `init-theme.el'"
      (set-face-attribute 'line-number nil
		                  :slant 'italic)
      (set-face-attribute 'line-number-current-line nil
                          :foreground (face-attribute 'error :foreground)
                          :background (face-attribute 'highlight :background)
                          :weight 'bold
		                  :slant 'normal)))

  (:with-mode hl-line-mode
    (:doc "Highlight the current line")
    (:require hl-line)
    (:hook-into prog-mode))

  (:with-mode show-paren-mode
    (:doc "Highlight matching paren")
    (:require paren)
    (:hook-into prog-mode)
    (:option show-paren-delay 0)
    (define-advice show-paren-function (:around (fn) fix)
      "Highlight enclosing parens."
      (cond ((looking-at-p "\\s(") (funcall fn))
            (t (save-excursion
                 (ignore-errors (backward-up-list))
                 (funcall fn)))))
    (set-face-attribute 'show-paren-match nil
    		            :box
    		            `(:line-width -1
                          :color ,(face-attribute 'default :foreground))))
  (:with-mode rainbow-delimiters-mode
    (:doc "Highlight delimiters according to their depth.")
    (:require rainbow-delimiters)
    (:hook-into prog-mode)))

(setup ibuffer-mode
  (:doc "Operate on buffers like dired")
  (:require ibuffer)
  (define-ibuffer-column size-h
    (:name "Size" :inline t)
    (file-size-human-readable (buffer-size)))
  (:hook (lambda ()
           (ibuffer-switch-to-saved-filter-groups "Buffer")
           (setq ibuffer-hidden-filter-groups '("Base" "Hidden"))))
  (:option ibuffer-marked-char 42
           ibuffer-show-empty-filter-groups nil
           ibuffer-display-summary nil
           ibuffer-filter-group-name-face 'font-lock-doc-face
           ibuffer-formats (quote ((" " mark " "
                                    (name 18 18 :left :elide)
                                    " "
                                    (mode 16 16 :left :elide)
                                    " "
                                    (size-h 9 9 :right)
                                    " "
                                    (filename-and-process 30 30))))
           
           ibuffer-saved-filter-groups
           (quote (("Buffer"
                    ("Dired" (mode . dired-mode))
                    ("Emacs Lisp" (name . "\\.el$\\|\\.el\\.gz$"))
                    ("Python" (name . "\\.py$"))
                    ("Org"  (name . "\\.org$"))
                    ("GNUS" (or
                             (mode . message-mode)
                             (mode . bbdb-mode)
                             (mode . mail-mode)
                             (mode . gnus-group-mode)
                             (mode . gnus-summary-mode)
                             (mode . gnus-article-mode)
                             (name . "^\\.bbdb$")
                             (name . "^\\.newsrc-dribble")))
                    ("Base" (or
                             (name . "^\\*scratch\\*$")
                             (name . "^\\*Messages\\*$")
                             (name . "^\\*Completions\\*$")
                             (mode . help-mode)
                             (mode . debug-mode)))
                    ("Hidden" (name . "^\\*[^*]*\\*$"))))))
  (:bind-into-after ibuffer-mode-map ibuffer
    "j" ibuffer-forward-line
    "k" ibuffer-backward-line
    "M-j" ibuffer-forward-line
    "M-k" ibuffer-backward-line
    "f" ibuffer-jump-to-buffer
    "S-f" ibuffer-forward-line
    "M-f" ibuffer-forward-line)
  (:modalka "C-x C-b" ibuffer))

(setup window
  (:doc "Operations about windows")
  (:require window winum)
  ;; window
  (defun split-window-right-for-buffer (buffer)
    (interactive "bChoose buffer: \n")
    (split-window-right)
    (windmove-right)
    (switch-to-buffer buffer))
  (defun split-window-below-for-buffer (buffer)
    (interactive "bChoose buffer: \n")
    (split-window-below)
    (windmove-down)
    (switch-to-buffer buffer))
  (:modalka "M-q M-s" split-window-right-for-buffer
            "M-q M-v" split-window-below-for-buffer
            "M-q M-q" delete-window
            "M-q M-w" delete-other-windows
            "M-q M-e" other-window)
  ;; winum
  (:modalka "M-0" winum-select-window-0
            "M-1" winum-select-window-1
            "M-2" winum-select-window-2
            "M-3" winum-select-window-3
            "M-4" winum-select-window-4
            "M-5" winum-select-window-5
            "M-6" winum-select-window-6
            "M-7" winum-select-window-7
            "M-8" winum-select-window-8
            "M-9" winum-select-window-9)
  (:option winum-auto-assign-0-to-minibuffer t
           winum-auto-setup-mode-line nil)
  (:option winum-mode 1))

(setup jieba
  (:doc "Things about selection and deletion supporting CN words")
  (:require jieba)
  (defun select-word-at-point ()
    (interactive)
    (when (use-region-p)
	  (keyboard-escape-quit))
    ;; 确保回到单词的第一个字符
    (jieba-forward-word)
    (jieba-backward-word)
    (set-mark-command nil)
    ;; 落到单词结尾
    (jieba-forward-word))
  (defun select-next-word (&optional N)
    (interactive "p")
    (when (use-region-p)
	  (keyboard-escape-quit))
    (set-mark-command nil)
	(jieba-forward-word N))
  (defun select-previous-word (&optional N)
    (interactive "p")
    (when (use-region-p)
	  (keyboard-escape-quit))
    (set-mark-command nil)
	(jieba-backward-word N))
  (defun select-current-line-and-forward-line (&optional N)
    "Select a line, with cursor locating at the beginning of next line.
    If N given, then select N lines.(-N backward)"
    (interactive "p")
    (when (use-region-p)
	  (keyboard-escape-quit))
	(forward-line 0)    ; 移动到行首
	(set-mark-command nil)
	(forward-line N))
  (defun select-current-lin-without-indentation (&optional N)
    "Select a line, withn cursor locating at the end of current line.
    If N given, then select N lines.(-N backward)"
    (interactive "p")
    (when (use-region-p)
	  (keyboard-escape-quit))
    (mwim-beginning-of-code-or-line)
    (set-mark-command nil)
    (move-end-of-line N))
  (defun select-to-forward-word (&optional N)
    "Select to next word.
    If N given, then select to next N words."
    (interactive "P")
    (when (use-region-p)
	  (keyboard-escape-quit))
	(set-mark-command nil)
	(jieba-forward-word N))
  (defun select-to-backword-word (&optional N)
    "Select to previous word.
    If N given, then select to previous N words."
    (interactive "P")
    (when (use-region-p)
	  (keyboard-escape-quit))
	(set-mark-command nil)
	(jieba-backward-word N))
  (defun select-to-beginning-of-line (&optional REAL)
    "Select to the beginning of line.
    IF REAL, then indentions include."
    (interactive "P")
    (when (use-region-p)
	  (keyboard-escape-quit))
	(set-mark-command nil)
	(if REAL
	    (mwim-beginning-of-line)
	  (mwim-beginning-of-code-or-line)))
  (defun select-to-end-of-line (&optional REAL)
    "Select to the end of line.
    IF REAL, then spaces include."
    (interactive "P")
    (when (use-region-p)
	  (keyboard-escape-quit))
	(set-mark-command nil)
	(if REAL
	    (mwim-end-of-line)
	  (mwim-end-of-code-or-line)))
  (defun delete-word-at-point ()
    (interactive)
    (select-word-at-point)
    (delete-active-region)
    (message "A word deleted"))
  (defun delete-next-word (&optional N)
    (interactive "p")
    (select-next-word N)
    (delete-active-region)
    (message "%d words deleted" N))
  (defun delete-previous-word (&optional N)
    (interactive "p")
    (select-previous-word N)
    (delete-active-region)
    (message "%d words deleted" N))
  (defun delete-lines (&optional N)
    (interactive "p")
    (select-current-line-and-forward-line N)
    (delete-active-region)
    (message "%s lines deleted" N))
  (defun delete-to-beginning-of-line (&optional REAL)
    (interactive "P")
    (select-to-beginning-of-line REAL)
    (delete-active-region)
    (message "Delete to the beginning of line"))
  (defun delete-to-end-of-line (&optional REAL)
    (interactive "P")
    (select-to-end-of-line REAL)
    (delete-active-region)
    (message "Delete to the beginning of line"))
  (:modalka "C-r" jieba-forward-word
            "C-e" jieba-backward-word
            "C-v C-d" select-word-at-point
            "C-v C-r" select-next-word
            "C-v C-e" select-previous-word
            "C-v C-l" select-current-line-and-forward-line
            "C-v C-L" select-current-lin-without-indentation
            "C-v C-a" select-to-beginning-of-line
            "C-v C-b" select-to-end-of-line
            "C-d C-d" delete-word-at-point
            "C-d C-r" delete-next-word
            "C-d C-e" delete-previous-word
            "C-d C-l" delete-lines
            "C-d C-a" delete-to-beginning-of-line
            "C-d C-b" delete-to-end-of-line
            "C-<backspace>" delete-previous-word
            "C-<delete>" delete-next-word)
  (:option jieba-mode 1))

;; https://github.com/joaotavora/eglot/issues/1193
;; 等更新
;; (setup eglot
;;   (:doc "A emacs LSP client")
;;   (:autoload eglot-ensure)
;;   (:with-function eglot-ensure
;;     (:hook-into python-mode
;;                 yaml-mode
;;                 js-mode
;;                 mhtml-mode
;;                 scss-mode
;;                 latex-mode))
;;   (:after eglot
;;    (:option eldoc-echo-area-use-multiline-p 1)))

(setup theme
  (:doc "Theme settings")
  (:require dracula-theme one-themes circadian)
  (:hooks circadian-after-load-theme
          (lambda (theme)
            (setq modeline-dark-theme (string= (symbol-name theme)
				                               "dracula"))
            (set-hl-face)))
  (:option circadian-themes '(("07:00" . one-light)
                              ("20:00" . dracula)))
  (circadian-setup))

(setup rime
  (:doc "RIME input method in Emacs")
  (:custom default-input-method "rime")
  (:require rime)
  (:after rime
    (defun my-predicate-punctuation-after-space-cc-p ()
      (let* ((start (save-excursion
				      (re-search-backward
					   "[^\s]"
					   nil
					   t)))
		     (string (buffer-substring
				      (if start start 1)
				      (point))))
	    (string-match "\\cc +" string)))
    (:option rime-inline-ascii-trigger 'shift-l
             rime-show-preedit 'inline
             rime-show-candidate 'posframe)
    (:option rime-disable-predicates
             '(rime-predicate-prog-in-code-p
               my-predicate-punctuation-after-space-cc-p
               rime-predicate-after-alphabet-char-p))
    (:bind-into-after rime-mode-map rime
      "M-j" rime-force-enable)
    (:after org
	  (add-to-list 'rime-disable-predicates 'org-in-src-block-p)))
  (:modalka "C-<SPC>" toggle-input-method))

(setup denote
  (:doc "A simple note-taking tool for Emacs")
  (:autoload denote denote-dired-mode)
  (defun denote-template ()
    "Create note while prompting for a subdirectory.

Available candidates include the value of the variable
`denote-directory' and any subdirectory thereof.

This is equivalent to calling `denote' when `denote-prompts' is
set to '(subdirectory title keywords)."
    (declare (interactive-only t))
    (interactive)
    (let ((denote-prompts '(template subdirectory title keywords)))
      (call-interactively #'denote)))
  (:option
   denote-directory "~/Note"
   denote-known-keywords '("emacs" "philosophy" "politics" "history" "aesthetics"
                           "math" "physics" "python" "book" "pedagogy" "muse" )

   denote-date-format "<%Y-%m-%d %a>"
   
   denote-infer-keywords t
   denote-sort-keywords t
   denote-file-type 'org

   denote-prompts '(subdirectory title keywords)
   denote-excluded-directories-regexp "^assets\\|^static"

   ;; Pick dates, where relevant, with Org's advanced interface:
   denote-date-prompt-use-org-read-date t
   denote-allow-multi-word-keywords nil

   xref-search-program 'ripgrep

   denote-templates
   `((book . ,(concat "#+book_author: \n"
                      "#+book_translator: \n"
                      "#+book_publisher: \n"
                      "#+book_publish_date: \n\n"
                      "#+startup: overview\n\n"
                      "* Outline\n"
                      ":PROPERTIES:\n"
                      ":VISIBILITY: all\n"
                      ":END:\n\n"
                      "* Conclusion\n"
                      ":PROPERTIES:\n"
                      ":VISIBILITY: all\n"
                      ":END:\n\n"
                      "* Excerpts\n"
                      ":PROPERTIES:\n"
                      ":VISIBILITY: children\n"
                      ":END:\n"))
     (blog . ,(concat "#+publish: nil\n\n"))))
  (:after denote
    (set-face-attribute 'denote-faces-date nil
                        :foreground
                        (face-attribute 'font-lock-function-name-face
                                        :foreground))
    (set-face-attribute 'denote-faces-delimiter nil
                        :foreground
                        (face-attribute 'font-lock-comment-face
                                        :foreground))
    (set-face-attribute 'denote-faces-extension nil
                        :foreground
                        (face-attribute 'font-lock-comment-face
                                        :foreground))
    (set-face-attribute 'denote-faces-keywords nil
                        :foreground
                        (face-attribute 'font-lock-keyword-face
                                        :foreground))
    (set-face-attribute 'denote-faces-title nil
                        :foreground
                        (face-attribute 'font-lock-string-face
                                        :foreground)))
  (:hooks dired-mode denote-dired-mode))

(setup modeline
  (:doc "Configuration of mode line
REF:
https://emacs.stackexchange.com/questions/16654/how-to-re-arrange-things-in-mode-line
https://github.com/domtronn/all-the-icons.el/wiki/Mode-Line")
  (defcustom modeline-colors '((background . ("#F0F0F0" "#44475a"))
	                           (background-deep . ("#FAFAFA" "#282a36"))
	                           (foreground . ("#494B53" "#f8f8f2"))
	                           (red . ("#E45649" "#ff5555"))
	                           (blue . ("#4078F2" "#7b6bff"))
	                           (green . ("#50A14F" "#50fa7b"))
	                           (yellow . ("#986801" "#f1fa8c"))
	                           (pink . ("#CA1243" "#ff79c6"))
	                           (cyan . ("#0184BC" "#8be9fd"))
	                           (purple . ("#A626A4" "#bd93f9"))
	                           (orange . ("#C18401" "#ffb86c")))
    "colors in modeline.

This variable is a ALIST, in which keys are colors' name,
and values are the lists with two elements representing
color in light theme and dark theme respectively.

LIGHT: one-light
DARK: dracula-theme")
  (defvar modeline-dark-theme nil
    "If use dark theme colors")
  (defun modeline-get-color (color-name)
    "Return the string of COLOR-NAME.

If IF-DARK is not-nil, then return the color-string in
dark theme."
    (let ((idx (if modeline-dark-theme 1 0)))
	  (nth idx (assoc-default color-name modeline-colors))))
  (defvar modeline-left
    '(modeline-winum
      modeline-major-mode
      modeline-buffer-name))
  (defvar modeline-right
    '(modeline-rime-state
      modeline-cursor-info))
  (defun modeline-winum ()
    "窗口编号"
    (propertize (format " %d " (winum-get-number))
                'face `(:foreground ,(modeline-get-color 'background)
                        :background ,(modeline-get-color 'foreground))))
  (defun modeline-major-mode ()
    "主模式"
    (propertize (format "  %s"
					    (s-upcase (s-replace-regexp "[\s-]*mode$" ""
                                                    (format "%s" major-mode))))
                'help-echo (s-spaced-words (s-titleize (format "%s" major-mode)))
                'face `(:foreground ,(modeline-get-color 'foreground)
					    :background ,(modeline-get-color 'background)
					    :family "Sans Serif"					  
					    :height 0.8
					    :weight bold)))
  (defun modeline-buffer-name ()
    "Buffer"
    (let ((name-color (cond
					   (buffer-read-only (modeline-get-color 'red))
					   ((buffer-modified-p) (modeline-get-color 'blue))
					   (t (modeline-get-color 'green)))))
      (propertize " %b"
		          'face `(:foreground ,name-color
				          :background ,(modeline-get-color 'background))
		          'display '(raise -0)
		          'help-echo (if buffer-file-name
					             buffer-file-name
					           (buffer-name)))))
  (defun modeline-rime-state ()
    "Whether RIME Mode is activated."
    (let ((state (length> (and (fboundp 'rime-lighter)
							   (rime-lighter))
						  0)))
      (propertize (format " %s " (if state " RIME" "    "))
				  'face `(:foreground ,(modeline-get-color 'pink)
						  :background ,(modeline-get-color 'background))
				  'display '(raise -0)
				  )))
  (defun modeline-cursor-info ()
    "光标位置相关信息" 
    (propertize (s-replace "%" "%%" (format-mode-line " %p <%l,%c> "))
			    'face `(:foreground ,(modeline-get-color 'background)
		                :background ,(modeline-get-color 'purple))))
  (defun modeline-pomodoro ()
    "番茄闹钟"
    (concat
     (propertize (format " ( %s ) " (if (and (listp org-pomodoro-mode-line)
                                             org-pomodoro-mode-line)
                                        (cadr org-pomodoro-mode-line)
                                      ""))
                 'face `(:foreground ,(modeline-get-color 'cyan)
                         :background ,(modeline-get-color 'background)))
     (propertize (format "[%s] " (s-pad-right org-pomodoro-long-break-frequency
                                              " "
                                              (s-repeat org-pomodoro-count
                                                        "*")))
                 'face `(:foreground ,(modeline-get-color 'purple)
                         :background ,(modeline-get-color 'background)))))
  (defun modeline-denote-title ()
    "Denote's Title"
    (let ((name-color (cond
					   (buffer-read-only (modeline-get-color 'red))
					   ((buffer-modified-p) (modeline-get-color 'blue))
					   (t (modeline-get-color 'green)))))
      (propertize (format " %s "
                          (denote-retrieve-title-value (f-this-file) 'org))
		          'face `(:foreground ,name-color
				          :background ,(modeline-get-color 'background))
		          'display '(raise -0)
		          'help-echo (if buffer-file-name
					             buffer-file-name
					           (buffer-name)))))
  (defun modeline-denote-keywords ()
    "Denote's keywords"
    (mapconcat
     (lambda (it)
       (propertize (format "%s" it)
                   'face `(:foreground ,(modeline-get-color 'orange)
				           :background ,(modeline-get-color 'background))
		           'display '(raise -0)
		           ;; 'help-echo
                   'mouse-face `(:background ,(modeline-get-color 'background-deep))
                   'local-map (make-mode-line-mouse-map
						       'mouse-1 `(lambda ()
                                           (interactive)
                                           (let ((denote-ql--kws (list ,it)))
                                             (denote-ql--keyword))))))
     (denote-retrieve-keywords-value (f-this-file) 'org)
     " "))
  (defun modeline-empty ()
    "Nothing"
    "")
  (defun modeline-space ()
    (let* ((rp-lst (-map #'funcall modeline-right))
           (rp (if rp-lst
                   (apply #'concat rp-lst)
                 ""))
           (reserve (+ (length rp)
                       (if (s-match "%" rp) 0 1))))
      (setq reserve (1- reserve))
      (propertize " "
                  'display `((space :align-to
                                    (- (+ right right-fringe right-margin)
                                       ,reserve)))
                  'face `(:background ,(modeline-get-color 'background)))))
  (defun modeline-set-agenda ()
    (setq-local
     modeline-left '(modeline-winum
                     modeline-major-mode)
     modeline-right '(modeline-pomodoro)))
  (defun modeline-set-org ()
    (setq-local
     modeline-left `(modeline-winum
                     modeline-major-mode
                     ,(if (and (f-this-file)
                               (f-exists-p (f-this-file))
                               (f-descendant-of-p (f-this-file) denote-directory))
                          'modeline-denote-title
                        'modeline-buffer-name)
                     ,(if (and (f-this-file)
                               (f-exists-p (f-this-file))
                               (f-descendant-of-p (f-this-file) denote-directory))
                          'modeline-denote-keywords
                        'modeline-empty))
     modeline-right '(modeline-rime-state
                      modeline-cursor-info)))
  (:after org-agenda
    (:hooks org-agenda-mode-hook modeline-set-agenda))
  (:after org
    (:hooks org-mode-hook modeline-set-org))
  (setq-default mode-line-format
                '("%e" (:eval
                        (let ((lp (-map #'funcall modeline-left))
                              (rp (-map #'funcall modeline-right)))
                          (apply #'concat
                                 (append lp
                                         (list (modeline-space))
                                         rp)))))))

(setup org-mode
  (:doc "Org Mode settings")
  (:option org-todo-keywords '((sequence "TODO(t)"
                                         "DOING(i)"
                                         "WAIT(w@/!)"
                                         "|"
                                         "DONE(d!)"
                                         "CANCELED(c@)")))
  (:option org-edit-src-content-indentation 0
           org-auto-align-tags nil
           org-tags-column 0
           org-use-sub-superscripts nil)
  (:hook (lambda () (setq word-wrap nil)))

  (setup org-apparence
    (:doc "Org Apparence settings")
    (:after org
      (set-face-attribute 'org-checkbox nil :box nil)
      (set-face-attribute 'org-level-1 nil :weight 'semi-bold :height 1.0)
      (set-face-attribute 'org-level-2 nil :weight 'semi-bold :height 1.0)
      (set-face-attribute 'org-level-3 nil :weight 'semi-bold :height 1.0)
      (set-face-attribute 'org-level-4 nil :weight 'semi-bold :height 1.0)
      (set-face-attribute 'org-level-5 nil :weight 'semi-bold :height 1.0)))

  (setup org-headline
    (:doc "Org Headline settings")
    (defun org-headline-set (&optional N)
      "Set org headline"
      (interactive "p")
      (when (and (org-at-heading-p)
			     (/= N
				     (save-excursion
				       (beginning-of-line)
				       (length
					    (nth 1
						     (s-match org-heading-regexp
                                      ;; "^\\([*]\\{1,6\\}\\) "
								      (buffer-substring-no-properties
								       (point)
								       (+ (point) 10))))))))
        (org-toggle-heading))
      (when (and (>= N 1)
			     (<= N 6))
        (org-toggle-heading N)))
    (defun org-headline-set-1 () (interactive) (org-headline-set 1))
    (defun org-headline-set-2 () (interactive) (org-headline-set 2))
    (defun org-headline-set-3 () (interactive) (org-headline-set 3))
    (defun org-headline-set-4 () (interactive) (org-headline-set 4))
    (defun org-headline-set-5 () (interactive) (org-headline-set 5))
    (defun org-headline-set-6 () (interactive) (org-headline-set 6))
    (:bind-into-after org-mode-map org
                      "C-c h 1" org-headline-set-1
                      "C-c h 2" org-headline-set-2
                      "C-c h 3" org-headline-set-3
                      "C-c h 4" org-headline-set-4
                      "C-c h 5" org-headline-set-5
                      "C-c h 6" org-headline-set-6))
  
  (setup org-agenda
    (:doc "Org Agenda settings")
    (:modalka "C-\\" org-cycle-agenda-files)
    (:after org-agenda
      (:option org-agenda-tags-column 0
               org-agenda-use-time-grid t
               org-agenda-time-grid '((daily today require-timed)
                                      (700 1200 1800 2300)
                                      "......"
                                      "----------------")
               org-agenda-start-with-follow-mode t
               org-agenda-skip-scheduled-if-done t)))

  (setup org-babel
    (:doc "Execute source code within Org")
    (org-babel-do-load-languages 'org-babel-load-languages
                                 '((python . t)
                                   (lisp . t))))

  (setup org-link
    (:doc "Settings of links in Org Mode")
    (defun org-insert-key-sequence ()
      "Insert key sequnce"
	  (interactive)
	  (insert (key-description
			   (read-key-sequence-vector "Pressing... "))))
    (defun org-insert-uri ()
      "Try to fetch HTML by URL, parsing it to get title."
      (interactive)
      (let ((title "")
            (uri (read-from-minibuffer "Uri: ")))
        (with-current-buffer
            (url-retrieve-synchronously uri t nil 10)
          (let* ((dom (libxml-parse-html-region
                       (point-min) (point-max))))
            (setq title 
                  (and dom
                       (dom-text (dom-by-tag dom 'title))))))
        (unless (or title
                    (length= title 0))
          (setq title
                (read-from-minibuffer
                 "Failed to get title. Manually descript: ")))
        (insert (format "[[%s][%s]]" uri (s-trim title)))))
    (defvar org-image-directory nil)
    (:option org-image-directory "~/Note/assets")
    (defun org-image-insert ()
      "Insert image from Special directory into current buffer."
      (interactive)
      
      (defun image--sort-completion-table (completions)
        (lambda (string pred action)
          (if (eq action 'metadata)
              `(metadata (display-sort-function . ,#'identity))
            (complete-with-action action completions string pred))))
      
      (let ((images (--sort (>= (f-modification-time it 'seconds)
                                 (f-modification-time other 'seconds))
                            (f-files org-image-directory)))
            (cur-file (f-this-file)))
        (if (not cur-file)
            (message "Current buffer is not a file: %s" (buffer-name
                                                         (current-buffer)))
          (insert (format "[[file:%s]]\n"
                          (f-relative
                           (completing-read
                            "Insert image: "
                            (image--sort-completion-table images)
                            nil t)
                           (f-dirname cur-file)))))))
    (:bind-into-after org-mode-map org
      "C-c C-i" org-insert-uri
      "C-C C-k" org-insert-key-sequence
      "C-c C-m" org-image-insert)
    (:option org-link-file-path-type 'relative))

  (setup org-modern
    (:doc "A modern style for Org buffers")
    (:autoload global-org-modern-mode)
    (:option org-hide-emphasis-markers t
             org-modern-list '((?+ . "◦")
		                       (?- . "•")
		                       (?* . "•"))
             org-modern-checkbox nil
             org-modern-todo-faces
             `(("TODO"  :background "red3" :foreground "white" :weight bold)
               ("DOING" :background "SteelBlue" :foreground "white" :weight bold)
               ("WAIT" :background "orange" :foreground "white" :weight bold)
               ("DONE" :background "SeaGreen4" :foreground "white" :weight bold)
               ("CANCELED" :foreground ,(face-attribute 'fringe
                                                        :foreground)
                           :weight bold
                           :strike-through ,(face-attribute 'fringe
                                                            :foreground))))
    (:hooks org-mode global-org-modern-mode))

  (setup olivetti
    (:doc "A simple Emacs minor mode for a nice writing environment.")
    (:option olivetti-body-width 120)
    (:autoload olivetti-mode)
    (:hooks org-mode olivetti-mode)
    )

  (setup org-pomodoro
    (:doc "Basic support for Pomodoro technique in Org Mode.")
    (:autoload org-pomodoro)
    (:option org-pomodoro-start-sound-p t
             org-pomodoro-length 25
             org-pomodoro-short-break-length 5
             org-pomodoro-long-break-length 30)
    (:bind-into-after org-agenda-mode-map org-agenda
      "G" org-pomodoro)
    (:hooks org-pomodoro-long-break-finished (lambda ()
                                               (setq org-pomodoro-count 0)))
    )

  (setup org-latex
    (:doc "Org Latex Environment")
    (:option org-latex-listings t
             org-latex-pdf-process
             '("xelatex -interaction nonstopmode -output-directory %o %f"
               "xelatex -interaction nonstopmode -output-directory %o %f"
               "xelatex -interaction nonstopmode -output-directory %o %f")
             org-latex-compiler "xelatex")
    (add-to-list 'org-latex-packages-alist '("" "xeCJK"))
    ;; Beamer
    (:option org-beamer-frame-level 2
             org-beamer-outline-frame-title "Content"))

  (setup org-drill
    (:doc "An Spaced Repetition System")
    (:autoload org-drill)
    (:option drill-directory "~/Drill/"
             org-drill-maximum-items-per-session 40
             org-drill-maximum-duration 30)
    (defun drill ()
      "Start to drill."
      (interactive)
      (setq org-drill-scope
            (f-files (f-expand (completing-read
                                "What to drill: "
                                (-map #'f-base                
                                      (f-directories drill-directory))
                                nil t)
              drill-directory)))
      (org-drill))
    (defalias 'destructuring-bind 'cl-destructuring-bind))

  (setup org-journal
    (:doc "A simple personal diary / journal using in Emacs.")
    (:autoload org-journal-new-entry)
    (:option org-journal-dir "~/Journal"
             org-journal-find-file 'find-file
             
             org-journal-carryover-items
             "TODO=\"TODO\"|TODO=\"DOING\"|TODO=\"WAIT\""
             
             org-journal--cache-file
             (no-littering-expand-var-file-name "org-journal.cache")
             org-journal-enable-cache t
             org-journal-file-format "%Y%m%d.org"
             org-journal-hide-entries-p nil)
    (:modalka "C-c C-j" (lambda () (interactive) (org-journal-new-entry t))))
  )

(setup yaml-mode
  (:doc "Support for YAML Language")
  (:autoload yaml-mode)
  (add-to-list 'auto-mode-alist '("\\.\\(yml\\|yaml\\)\\'" . yaml-mode)))

(setup markdown-mode
  (:doc "Support for Markdown")
  (:autoload markdown-mode)
  (:option markdown-command "multimarkdown")
  (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode)))

(setup excerpt
  (:doc "Excerpt management")
  (:autoload excerpt)
  (:option excerpt-dir (no-littering-expand-var-file-name "excerpt")))

(setup blog
  (:doc "Blog publishing system")
  (:load-path "~/gh-repo/org-blog")
  (:autoload org-blog-publish)
  (:option org-blog-publish-directory "~/blog/"
           org-blog-posts-directory "~/Note/"
           org-blog-static-directory "~/Note/static/"
           org-blog-assets-directory "~/Note/assets/"
           org-blog-cache-file (no-littering-expand-var-file-name
                                "org-blog-cache.json"))
  (:option org-blog-publish-title "手指骑士的病房"
           org-blog-publish-description "I choose to see the beauty."
           org-blog-publish-author "Finger Knight"
           org-blog-index-length 5
           org-blog-use-preview t
           org-blog-enable-tags t

           org-export-with-sub-superscripts nil
           
           org-export-with-toc nil
           org-export-with-section-numbers nil)
  (:option org-blog-page-head
           (concat "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
                   "<meta name=\"robots\" content=\"noodp\">\n"
                   (format "<meta name=\"author\" content=\" %s \">\n"
                           org-blog-publish-author)
                   "<meta name=\"referrer\" content=\"no-referrer\">"
                   "<link rel=\"icon\" href=\"/static/favicon.ico\">"
                   "<link href= \"/static/style/style.css\" rel=\"stylesheet\" type=\"text/css\" />"))

  (:option org-blog-index-front-matter
           (format "<div class=\"index-desc\"><center> %s </center></div>\n"
                   org-blog-publish-description)))

(setup elisp-def
  (:doc "Go to the definition of the symbol at point.")
  (:autoload elisp-def-mode)
  (:hook-into emacs-lisp-mode ielm-mode))

(setup smartparens
  (:doc "A minor mode for dealing with pairs in Emacs.")
  (:require smartparens-config)
  (:option smartparens-global-mode 1)
  (:hooks prog-mode turn-on-smartparens-strict-mode))

(provide 'init)
;;; init.el ends