;;; el-who-test.el --- Test for el-who               -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Alejandro Gallo

;; Author: Alejandro Gallo <gallo@unug>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'el-who)

(ert-deftest el-who-test-simple ()
  "Simple transformations"

  (should (string= (el-who `(:br))
                   "<br/>"))

  (should (string= (el-who `(:div))
                   "<div></div>"))

  (should (string= (el-who `(:input :type "text"))
                   "<input type=\"text\"/>"))

  (should (string= (el-who `(:input :type "text"
                                    :placeholder "Somethig"
                                    :required t
                                    :value "Hello World"))
                   "<input type=\"text\" placeholder=\"Somethig\" required value=\"Hello World\"/>"))

  (should (string= (el-who `(:p (:p (:span) (:span (:p) (:span)))))
                   "<p>
<p>
<span></span><span>
<p></p><span></span>
</span>
</p>
</p>"))

  (should (string= (el-who `((:p (:span)) (:p) (:p)))
                   "<p>
<span></span>
</p><p></p><p></p>")))

(ert-deftest el-who-test-cl:who ()
  "Tests for cl:who compattibility"

  (should (string=
           (el-who-cl-who
            (:div
             (:p)
             (loop for i below 4
                   do (who:htm (:span :id i
                                      (who:fmt "Hello %s" i))))))
           "<div>
<p></p><span id=\"0\">
Hello 0
</span><span id=\"1\">
Hello 1
</span><span id=\"2\">
Hello 2
</span><span id=\"3\">
Hello 3
</span>
</div>"))

  (should (string=
           (el-who-cl-who
            (:div :class "card w-100"
                  (let ((card "hello")
                        (deck "world"))
                    (who:htm
                     (:div (who:str card)
                           (:div :class "card-footer"
                                 (:form :method "POST"
                                        :action "/grade"
                                        (:input :name "deck-id"
                                                :value deck
                                                :class "d-none invisible")
                                        (:input :name "card-id"
                                                :value deck
                                                :class "d-none invisible")
                                        (:span :class "badge fs-7 bg-secondary"
                                               (who:fmt "This %s" card))
                                        (:div :class "btn-group float-end"
                                              (loop for i below 5
                                                    do (who:htm
                                                        (:button :class "btn btn-primary"
                                                                 :value i
                                                                 :name "grade"
                                                                 (who:str i))))))))))))
           "<div class=\"card w-100\">
<div>
hello<div class=\"card-footer\">
<form method=\"POST\" action=\"/grade\">
<input name=\"deck-id\" value=\"world\" class=\"d-none invisible\"/><input name=\"card-id\" value=\"world\" class=\"d-none invisible\"/><span class=\"badge fs-7 bg-secondary\">
This hello
</span><div class=\"btn-group float-end\">
<button class=\"btn btn-primary\" value=\"0\" name=\"grade\">
0
</button><button class=\"btn btn-primary\" value=\"1\" name=\"grade\">
1
</button><button class=\"btn btn-primary\" value=\"2\" name=\"grade\">
2
</button><button class=\"btn btn-primary\" value=\"3\" name=\"grade\">
3
</button><button class=\"btn btn-primary\" value=\"4\" name=\"grade\">
4
</button>
</div>
</form>
</div>
</div>
</div>")))

(provide 'el-who-test)
;;; el-who-test.el ends here
