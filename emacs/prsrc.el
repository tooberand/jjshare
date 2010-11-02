(defun prsrc-d-buffer ()
  "Print buffer contents with prsrc -d"
  (interactive)
  (prsrc-region-1 (point-min) (point-max) (buffer-name) "-d"))

(defun prsrc-d-region (start end)
  "Print region contents with prsrc -d."
  (interactive "r")
  (prsrc-region-1 start end (concat "region from: " (buffer-name)) "-d"))

(defun prsrc-1-buffer ()
  "Print buffer contents with prsrc -1"
  (interactive)
  (prsrc-region-1 (point-min) (point-max) (buffer-name) "-1"))

(defun prsrc-1-region (start end)
  "Print region contents with prsrc -1."
  (interactive "r")
  (prsrc-region-1 start end (concat "region from: " (buffer-name)) "-1"))

(defun prsrc-5-buffer ()
  "Print buffer contents with prsrc -1"
  (interactive)
  (prsrc-region-1 (point-min) (point-max) (buffer-name) "-1 -p5"))

(defun prsrc-5-region (start end)
  "Print region contents with prsrc -1."
  (interactive "r")
  (prsrc-region-1 start end (concat "region from: " (buffer-name)) "-1 -p5"))

(defun prsrc-buffer ()
  "Print buffer contents with prsrc"
  (interactive)
  (prsrc-region-1 (point-min) (point-max) (buffer-name)))

(defun prsrc-region-1 (start end header &rest args)
  (let ((width tab-width))
    (save-excursion
      (message "Spooling...")

		;(print-region-new-buffer) could be useful for enhancements, see lpr.el
;      (apply 'call-process-region start end "prsrc" nil t t ; for debug
      (apply 'call-process-region start end
				 "/Users/dwaldhei/Public/bin/prsrc" nil nil nil
			   (concat "-t" (int-to-string tab-width))
			   (concat "-h" "'" header "'")
				args)

      (if (markerp end)
	  (set-marker end nil))
      (message "Spooling...done"))))

(defun prsrc-region (start end)
  "Print region contents with prsrc."
  (interactive "r")
  (prsrc-region-1 start end (concat "region from: " (buffer-name))))
;  (prsrc-region-1 start end (concat "region from: " (buffer-name)) "" "" ))

(defun prsrc-region-2 (start end header &rest args)
  (let ((width tab-width))
    (save-excursion
      (message "Spooling...")

		;(print-region-new-buffer) could be useful for enhancements, see lpr.el
      (apply 'call-process-region start end "cat" nil t t ; for debug
;      (apply 'call-process-region start end "cat" nil nil nil
			   (concat "-t" (int-to-string tab-width))
			   (concat "-h" "'" header "'")
				args)
				
				(if (markerp end)
					 (set-marker end nil))
				(message (concat "Spooling...done[" (int-to-string start) ) ))) )
  

;(apply 'call-process-region 0 10 "cat" nil t t (concat "-t" 3)
;		 (concat "-h" "'" "FILE NAME" "'")  args)
;(call-process-region 0 10 "cat" '(+ 1 2) t t (concat "-t" 3) "-h" args)
;(call-process-region "0" "10" "cat" nil t t "" "-h" "")



