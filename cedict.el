(defvar cedict-db-file "cedict-db.el")
(defvar cedict-dictionary nil)

(setq cedict-dictionary nil)

(defun cedict-read-dictionary (filename)
  (with-temp-buffer 
    (insert-file-contents filename)
    (setq cedict-dictionary (read (current-buffer)))))
				  

(defun cedict ()
  (interactive)
  (if (not cedict-dictionary)
      (if (file-exists-p cedict-db-file)
	  (when (y-or-n-p (format "Load dictionary data from %s? " cedict-db-file))
	    (cedict-read-dictionary cedict-db-file))
	(let ((db-file-name (file-truename (read-file-name "Choose dictionary to load: "
							   default-directory default-directory t))))
	  (setq cedict-db-file db-file-name)
	  (cedict-read-dictionary db-file-name)))))


(defun cedict-search (&optional word-name)
  (interactive "sSearch for: ")
  (lexical-let ((b (get-buffer-create "*cedict*"))
		(found-words ()))
    (set-buffer b)
    (delete-region (point-min) (point-max))
    (dolist (entry cedict-dictionary)
      (let ((en-words-cur (caddr entry)))
	(dolist (word en-words-cur)
	  (if (string-match word-name word)
	      (push word found-words)
	    ))))
    (lexical-let ((sorted-words (sort found-words (lambda (first second) (let ((fp (string-match word-name first))
     						   (sp (string-match word-name second))
     						   (fl (length first))
     						   (sl (length second)))
     					       (> (+ sl sp) (+ fl fp)))))))
      (dolist (word sorted-words) (insert (format "%s\n" word)))
    (pop-to-buffer b))))



	  
						


