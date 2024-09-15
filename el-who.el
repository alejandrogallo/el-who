;;; el-who.el --- A s-expression html DSL library compatible with cl-who  -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Alejandro Gallo

;; SPDX-License-Identifier: MIT
;; Author: Alejandro Gallo <aamsgallo@gmail.com>
;; Version: 1.0
;; Keywords: lisp, hypermedia, docs, tools, html, web
;; Package-Requires: ((emacs "25.1"))
;; URL: https://github.com/alejandrogallo/p5js

;;; Commentary:

;; This package provides a html DSL built after the common Lisp
;; library CL-WHO (https://edicl.github.io/cl-who/).  You can mostly
;; reuse the cl-who snippets with el-who, and this should be the main
;; leitmotiv of this package.

;;; Code:

(require 'cl-lib)


(defun el-who--engine (tree)
  "Write a HTML representation of the s-expression TREE in the current buffer.

It writes the output HTML code into the current buffer, so you can
decide using the `with-current-buffer' macro to redirect the output
somewhere else."
  (cl-flet ((kwd-name (kwd) (substring (symbol-name kwd) 1)))
    (pcase tree

      ;;
      ;;
      ;; Handle general tags
      ;;
      ;;
      ((and `(,tag . ,rest)
            (guard (keywordp tag)))
       (let ((i 0)
             (void-tag-p (member tag '(:input
                                       :br
                                       :img))))

         ;;
         ;; Write beginning tag
         ;;

         (insert (format "<%s" (kwd-name tag)))

         ;;
         ;; Write attributes if any
         ;;
         (cl-loop for (k v) on rest by #'cddr
               collect
               (pcase k
                 ((guard (keywordp k))
                  (prog1 (when v
                           (insert " ")
                           (cond
                             ((eq v t) (insert (format "%s"
                                                       (kwd-name k))))
                             (t
                              (insert (format "%s=%S"
                                              (kwd-name k)
                                              (format "%s" (eval v)))))))
                    (cl-incf i)
                    (cl-incf i)))
                 ;; if there is no match return immediately
                 (_ (cl-return))))


         ;;
         ;; Write a closing > tag if it's a normal tag
         ;; or /> if it's a ,,void-tag''
         ;;

         (insert (if void-tag-p "/>" ">"))

         ;;
         ;; render the body of the tag
         ;;
         (unless (= (length rest) i)
           (newline))
         (cl-loop for j from i to (length rest)
               do (el-who--engine (nth j rest)))
         (unless (= (length rest) i)
           (newline))

         ;;
         ;; close the tag properly if we have to
         ;;

         (unless void-tag-p
           (insert (format "</%s>" (kwd-name tag))))))

      ;;
      ;;
      ;; if it's an atom, just get the formatted version of it
      ;;
      ;;
      ((and (pred atom)
            (guard (not (null tree))))
       (insert (format "%s" tree)))

      ;;
      ;;
      ;; if it's something resembling a lisp call, just evaluate the
      ;; tree and pass the return value through el-who again
      ;;
      ;;
      ((and `(,form-name . ,_)
            (guard (symbolp form-name)))
       (el-who--engine (eval tree))))))

(defun el-who (tree)
  "Create an html string representation of the s-expression TREE."
  (with-temp-buffer
    (el-who--engine tree)
    (buffer-string)))

(defmacro el-who-htm (tree)
  "A macro recreating the cl:who functionality for TREE."
  `(el-who--engine ',tree))

(defmacro el-who-cl-who (tree)
  "Transform a S-expression TREE which include cl-who functions.

The cl-who functions are `who:str', `who:htm' and `who:fmt'.
Also loop keywords are replaced by the cl-lib symbol `cl-loop'.
It returns a string containing the HTML output.
Bear in mind that `who:fmt' is a quite bad replacement by the elisp function
`format' since the formatting strings are not the same."
  `(el-who (cl-sublis '((who:str . identity)
                        (who:htm . el-who-htm)
                        (who:fmt . format)
                        (loop . cl-loop))
                      ',tree)))

(provide 'el-who)

;;; el-who.el ends here
