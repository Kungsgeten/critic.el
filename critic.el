;;; critic.el --- Minor mode for CriticMarkup

;; Copyright (C) 2016 Erik Sjöstrand
;; MIT License

;; Author: Erik Sjöstrand
;; URL: http://github.com/Kungsgeten/critic.el
;; Version: 0.1
;; Keywords: wp
;; Package-Requires: ()

;;; Commentary:

;; Minor mode for CriticMarkup (http://criticmarkup.com).
;; Provides syntax highlightning through `font-lock-mode'.
;; Can query for addition/deletion/substitution with `critic-at-point'
;; or `critic-buffer'.

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

(defun critic-add (&optional force)
  "Maybe add critic markup at point.  Always add if FORCE is t."
  (when (looking-at critic-addition-regex)
    (if (or force (y-or-n-p "Add? "))
        (replace-match (match-string 1))
      (replace-match ""))))

(defun critic-delete (&optional force)
  "Maybe delete critic markup at point.  Always delete if FORCE is t."
  (when (looking-at critic-deletion-regex)
    (if (or force (y-or-n-p "Delete? "))
        (replace-match "")
      (replace-match (match-string 1)))))

(defun critic-substitute (&optional force)
  "Maybe substitute critic markup at point.  Always substutute if FORCE is t."
  (when (looking-at critic-substitution-regex)
    (if (or force (y-or-n-p "Substitute? "))
        (replace-match (match-string 2))
      (replace-match (match-string 1)))))

(defun critic-at-point (&optional force)
  "Maybe apply critic markup at point.  Always apply if FORCE is t."
  (interactive)
  (critic-add force)
  (critic-delete force)
  (critic-substitute force))

(defun critic-buffer ()
  "Go through critic markup in buffer and remove/apply."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (ignore-errors (search-forward-regexp
                           (concat "\\(" critic-addition-regex "\\|"
                                   critic-deletion-regex "\\|"
                                   critic-substitution-regex "\\)")))
      (goto-char (match-beginning 0))
      (critic-at-point))))

(defun org-critic-to-html (backend)
  "Convert CriticMarkyp in buffer to HTML, if BACKEND is html."
  (when (equal backend 'html)
    (while (re-search-forward critic-addition-regex nil t)
      (replace-match "@@html:<ins>@@\\1@@html:</ins>@@" nil nil))
    (goto-char (point-min))
    (while (re-search-forward critic-deletion-regex nil t)
      (replace-match "@@html:<del>@@\\1@@html:</del>@@" nil nil))
    (goto-char (point-min))
    (while (re-search-forward critic-substitution-regex nil t)
      (replace-match "@@html:<del>@@\\1@@html:</del><ins>@@\\2@@html:</ins>@@" nil nil))
    (goto-char (point-min))
    (while (re-search-forward critic-highlight-regex nil t)
      (replace-match
       "@@html:<mark>@@\\1@@html:</mark><span class=\"critic comment\">@@\\2@@html:</span>@@" nil nil))
    (goto-char (point-min))
    (while (re-search-forward critic-comment-regex nil t)
      (replace-match "@@html:<span class=\"critic comment\">@@\\1@@html:</span>@@" nil nil))))

;;;###autoload
(define-minor-mode critic-minor-mode
  "Minor mode for CriticMarkdown."
  :lighter " critic"
  (if critic-minor-mode
      (progn
        (font-lock-add-keywords nil (critic--font-lock-keywords))
        (when (equal major-mode 'org-mode)
          (add-hook 'org-export-before-parsing-hook 'org-critic-to-html)))
    (font-lock-remove-keywords nil (critic--font-lock-keywords))
    (when (equal major-mode 'org-mode)
      (remove-hook 'org-export-before-parsing-hook 'org-critic-to-html))))

(provide 'critic)
;;; critic.el ends here
