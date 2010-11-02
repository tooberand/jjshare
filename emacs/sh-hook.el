; File: sh-hook.el
; last revised: Dan Waldheim, 02-May-2003

(add-hook 'sh-mode-hook
			 (function (lambda ()
							 (turn-on-font-lock)
							 (setq tab-width 3)
							 )))
