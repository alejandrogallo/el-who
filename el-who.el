;;; el-who.el --- A s-expression html DSL library compatible with cl-who  -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Alejandro Gallo

;; SPDX-License-Identifier: MIT
;; Author: Alejandro Gallo <aamsgallo@gmail.com>
;; Version: 1.0
;; Keywords: lisp, hypermedia, docs, tools, html, web
;; Package-Requires: ((emacs "25.1"))
;; URL: https://github.com/alejandrogallo/p5js

;;; Commentary:

;; This package provides a html DSL built after the common lisp
;; library CL-WHO (https://edicl.github.io/cl-who/).  You can mostly
;; reuse the cl-who snippets with el-who, and this should be the main
;; leitmotiv of this package.

;;; Code:

(require 'cl-lib)

(defun el-who (tree)
  "Create an html string representation of the s-expression TREE."
  (cl-flet ((kwd-name (kwd) (substring (symbol-name kwd) 1)))
    (pcase tree
      ((and `(,tag . ,rest)
            (guard (keywordp tag)))
       (let ((i 0)
             (void-tag-p (member tag '(:input
                                       :br
                                       :img))))
         (string-join
          (append

           ;; Write beginning tag
           (list (format "<%s" (kwd-name tag)))

           ;; Write attributes if any
           (let ((attrs
                  (cl-loop for (k v) on rest by #'cddr
                        collect
                        (pcase k
                          ((guard (keywordp k))
                           (prog1 (when v
                                    (cond
                                      ((eq v t) (format "%s"
                                                        (kwd-name k)))
                                      (t
                                       (format "%s=%S" (kwd-name k) v))))
                             (cl-incf i)
                             (cl-incf i)))
                          ;; if there is no match return immediately
                          (_ (return))))))
             (when attrs
               (list (concat " "
                             (string-join attrs " ")))))


           ;; Write a closing > tag if it's a normal tag
           ;; or /> if it's a ,,void-tag''
           (list (if void-tag-p "/>\n" ">\n"))

           ;; render the body of the tag
           (cl-loop for j from i to (length rest)
                 collect (el-who (nth j rest)))

           ;; close the tag properly if we have to
           (unless void-tag-p
             (list (format "\n</%s>\n" (kwd-name tag))))))))

      ;; if it's an atom, just get the formatted version of it
      ((and (pred atom)
            (guard (not (null tree))))
       (format "%s" tree))

      ;; if it's something resembling a lisp call, just evaluate the
      ;; tree and pass the return value through el-who again
      ((and `(,form-name . ,body)
            (guard (symbolp form-name)))
       (el-who (eval tree))))))


(provide 'el-who)

;;; el-who.el ends here
