;; File: fit-mode.el
; last revised: Dan Waldheim, 03-Mar-2004

(setq auto-mode-alist (append '(("\\.fit$" . fit-mode)) auto-mode-alist))
(setq indent-tabs-mode t)

(defvar fit-mode-hook nil)
(defvar fit-mode-map
  (let ((fit-mode-map (make-keymap)))
	 (define-key fit-mode-map [(control c) (control v)] 'my::fit-v)
	 (define-key fit-mode-map [(control c) (control s)] 'my::fit-s)
	 (define-key fit-mode-map [(control c) (control d)] 'my::fit-d)
    fit-mode-map)
  "Keymap for fit major mode")

(defun fit-setup-face (face fg)
  (progn
	 (make-face face)
	 (set-face-foreground face fg)
	 ))

(fit-setup-face 'font-lock-fit-activity-face "cyan")
(fit-setup-face 'font-lock-fit-inactivity-face "red")
(fit-setup-face 'font-lock-fit-dont-count-face "slate grey")
(fit-setup-face 'font-lock-fit-date-face "palevioletred1")
(defvar font-lock-fit-activity-face 'font-lock-fit-activity-face
  "Face name to use for fit-mode activities.")
(defvar font-lock-fit-inactivity-face 'font-lock-fit-inactivity-face
  "Face name to use for fit-mode periods.")
(defvar font-lock-fit-dont-count-face 'font-lock-fit-dont-count-face
  "Face name to use for fit-mode underscores.")
(defvar font-lock-fit-date-face 'font-lock-fit-date-face
  "Face name to use for fit-mode dates.")

(defconst fit-font-lock-keywords
  (list
 '("^\\w\\w\\w [0-9][0-9]\\(\t[^ \t\n]+\\(\t[^ \t\n]+\\)?\\(\t[^ \t\n]+\\)?\\(\t[^ \t\n]+\\)?\\(\t[^ \t\n]+\\)?\\(\t[^ \t\n]+\\)?\\(\t[^ \t\n]+\\)?\\)" 1 font-lock-fit-activity-face)
 '("\\(\\.[\t$\n]\\)" 1 font-lock-fit-inactivity-face t)
 '("\\(_[\t$\n]\\)" 1 font-lock-fit-dont-count-face t)
 '("^\\(Jan \\|Feb \\|Mar \\|Apr \\|May \\|Jun \\|Jul \\|Aug \\|Sep \\|Oct \\|Nov \\|Dec \\)[0-9][0-9]" . font-lock-fit-date-face)
)
  "Minimal highlighting expressions for fit mode.")

(defvar fit-font-lock-keywords fit-font-lock-keywords
  "Default highlighting expressions for fit mode.")

(defun fit-mode ()
  "Major mode for editing fit data files.\n
   LEGEND is provided within the file to aid the fit.pl processing.
   Use \"C-c C-v\" to see your current level of fit-ness.
   Use \"C-c C-s\" to see a by-month summary of fit-ness.
   Use \"C-c C-d\" to do a fit-diff of fit files."
  (interactive)
  (kill-all-local-variables)
  (use-local-map fit-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(fit-font-lock-keywords))
  (setq major-mode 'fit-mode)
  (setq mode-name "FIT")
  (run-hooks 'fit-mode-hook))

(add-hook 'fit-mode-hook
			 (function (lambda()
							 (setq tab-width 4)
							 (font-lock-mode 1)
							 (setq truncate-lines t)
							 (make-local-variable 'find-file-hooks)
							 (add-hook 'find-file-hooks 'my::fit-position-cursor t)
							 )))

;----- run-fit functions

(defun my::fit-v ()
  "display fit totals in other window"
  (interactive)
  (my::run-fit "-v")
)

(defun my::fit-s ()
  "display fit totals in other window"
  (interactive)
  (my::run-fit "-s")
)

(defun my::fit-d (file)
  "display fit diff statistics in other window"
  (interactive "fDiff against file: ")
  (my::run-fit "-d" (expand-file-name file))
)

(defun my::run-fit (option &optional file2)
  "display fit totals in other window"
  (interactive)
  (let ((conf (current-window-configuration))
		  (buffer (generate-new-buffer "*fit*"))
		  (tfile (concat "/tmp/" (make-temp-name "fit-")))
		  (file2 (or file2 ""))
		  )
    (with-output-to-temp-buffer (buffer-name buffer)
      (progn
		  (write-region (point-min) (point-max) tfile nil 0)
		  (call-process (concat (getenv "PUB") "/src/fit.pl")
							 nil 
							 buffer
							 t
							 option
							 tfile
							 file2
							 ;(buffer-file-name (current-buffer))
							 )
		  (delete-file tfile)
		  ))
	 (shrink-window-if-larger-than-buffer (other-window 1))
    (if (my::comint-restore-window-config conf)
		  (kill-buffer buffer))
	 ))

(defun my::fit-position-cursor ()
  "move cursor to probable position of next input"
  (interactive)
  (or
	; find next fit mode entry location
	(and
	 ; go to end of file
	 (goto-char (point-max))
	 ; back up to the last completed (7-entry) line
	 (re-search-backward
	  (concat
		"^\\w\\w\\w [0-3][0-9]"
		"\t[^\t\n]+\t[^\t\n]+\t[^\t\n]+\t[^\t\n]+\t[^\t\n]+\t[^\t\n]+\t[^\t\n]+")
	  0 t)
	 ; goto next line
	 (progn (next-line 1) t)
	 ; goto first \t\t on line or end of line
	 (progn 
		(forward-line 1)
		(let ((eoline (point)))
		  (forward-line -1)
		  (or
			(and (re-search-forward "\t\t" eoline t)
				  (progn (backward-char 1) t))
			(end-of-line)
			)
		  )
		t)
	 )
	; couldn't find (7-entry) line, perhaps its start of year, find first empty
	(and
	 (progn (goto-char (point-min)) t)
	 (re-search-forward "^\\w\\w\\w [0-3][0-9]" (point-max) t)
	 (progn (end-of-line) t)
	 )
	; couldn't find jack, beginning of buffer
	(goto-char 0)
	)
)

(provide 'fit-mode)
