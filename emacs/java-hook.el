; File: java-hook.el
; last revised: Sada Narayanappa, 17-Aug-2004

(add-hook 'java-mode-hook
			 (function (lambda ()
							 (turn-on-font-lock)
							 (setq tab-width 3)
							 (setq java-indent-level 3)
							 (setq c-basic-offset 3)
							 )))

(setq auto-mode-alist (append '(("\\.as$" . java-mode)) auto-mode-alist))
(font-lock-fontify-buffer)