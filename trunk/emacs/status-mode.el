;; File: status-mode.el
; last revised: Dan Waldheim, 03-Mar-2004

(setq auto-mode-alist (append '(("\\.log$" . status-mode)) auto-mode-alist))

(defvar status-mode-hook nil)
(defvar status-mode-map nil
  "Keymap for status major mode")

(defun status-setup-face (face fg)
  (progn
	 (make-face face)
	 (set-face-foreground face fg)
	 ))

(status-setup-face 'font-lock-status-sep-line-face "red")
(status-setup-face 'font-lock-status-hrs-face "yellow")
(status-setup-face 'font-lock-status-date-face "cyan")
(status-setup-face 'font-lock-status-dot-face "magenta")
(status-setup-face 'font-lock-wk-ending-face "turquoise")
(defvar font-lock-status-sep-line-face 'font-lock-status-sep-line-face
  "Face name to use for status-mode vertical dividers.")
(defvar font-lock-status-hrs-face 'font-lock-status-hrs-face
  "Face name to use for status-mode hours.")
(defvar font-lock-status-date-face 'font-lock-status-date-face
  "Face name to use for status-mode dates.")
(defvar font-lock-status-dot-face 'font-lock-status-dot-face
  "Face name to use for status-mode dots.")
(defvar font-lock-status-wk-ending-face 'font-lock-status-wk-ending-face
  "Face name to use for status mode Week Ending.")

(defconst status-font-lock-keywords
  (list
	'("---+" . font-lock-status-sep-line-face)
	'("^[\t ]*\\*[\t ]" . font-lock-status-dot-face)
	'("^.*\\(Jan \\|Feb \\|Mar \\|Apr \\|May\\|Jun \\|Jul \\|Aug \\|Sep \\|Oct \\|Nov \\|Dec \\|January\\|February\\|March\\|April\\|June\\|July\\|August\\|September\\|October\\|November\\|December\\).*$" . font-lock-status-date-face)
	'("^.*\\(Jan\\|Feb\\|Mar\\|Apr\\|May\\|Jun\\|Jul\\|Aug\\|Sep\\|Oct\\|Nov\\|Dec\\)$" . font-lock-status-date-face)
	'("week ending.*" . font-lock-status-wk-ending-face)
	'("\\(-->.*hrs\\)" 1 font-lock-status-hrs-face t)
)
  "Minimal highlighting expressions for status mode.")

(defvar status-font-lock-keywords status-font-lock-keywords
  "Default highlighting expressions for status mode.")

(defun status-mode ()
  "Major mode for editing status data files.\n
   LEGEND is provided within the file to aid the status.pl processing.
   Use \"C-c C-v\" to see your current level of status-ness.
   Use \"C-c C-s\" to see a by-month summary of status-ness.
   Use \"C-c C-d\" to do a status-diff of status files."
  (interactive)
  (kill-all-local-variables)
  (use-local-map status-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(status-font-lock-keywords))
  (setq major-mode 'status-mode)
  (setq mode-name "STATUS")
  (run-hooks 'status-mode-hook))

(add-hook 'status-mode-hook
			 (function (lambda()
							 (setq tab-width 4)
							 (font-lock-mode 1)
							 (setq truncate-lines t)
							 (make-local-variable 'find-file-hooks)
							 )))

(provide 'status-mode)
