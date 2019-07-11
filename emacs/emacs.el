; File: emacs.el
; last revised: Dan Waldheim, 02-May-2003

; Add path to my .el's to load-path
(setq load-path (cons (concat (getenv "PUB") "/emacs") load-path))
(setq load-path (cons (concat (getenv "HOME") "/emacs") load-path))

; Load user emacs and mail specifics if exists and readable
(if (file-readable-p (concat (getenv "HOME") "/emacs/myemacs.el"))
    (load-library "myemacs"))
(if (file-readable-p (concat (getenv "HOME") "/emacs/mymail.el"))
    (load-library "mymail"))

; Load global and user keys
(load-library "global-keys")
(if (file-readable-p (concat (getenv "HOME") "/emacs/myglobal-keys.el"))
    (load-library "myglobal-keys"))

; Skip to matching paren
(defun my::skip-to-matching-paren (arg)
  "Skip to matching paren if on paren or insert \\[skip-to-matching-paren]"
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
	((looking-at "\\s\)") (forward-char 1) (backward-list 1))
	(t (self-insert-command (or arg 1)))))

; Tab width
(setq tab-width 3)

; Set highlighting on mark-mode properly
;(pc-selection-mode)

; Place the entire path/filename on window frame.
(setq frame-title-format
      '("%S: " (buffer-file-name "%f" (dired-directory dired-directory "%b"))))

; Don't need a scratch message
(setq initial-scratch-message nil)

; Disable message logging
(setq message-log-max nil)
(kill-buffer "*Messages*")
;(setq message-log-max 50)

; Define toggle-truncate-lines
(defun toggle-truncate-lines () (interactive)
  (setq truncate-lines (not truncate-lines)))

; Make man window active when invoked
(setq Man-notify-method 'pushy)

; Set .emacs-bak as backup dir
(load-library "bakupdir")

; Emacs's standard method for making buffer names unique adds <2>, <3>, ...
;(load-library "uniquify")

; Hooks
(load-library "c-hook")
(load-library "cperl-hook")
(load-library "cvs-hook")
(load-library "go-hook")
(load-library "java-hook")
(load-library "lisp-hook")
(load-library "mail-hook")
(load-library "make-hook")
(load-library "sh-hook")
(load-library "shell-hook")
(load-library "sql-hook")

; Modes
(load-library "fit-mode")
(load-library "php-mode")
(load-library "status-mode")

; Printing
(load-library "prsrc")
