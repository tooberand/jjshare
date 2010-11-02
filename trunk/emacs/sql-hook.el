; File: sql-hook.el
; last revised: Dan Waldheim, 21-Jan-2003

(add-hook 'sql-mode-hook
			 (function (lambda ()
							 (turn-on-font-lock)
							 (setq tab-width 3)
							 )))
