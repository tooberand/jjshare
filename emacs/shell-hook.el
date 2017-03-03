; File: shell-hook.el
; last revised: Dan Waldheim, 03-Mar-2004

; Treat shells as pty's instead of pipes
(setq process-connection-type t)

(require 'comint)
;(setq comint-use-prompt-regexp t)
(defconst comint-input-ring-size 511)
(define-key comint-mode-map "\ep" 'comint-previous-matching-input-from-input)

; Create new faces for shell
(defun shell-setup-face (face fg)
  (progn
	 (make-face face)
	 (set-face-foreground face fg)
	 ))

(shell-setup-face 'my::shell-prompt-face "red")
(shell-setup-face 'my::isql-prompt-face "cyan")
(shell-setup-face 'my::vert-divider-face "palevioletred1")
(shell-setup-face 'my::shell-info-face "skyblue")
(shell-setup-face 'my::shell-warn-face "pink")
(shell-setup-face 'my::shell-error-face "red")

(defvar my::shell-prompt-face 'my::shell-prompt-face
  "Face name to use for shell-mode prompt")
(defvar my::isql-prompt-face 'my::isql-prompt-face
  "Face name to use for shell-mode isql prompt")
(defvar my::vert-divider-face 'my::vert-divider-face
  "Face name to use for shell-mode vertical divider")
(defvar my::shell-info-face 'my::shell-info-face
  "Face name to use for shell-mode informational messages")
(defvar my::shell-warn-face 'my::shell-warn-face
  "Face name to use for shell-mode warning messages")
(defvar my::shell-error-face 'my::shell-error-face
  "Face name to use for shell-mode error messages")

; Allows for customization of regexps
(defvar my::vert-divider-regexp "^----------------------$")
(defvar my::isql-prompt-regexp "^\\([0-9]+\\|SQL\\)> ")
(defvar my::comint-prompt-regexp "^\\\[[^]]*\\\] ")
(defvar my::comint-error-regexp "^\\(E\\(RROR\\|rror\\).*\\)")
(defvar my::comint-warn-regexp "^\\(W\\(ARN\\|arn\\).*\\)")
(defvar my::comint-info-regexp "^\\(I\\(NFO\\|nfo\\).*\\)")

(add-hook 'shell-mode-hook
	(function 
	 (lambda ()
		(setq font-lock-keywords
				(purecopy
				 (list
				  (cons my::comint-prompt-regexp 'my::shell-prompt-face)
				  (cons my::vert-divider-regexp 'my::vert-divider-face)
				  (cons my::isql-prompt-regexp 'my::isql-prompt-face)
				  (list my::comint-error-regexp 1 'my::shell-error-face t)
				  (list my::comint-warn-regexp 1 'my::shell-warn-face t)
				  (list my::comint-info-regexp 1 'my::shell-info-face t)
				  )))
		)))
;(setq shell-mode-hook nil)

; This came with comint-postout-scroll-to-bottom which Dan doesn't like
(setq comint-output-filter-functions '(comint-watch-for-password-prompt))

; Almost an exact copy of comint-restore-window-config except
; returns T/F result for hit space/didn't hit space.
(defun my::comint-restore-window-config (conf &optional message)
  ;; Don't obscure buffer being edited
  (or (eq (selected-window) (minibuffer-window))
      (message "%s" (or message "Press space to flush")))
  (sit-for 0)
  (if (if (fboundp 'next-command-event)
          ;; lemacs
          (let ((ch (next-command-event)))
            (if (eq (event-to-character ch) ?\ )
                t
                (progn (setq unread-command-event ch)
                       nil)))
          ;; v19 FSFmacs
          (let ((ch (read-event)))
            (if (eq ch ?\ )
                t
                (progn (setq unread-command-events (list ch))
                       nil))))
      (progn (set-window-configuration conf) t)
	 nil))

; Don't let process buffers be killed without confirmation
(defun my::kill-buffer-save-processes-query-function ()
  (or (not (get-buffer-process (current-buffer)))
      (yes-or-no-p (format "Buffer `%s' still has a running process; kill it? "
									(buffer-name (current-buffer))))))

(add-hook 'kill-buffer-query-functions 
			 'my::kill-buffer-save-processes-query-function)
