; File: .emacs
; last revised: Dan Waldheim, 30-Oct-2010
; Emacs for Mac from http://emacsformacosx.com/

; Environment settings
;(setenv "PUB" "/Users/dwaldhei/dev/jjshare")
(setenv "PUB" (if (file-readable-p (concat (getenv "HOME") "/dev/jjshare"))
						(concat (getenv "HOME") "/dev/jjshare")
					   (concat (getenv "HOME") "/jjshare")))

; Additions to /usr/share/man for perl and mysql
;(setenv "MANPATH" "usr/bin/man:/usr/local/man:/usr/share/man:/usr/X11R6/man")
(setenv "MANPATH" "/usr/share/man:/usr/X11R6/man")
(setenv "LC_ALL" "C") ; for perl

; Start the Process
(load-file (concat (getenv "PUB") "/emacs/emacs.el"))

(shell) (rename-buffer "sql")

;(setq mac-allow-anti-aliasing nil)

; Gnu Emacs Custom -- DO NOT EDIT
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(cua-mode nil)
 '(show-paren-mode nil)
 '(tool-bar-mode nil nil (tool-bar))
 '(transient-mark-mode t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
; '(default ((t (:stipple nil :background "black" :foreground "green" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 110 :width normal :family "apple-monaco"))))
 '(default ((t (:stipple nil :background "black" :foreground "green" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 107 :width normal :family "Hack" :foundry "unknown"))))
; '(default ((t (:stipple nil :background "black" :foreground "green" :famil "apple-monaco"))))
 '(cperl-array-face ((t (:background "navy" :foreground "yellow"))))
 '(cperl-hash-face ((t (:background "navy" :foreground "Red"))))
 '(cursor ((t (:background "red"))) t)
 '(font-lock-comment-delimiter-face ((default (:inherit font-lock-comment-face)) (((class color) (min-colors 8) (background dark)) (:foreground "dim gray"))))
 '(font-lock-comment-face ((((class color) (min-colors 88) (background dark)) (:foreground "dim gray")))))

; Load user emacs and mail specifics if exists and readable
(if (file-readable-p (concat (getenv "HOME") "/emacs/myemacs.el"))
    (load-library "myemacs"))
(if (file-readable-p (concat (getenv "HOME") "/emacs/mymail.el"))
    (load-library "mymail"))
