(eval-when-compile
  (require 'cl-lib))
(require 'ht)
(require 'dash)
(defvar iabbrev-table (ht<-alist '(("ZZ" . "\\mathbb{Z}")
                                   ;; ("<" . "\\langle")
                                   ;; (">" . "\\rangle")
                                   ("NN" . "\\mathbb{N}")
                                   ("\\empty" . "\\emptyset")
                                   ("LL" . "\\mathcal{L}")
                                   ("XX" . "\\mathcal{X}")
                                   ("UU" . "\\bigcup")
                                   ("SS" . "\\mathcal{S}")
                                   ("\\iff" . "\\Leftrightarrow")
                                   ("\\rangle=" . "\\geq")
                                   ("\\langle=" . "\\leq")
                                   ("=\\rangle" . "\\Rightarrow")
                                   ("<=" . "\\leq")
                                   (">=" . "\\geq")
                                   ("->" . "\\to")
                                   ("\\prec" . "\\preceq")
                                   ("QQ" . "\\mathbb{Q}")
                                   ("RR" . "\\mathbb{R}")
                                   ("PP" . "\\mathcal{P}")
                                   ("\\sub" . "\\subseteq")
                                   ("=>" . "\\Rightarrow")
                                   ("\\{" . "\\{\\}")
                                   ("and" . "\\wedge")
                                   ("..." . "\\ldots"))))
(defun iabbrev-update-function (text expansion beg end)
  ;; make this into a proper advice function
  (pcase text
    ((or "and" "or") (when (texmathp)
                       (progn
                         (delete-region beg end)
                         (insert expansion))))
    ("\\{"
     (progn
       (delete-region beg end)
       (insert expansion)
       (backward-char 2)))
    (_ (progn
         (delete-region beg end)
         (insert expansion)))))
(defun iabbrev-if-abbrev-expand ()
  (let ((abbrev-max-length (-max (-map #'length (ht-keys iabbrev-table)))))
    (cl-loop for len downfrom abbrev-max-length to 1
             for end = (point)
             for beg = (- end len)
             for text = (buffer-substring beg end)
             for expansion = (ht-get iabbrev-table text)
             if expansion
             do (iabbrev-update-function text expansion beg end)
             and return t)))
(defun add-iabbrev (abbrev expansion)
  (ht-set iabbrev-table abbrev expansion))
(defun remove-iabbrev (abbrev)
  (ht-remove iabbrev-table abbrev))
(defun add-local-iabbrev-hook ()
  (add-hook 'post-self-insert-hook #'iabbrev-if-abbrev-expand nil 'local))
(add-hook 'TeX-mode-hook #'add-local-iabbrev-hook)

;; examples
;; (add-iabbrev "<=" "\\leq")
;; (add-iabbrev "CC" "\\mathbb{C}")
;; (remove-iabbrev "CC")

;; swap-text
(defvar swap-table (ht-create))
(defun cycle->alist (cycle)
  (cl-loop for pair in (-zip cycle (-rotate -1 cycle))
           collect pair))
(defun swap-add-cycle (cycle)
  (cl-loop for (prev . next) in (cycle->alist cycle)
           do (ht-set swap-table prev next)))
(defun swap-if-in-cycle ()
  (interactive)
  (let ((cycle-text-max-length (-max (-map #'length (ht-keys swap-table)))))
    (cl-loop for len downfrom cycle-text-max-length to 1
             for end = (point)
             for beg = (- end len)
             for text = (buffer-substring beg end)
             for expansion = (ht-get swap-table text)
             if expansion
             do (progn
                  (delete-region beg end)
                  (insert expansion))
             and return t)))
;; (ht-set swap-table "sub" "\\subseteq")
;; (ht-set swap-table "\\sub" "\\subseteq")
;; (ht-set swap-table "\\subseteq" "sub")
(-map #'swap-add-cycle '(
                         ;; ("=" "\\equiv" "\\approx")
                         ("=" "\\cong")
                         ("|^" "\\restrict")
                         ("<" "\\langle \\rangle")
                         ("|" "\\mid")
                         ("a" "\\alpha")
                         ("A" "\\alpha")
                         ("b" "\\beta")
                         ("B" "\\beta")
                         ("U" "\\cup" "\\bigcup")
                         ("p" "\\phi")
                         ("d" "\\delta")
                         ("g" "\\gamma")
                         ("k" "\\kappa")
                         ("m" "\\mu")
                         ("n" "\\nu")
                         ("(" "\\left(")
                         (")" "\\right)")
                         ("o" "\\omega")
                         ("dom" "\\text{dom}")
                         (">" "\\rangle")
                         ("\\sub" "\\subseteq" "\\subsection*" "\\subsetneq")
                         ("\\leq" "\\Leftarrow")
                         ("em" "\\emptyset")
                         ("l" "\\lambda")
                         ("s" "\\sigma")
                         ("and" "\\wedge")
                         ("or" "\\vee")
                         ("*" "\\times" "\\circ" "\\cdot")
                         ("\\Rightarrow" "\\implies")
                         ("<=" "\\leq" "\\preceq" "\\Leftarrow")))
(define-key TeX-mode-map (kbd "TAB") #'swap-if-in-cycle)

;; next feature is deleting symbols together, like \mathbb{Z}, in one delete. add advice to delete
