(defvar cedict-db-file "cedict-db.el")
(defvar cedict-dictionary nil)

(defface cedict-chinese-traditional-face
  '((t (:inherit font-lock-variable-name-face)))
  "Face for word in chinese traditional script."
  :version "23.1")

(defface cedict-chinese-simplified-face
  '((t (:inherit font-lock-constant-face)))
  "Face for word in chinese traditional script."
  :version "23.1")

(defface cedict-chinese-pinyin-face
  '((t (:inherit font-lock-function-name-face)))
  "Face for word in chinese traditional script."
  :version "23.1")

;(setq cedict-dictionary nil)

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

(defun cedict-format-zh (zh-simplified zh-traditional)
  (lexical-let ((zh-s (propertize zh-simplified 'face 'cedict-chinese-traditional-face))
		(zh-t (propertize zh-traditional 'face 'cedict-chinese-simplified-face)))
    (insert (format "%s %s\t" zh-s zh-t)))
  )

		
(defun cedict-format-py (py)
  (insert (format "%s\n" (propertize py 'face 'cedict-chinese-pinyin-face))))
 
(defun cedict-format-en (en-list)
  (dolist (en en-list)
    (insert (format "\t%s\n" en))))

(defun cedict-format-chinese (entry)
  (lexical-let ((zh (car entry))
		(py (caadr entry))
		(en (caddr entry)))
    (cedict-format-zh (car zh) (cadr zh))
    (cedict-format-py py)
    (cedict-format-en en)))
    
   
(defun cedict-insert-entry (zh)
  (cedict-format-zh (car zh) (cadr zh)))

  ;; (insert (format "%s\n" zh))
  ;; (dolist (meanings (map 'list (lambda (str) (propertize str 'face 'mode-line-emphasis)) (caddr entry)))
  ;;   (insert (format "\t%s\n" meanings))))

(defun cedict-search (&optional word-name)
  (interactive "sSearch for: ")
  (lexical-let ((b (get-buffer-create "*cedict*"))
		(found-entries ()))
    (set-buffer b)
    (delete-region (point-min) (point-max))
    (dolist (entry cedict-dictionary)
      (let ((en-words-cur (caddr entry)))
	(dolist (word en-words-cur)
	  (if (string-match word-name word)
	      (push `(,word ,entry) found-entries)))))
    (lexical-let ((sorted-entries
		   (sort found-entries 
			 (lambda (f s)
			   (lexical-let* ((first (car f))
				  (second (car s))
				  (fp (string-match word-name first))
				  (sp (string-match word-name second))
				  (fl (length first))
				  (sl (length second)))
			     (> (+ sl sp) (+ fl fp)))))))
      (dolist (entry sorted-entries) (cedict-format-chinese (cadr entry)))
      (goto-char (point-min))
      (pop-to-buffer b))))



	  
						


