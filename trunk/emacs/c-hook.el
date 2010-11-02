; File: c-hook.el
; last revised: Dan Waldheim, 14-Jan-2003

(add-to-list 'auto-mode-alist '("\\.\\([cC][pP][pP]\\)\\'" . c-mode))

(add-hook 'c-mode-hook
			 (function (lambda ()
							 (turn-on-font-lock)
							 (setq tab-width 3)
							 )))
