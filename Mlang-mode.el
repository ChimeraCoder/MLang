(require 'derived)
(require 'font-lock)

(defvar mlang-mode-hook nil)

(define-key global-map (kbd "RET") 'newline-and-indent)

(defvar mlang-mode-map
  (let ((map (make-keymap)))
    (define-key map "\C-j" 'newline-and-indent)
    map)
  "Keymap for Mlang major mode")

;;;###highlight words
(defconst mlang-font-lock-keywords-1
  (list 
    '("\\(ATOM\\|BODY\\|C\\(?:AR\\|DR\\|HANNEL\\|ON[DS]\\)\\|DEC\\|EQUAL\\|HEAD\\|INC\\|L\\(?:A\\(?:BEL\\|MBDA\\|ST\\)\\|ENGTH\\)\\|MAPCAR\\|NTH\\|\\(?:QUOT\\|\\(?:READ\\|WRITE\\)-FIL\\)E\\)" . font-lock-builtin-face))
  "Minimal highlighting of keywords")

(defvar mlang-font-lock-keywords mlang-font-lock-keywords-1 "Default highlighting")

;;;###Indentation
(defun mlang-indent-line ()
  "Indent lines"
  (interactive)
  (let ((indent-col 0))
  (save-excursion
    (beginning-of-line)
    (upcase-region (point-min) (point-max))
    (condition-case nil
	(while t
	  (backward-up-list)
	  (if (looking-at "(")
	      (setq indent-col (+ indent-col default-tab-width))))
      (error nil)))
  (save-excursion
    (back-to-indentation)
    (when (and (looking-at ")") (>= indent-col default-tab-width))
      (setq indent-col (- indent-col default-tab-width))))
  (indent-line-to indent-col)))


;;;###syntax table
(defvar mlang-mode-syntax-table 
  (let ((st (make-syntax-table)))
         (modify-syntax-entry ?\n ">b" st)
	 st)
  "Syntax table for mlang-mode")

(defun mlang-mode ()
  "Major mode for editing Mlang workflow"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table mlang-mode-syntax-table)
  (use-local-map mlang-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(mlang-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'mlang-indent-line)
  (setq major-mode 'mlang-mode)
  (setq mode-name "MLang")
  (run-hooks 'mlang-mode-hook))

(provide 'mlang-mode)

