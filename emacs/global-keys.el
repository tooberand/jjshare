; File: global-keys.el
; last revised: Dan Waldheim, 01-Nov-2010

; Make command key meta instead of alt (changed in v23)
(setq mac-option-key-is-meta nil)
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)

; Simple remaps
(global-set-key [(control 127)] 'backward-kill-word)
(global-set-key "\C-t" (function (lambda () (interactive) (recenter 0))))
(global-set-key "\M-t" (function (lambda () (interactive) (recenter -1))))
(global-set-key "\M-g" 'goto-line)
(global-set-key "\M-`" 'other-frame)
; This takes the place of what use to be fvwm control
(global-set-key "\M-J" (function (lambda () (interactive) (other-frame 1))))
(global-set-key "\M-L" (function (lambda () (interactive) (other-frame 1))))

; f keys specifictions
;(load-library "spell")
;(global-set-key [f8] 'spell-word)
(global-set-key [f9] 'call-last-kbd-macro)
(defvar compile-command "make")
(global-set-key [f12] (function
							  (lambda () (interactive) (compile compile-command))))

; Be nice about leaving emacs
(defun my-kill-emacs ()
  "Ask first before leaving emacs..."
  (interactive)
  (and (yes-or-no-p "Really exit? ")
       (save-buffers-kill-emacs)))

(define-key ctl-x-map "\C-c" 'my-kill-emacs)

; Comment and uncomment lines
(defun comment-line ()
  "Comment out a line"
  (interactive)
  (beginning-of-line)
  (insert comment-start))

(defun comment-or-uncomment-line ()
  "Comment or uncomment a line and go to next line"
  (interactive)
  (beginning-of-line)
  (if (not (search-forward-regexp 
				(concat "^" comment-start) 
				(+ (point) (length comment-start)) 
				t))
		(comment-line)
	 (beginning-of-line)
	 (delete-char (length comment-start)))
  (next-line 1))

(global-set-key '[(control 59)] 'comment-or-uncomment-line)

