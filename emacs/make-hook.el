; File: make-hook.el
; last revised: Dan Waldheim, 29-Jan-2003

(add-hook 'makefile-mode-hook
			 (function (lambda ()
							 (turn-on-font-lock)
							 (setq tab-width 3)
							 )))
