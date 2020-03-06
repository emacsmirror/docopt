;;; docopt-test.el --- The Docopt parser tests -*- lexical-binding: t -*-

;; Copyright (C) 2019-2020 r0man

;; Author: r0man <roman@burningswell.com>
;; Maintainer: r0man <roman@burningswell.com>
;; Created: 29 Feb 2020
;; Keywords: docopt, tools, processes
;; Homepage: https://github.com/r0man/docopt.el

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see http://www.gnu.org/licenses.

;;; Commentary:

;; The Docopt parser tests

;;; Code:

(require 'buttercup)
(require 'docopt)
(require 'docopt-testcase)
(require 'f)
(require 'test-helper)

(seq-doseq (testcase (docopt-parse-testcases (f-read-text "test/testcases.docopt")))
  (let ((program (docopt-testcase-program testcase)))
    (describe (format "Parsing the Docopt program:\n\n%s" (docopt-string program))
      (seq-doseq (example (docopt-testcase-test testcase))
        (it (format "should parse: %s" (docopt-testcase-example-argv example))
          (expect (docopt-testcase-example-actual example)
                  :to-equal (docopt-testcase-example-expected example)))))))

;;; docopt-test.el ends here
