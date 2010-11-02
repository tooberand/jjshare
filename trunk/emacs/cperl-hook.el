; File: perl-hook.el
; last revised: Dan Waldheim, 17-Jan-2003

(load-library "cperl-mode")

; Recommended by cperl-mode install page
(add-to-list 'auto-mode-alist '("\\.\\([pP][Llm]\\|al\\|t\\)\\'" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl5" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("miniperl" . cperl-mode))

(setq cperl-style-alist
		(append
		 '(("Waldheim"
			 (cperl-indent-level               .  3)
			 (cperl-brace-offset               .  0)
			 (cperl-continued-brace-offset     . -3)
			 (cperl-label-offset               . -3)
			 (cperl-continued-statement-offset .  3)
			 (cperl-merge-trailing-else	       .  nil)
			 (cperl-extra-newline-before-brace .  t)))
			cperl-style-alist))

(cperl-set-style "Waldheim")

; Set the font lock and use good tab widths
(add-hook 'cperl-mode-hook
			 (function (lambda ()
							 (font-lock-mode 1)
							 (setq cperl-font-lock t)
							 (setq perl-indent-level 3)
							 (setq tab-width 3)
							 (setq cperl-indent-level 3)
							 (setq cperl-continued-statement-offset 3)
;							 (setq cperl-brace-offset -3)
							 (setq cperl-brace-offset 0)
							 (local-set-key [(control tab)]
												 (function (lambda () (interactive)
																 (insert "\t"))))
							 )))

; (setq cperl-mode-hook nil)

; Remove gaudy italics and bold
(custom-set-faces
 '(cperl-array-face ((t (:background "navy" :foreground "yellow"))))
 '(cperl-hash-face ((t (:background "navy" :foreground "Red")))))
