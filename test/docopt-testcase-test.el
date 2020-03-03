;;; docopt-testcase-test.el --- The Docopt testcase tests -*- lexical-binding: t -*-

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

;; The Docopt testcase tests

;;; Code:

(require 'buttercup)
(require 'docopt-testcase)
(require 'f)

(describe "The `docopt--parse-testcase-example` parser"

  (it "should parse a single line JSON result"
    (expect (parsec-with-input "$ prog\n{\"-a\": false}\n"
              (docopt--parse-testcase-example))
            :to-equal (docopt-make-testcase-example
                       :argv "prog"
                       :expected '((-a . :json-false)))))

  (it "should parse a multi line JSON result"
    (expect (parsec-with-input "$ prog\n{\"-a\": false,\n \"-b\": true}\n"
              (docopt--parse-testcase-example))
            :to-equal (docopt-make-testcase-example
                       :argv "prog"
                       :expected '((-a . :json-false) (-b . t)))))

  (it "should parse a multi line nested JSON result"
    (expect (parsec-with-input "$ prog\n{\"-a\": false,\n \"-b\": {\"c\": 1}}\n"
              (docopt--parse-testcase-example))
            :to-equal (docopt-make-testcase-example
                       :argv "prog"
                       :expected '((-a . :json-false) (-b (c . 1))))))

  (it "should parse a multi line nested JSON result with spaces"
    (expect (parsec-with-input "$ prog\n {\"-a\": false,\n \"-b\": {\"c\": 1 } }\n"
              (docopt--parse-testcase-example))
            :to-equal (docopt-make-testcase-example
                       :argv "prog"
                       :expected '((-a . :json-false) (-b (c . 1))))))

  (it "should parse a user error"
    (expect (parsec-with-input "$ prog --xxx\n\"user-error\""
              (docopt--parse-testcase-example))
            :to-equal (docopt-make-testcase-example :argv "prog --xxx" :expected 'user-error))))

(describe "The `docopt-testcase-program` parser"

  (it "should parse a single line string"
    (expect (parsec-with-input "r\"\"\"Usage: prog [<arg>]\n\n\"\"\""
              (docopt--parse-testcase-program))
            :to-equal (docopt-parse-program "Usage: prog [<arg>]\n\n")))

  (it "should parse a multi line string"
    (expect (parsec-with-input "r\"\"\"Usage: prog [options]\n\nOptions: -a  All.\n\n\"\"\""
              (docopt--parse-testcase-program))
            :to-equal (docopt-parse-program "Usage: prog [options]\n\nOptions: -a  All.\n\n"))))

(describe "Parsing the Docopt test cases"
  :var ((testcases (docopt-parse-testcases (f-read-text "test/testcases.docopt"))))

  (it "should return 81 test cases"
    (expect (length testcases) :to-equal 81))

  (it "should test all test cases"
    (seq-doseq (testcase testcases)
      (docopt-testcase-test testcase))))

;;; docopt-testcase-test.el ends here
