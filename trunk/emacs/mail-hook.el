; File: mail-hook.el
; last revised: Dan Waldheim, 11-Jan-2003

; Allow abbrevs to expand on \C-n
(add-hook 'mail-mode-hook
			 (lambda ()
				(setq tab-width 3)
				(turn-on-font-lock)
				(mail-abbrevs-setup)
				(substitute-key-definition
				 'next-line 'mail-abbrev-next-line
				 mail-mode-map global-map)
				))

; Setup new sendmail program
(setq sendmail-program (concat (getenv "PUB") "/bin/gsendmail.pl"))
