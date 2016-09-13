;;; critic --- Minor mode for CriticMarkup

;;; Commentary:



;;; Code:
(defconst critic-addition-regex "{\\+\\+\\(.*?\\)\\+\\+}"
  "Regex for additions.  Group 1 is the text to be added.")

(defconst critic-deletion-regex "{--\\(.*?\\)--}"
  "Regex for deletion.  Group 1 is the text to be deleted.")

(defconst critic-substitution-regex "{~~\\(.*?\\)~>\\(.*?\\)~~}"
  "Regex for substitution.  Group 1 is the original text.  Group 2 is the replacement text."  )

(defconst critic-comment-regex "{>>\\(.*?\\)<<}"
  "Regex for comments.  Group 1 is the comment text.")

(defconst critic-highlight-regex "{==\\(.*?\\)==}{>>\\(.*?\\)<<}"
  "Regex for highlights.  Group 1 is the highlighted text.  Group 2 is the comment text.")

(defun critic--font-lock-keywords ()
  "Get list of `font-lock' keywords."
  `((,critic-addition-regex 0 font-lock-preprocessor-face t)
    (,critic-deletion-regex 0 font-lock-warning-face t)
    (,critic-substitution-regex 0 font-lock-function-name-face t)
    (,critic-highlight-regex 0 highlight t)
    (,critic-comment-regex 0 font-lock-comment-face t)))

(defun critic-font-lock ()
  "Toggle critic syntax highlightning."
  (interactive)
  (if (get 'critic-font-lock 'state)
      (progn
        (font-lock-add-keywords nil (critic--font-lock-keywords))
        (put 'critic-font-lock 'state nil))
    (font-lock-remove-keywords nil (critic--font-lock-keywords))
    (put 'critic-font-lock 'state t))
  (font-lock-fontify-buffer))

(define-minor-mode critic-minor-mode
  "Minor mode for CriticMarkdown."
  :lighter " critic"
  (critic-font-lock))

(provide 'critic)
;;; critic.el ends here
