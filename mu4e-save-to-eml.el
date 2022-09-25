;; -*- lexical-binding: t; -*-

;;;###autoload 
(defun mu4e-save-to-eml (&optional msg dir)
  (interactive)
  (unless msg (setq msg (mu4e-message-at-point)))
  (cl-flet* ((get-display-name
	      (cell)
	      (if (car cell)
		  ;; try to use initials
		  (if-let ((initials (s-split " " (car cell) t)))
		      (cl-loop for initial in initials concat (when (substring initial 0 1)
								(substring initial 0 1)))
		    ;; otherwise just use the entire name 
		    (car cell))
		;; if there's no name field, use the address up to the @
		;; otherwise use the entire address
		(or (and (stringp (cdr cell))
			 (car (s-split "@" (cdr cell) t)))
		    (cdr cell)
		    "")))
	     (make-file-name (msg)
			     (s-replace "/" ""
					(let* ((msg (mu4e-message-at-point))
					       (to-field (plist-get msg :to))
					       (first-to (car to-field))
					       (to-etal-p (cdr to-field))
					       ;; if there is a name in the to field
					       (from (car (plist-get msg :from))))
					  (concat 
					   (format-time-string "%F" (mu4e-message-field msg :date))
					   " - "
					   (get-display-name from)
					   " to "
					   (get-display-name first-to)
					   (if to-etal-p " et al" "")
					   " - "
					   (or (mu4e-message-field msg :subject) "No subject")
					   ".eml")))))
    (copy-file
     (mu4e-message-field msg :path)
     (concat 
      (or dir
	  (read-directory-name "Copy message to: " "~/legal/Dropbox/" ))
      "/"
      (make-file-name msg))
     1)))

(provide 'mu4e-save-to-eml)
