; File: lisp-hook.el
; last revised: Dan Waldheim, 11-Jan-2003

(add-hook 'lisp-mode-hook
	  (function (lambda ()
		      (setq tab-width 3)
		      (font-lock-mode 1)
		      )))

(add-hook 'emacs-lisp-mode-hook
	  (function (lambda ()
		      (setq tab-width 3)
		      (font-lock-mode 1)
		      )))
