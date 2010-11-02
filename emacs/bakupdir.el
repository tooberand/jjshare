; File: bakupdir.el
; last revised: Eric Waldheim, 26-Nov-1996

(load-library "dired")
(defvar my::backup-file-directory ".emacs-bak")

(defun make-backup-file-name (filename)
  "Eric's backup file naming scheme"
    (if (not (file-directory-p my::backup-file-directory))
	(make-directory my::backup-file-directory))
    (concat (expand-file-name my::backup-file-directory) "/"
	    (file-name-nondirectory filename) "~"))

(defun backup-file-name-p (file)
  "Return non-nil if FILE is a backup file name (numeric or not).
This is a separate function so you can redefine it for customization.
You may need to redefine `file-name-sans-versions' as well."
  (string-match (concat my::backup-file-directory ".*~") file))

(defun backup-file-name-p (file)
  "Return non-nil if FILE is a backup file name (numeric or not).
This is a separate function so you can redefine it for customization.
You may need to redefine `file-name-sans-versions' as well."
  (string-match ".*~" file))

;#####################
;#### for testing ####
;(make-backup-file-name "test")
;(backup-file-name-p "test")
;(backup-file-name-p (make-backup-file-name "test"))

(defun my::remove-version-dir (fn)
  (if
      (string-match (concat "/" my::backup-file-directory "/") fn)
      (concat
       (substring fn 0 (match-beginning 0))
       "/"
       (substring fn (match-end 0))
       )
    fn))

(defun file-name-sans-versions (name &optional keep-backup-version)
  "Return FILENAME sans backup versions or strings.
This is a separate procedure so your site-init or startup file can
redefine it.
If the optional argument KEEP-BACKUP-VERSION is non-nil,
we do not remove backup version numbers, only true file version numbers."
  (setq rvd-name (my::remove-version-dir name))
  (let
      ((handler (find-file-name-handler rvd-name 'file-name-sans-versions)))
    (if handler
	(funcall handler 'file-name-sans-versions rvd-name keep-backup-version)
      (substring rvd-name 0
		 (if (eq system-type 'vax-vms)
		     ;; VMS version number is (a) semicolon, optional
		     ;; sign, zero or more digits or (b) period, option
		     ;; sign, zero or more digits, provided this is the
		     ;; second period encountered outside of the
		     ;; device/directory part of the file name.
		     (or (string-match ";[-+]?[0-9]*\\'" rvd-name)
			 (if (string-match "\\.[^]>:]*\\(\\.[-+]?[0-9]*\\)\\'"
					   rvd-name)
			     (match-beginning 1))
			 (length rvd-name))
		   (if keep-backup-version
		       (length rvd-name)
		     (or (string-match "\\.~[0-9]+~\\'" rvd-name)
			 (string-match "~\\'" rvd-name)
			 (length rvd-name))))))))

;; I believe there is no need to alter this behavior for VMS;
;; since backup files are not made on VMS, it should not get called.
(defun find-backup-file-name (fn)
  "Find a file name for a backup file, and suggestions for deletions.
Value is a list whose car is the name for the backup file
 and whose cdr is a list of old versions to consider deleting now."
  (if (eq version-control 'never)
      (list (make-backup-file-name fn))
    (let* ((base-versions (concat (file-name-nondirectory fn) ".~"))
	   (bv-length (length base-versions)) ; used by backup-extract-version
	   possibilities
	   versions
	   high-water-mark
	   (deserve-versions-p nil)
	   number-to-delete)
      (condition-case ()
	  (setq possibilities (file-name-all-completions 
			       base-versions
                               (concat (file-name-directory fn)
				       my::backup-file-directory))
		versions (sort (mapcar #'backup-extract-version
                                       possibilities)
			       #'<)
		high-water-mark (apply #'max 0 versions)
		deserve-versions-p (or version-control
				       (> high-water-mark 0))
		number-to-delete (- (length versions)
				    kept-old-versions kept-new-versions -1))
	(file-error
	 (setq possibilities '())))
      (if (not deserve-versions-p)
	  (list (make-backup-file-name fn))
	(cons (concat (file-name-directory fn)
		      my::backup-file-directory
		      "/"
		      base-versions (int-to-string (1+ high-water-mark)) "~")
	      (if (and (> number-to-delete 0)
                       ;; Delete nothing if there is overflow
		       ;; in the number of versions to keep.
		       (>= (+ kept-new-versions kept-old-versions -1) 0))
		  (mapcar #'(lambda (n)
			      (concat 
			       (file-name-directory fn)
			       my::backup-file-directory
			       "/"
			       base-versions (int-to-string n) "~"))
                          (let ((v (nthcdr kept-old-versions versions)))
		            (rplacd (nthcdr (1- number-to-delete) v) ())
		            v))))))))


;#####################
;#### for testing ####
;(find-backup-file-name "/u/ewaldhe/lisp/test")
;(file-name-sans-versions "/u/ewaldhe/list/test.~3~")
;(file-name-sans-versions "/u/ewaldhe/list/.emacs-bak/test.~3~")
;(file-name-all-completions "test.~" (file-name-directory "/u/ewaldhe/lisp/test"))
;(file-name-all-completions "test.~" (concat (file-name-directory "/u/ewaldhe/lisp/test")  my::backup-file-directory))
;(setq version-control t)
;(let ((eric-bv-length (length "test.~")))
;(sort (mapcar #'backup-extract-version
;(file-name-all-completions "test.~" (concat (file-name-directory "/u/ewaldhe/lisp/test")  my::backup-file-directory)) ) #'<))
;(setq my::f "/u/ewaldhe/lisp/.emacs-bak/test.~3~")
;(setq my::f "/u/ewaldhe/lisp/test.~3~")
;(my::remove-version-dir my::f)
;(latest-backup-file "/u/ewaldhe/lisp/test")
;(dired-collect-file-versions "/u/ewaldhe/lisp/test")


(defun dired-collect-file-versions (fn)
  ;;  "If it looks like file FN has versions, return a list of the versions.
  ;;That is a list of strings which are file names.
  ;;The caller may want to flag some of these files for deletion."
    (let* ((base-versions
	    (concat (file-name-nondirectory fn) ".~"))
	   (bv-length (length base-versions))
	   (possibilities (file-name-all-completions
			   base-versions
			   (concat (file-name-directory fn) 
				   my::backup-file-directory)))
	   (versions (mapcar 'backup-extract-version possibilities)))
      (if versions
	  (setq file-version-assoc-list (cons (cons fn versions)
					      file-version-assoc-list)))))

;;>>> install (move this function into files.el)
(defun latest-backup-file (fn)	; actually belongs into files.el
  "Return the latest existing backup of FILE, or nil."
  ;; First try simple backup, then the highest numbered of the
  ;; numbered backups.
  ;; Ignore the value of version-control because we look for existing
  ;; backups, which maybe were made earlier or by another user with
  ;; a different value of version-control.
  (setq fn (expand-file-name fn))
  (or
   (let ((bak (make-backup-file-name fn)))
     (if (file-exists-p bak) bak))
   (let* ((dir (concat (file-name-directory fn) my::backup-file-directory))
	  (base-versions (concat (file-name-nondirectory fn) ".~"))
	  (bv-length (length base-versions)))
     (concat dir "/"
	     (car (sort
		   (file-name-all-completions base-versions dir)
		   ;; bv-length is a fluid var for backup-extract-version:
		   (function
		    (lambda (fn1 fn2)
		      (> (backup-extract-version fn1)
			 (backup-extract-version fn2))))))))))


(defun file-newest-backup (filename)
  "Return most recent backup file for FILENAME or nil if no backups exist."
  (let* ((filename (expand-file-name filename))
	 (file (file-name-nondirectory filename))
	 (dir  (concat (file-name-directory    filename) my::backup-file-directory))
	 (comp (file-name-all-completions file dir))
	 newest)
    (while comp
      (setq file (concat dir (car comp))
	    comp (cdr comp))
      (if (and (backup-file-name-p file)
	       (or (null newest) (file-newer-than-file-p file newest)))
	  (setq newest file)))
    newest))

