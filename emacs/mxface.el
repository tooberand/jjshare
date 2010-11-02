; File: mxface.el
; last revised: Alan Switzer,  4-Nov-1997

;; Check if xface should be inserted when sending mail
(add-hook 'mail-send-hook 'my::insert-xface-check)

(defvar my::xface-check-regexp 
  "switzer\\|waldhei\\|snarayan\\|ckat\\|easter\\|dlove\\|eric@pine")
(defvar my::xface-check-regexp-no-send nil)
(defvar my::xface "")

;; Note: If my::xface-check-regexp and/or my::xface are unset, this does
;; nothing... which is good
(defun my::insert-xface-check ()
  "Insert XFace for superior mail recipients"
  (progn
	(mail-to)
	(if
		(and
		 (progn 
		   (mail-to) 
		   (re-search-backward my::xface-check-regexp (point-min) t))
		 (progn
		   (mail-to)
		   (not
			(and
			 my::xface-check-regexp-no-send
			 (re-search-backward my::xface-check-regexp-no-send
								 (point-min) t))))
		 )
		 (my::insert-x-face)
		 )))

(defun my::insert-x-face ()
  (save-excursion 
    (goto-char (point-min))
    (search-forward mail-header-separator)
    (beginning-of-line nil)
	 (insert my::xface)))

(defun my::get-file-contents (filename)
  "Returns file contents as string."
  (unwind-protect
      (save-excursion
	(set-buffer (setq buf (get-buffer-create " *file-contents-tmp*")))
	(buffer-disable-undo (current-buffer))
	(erase-buffer)
	(insert-file-contents filename)
	(setq data (buffer-string))
	(erase-buffer))
    (and buf (kill-buffer buf)))
  data)

;; Set this function in your local setup to the full path of your xface
(defun mxface-set-xface (filename)
  "Set the current XFace using a full path to a .xf file"
  (progn
	(setq my::xface (concat "X-Face: " (my::get-file-contents filename)))
  ))
