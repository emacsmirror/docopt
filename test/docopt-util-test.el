;;; docopt-util-test.el --- The Docopt util tests -*- lexical-binding: t -*-

;; Copyright (C) 2019-2020 r0man

;; Author: r0man <roman@burningswell.com>
;; Maintainer: r0man <roman@burningswell.com>
;; Created: 29 Feb 2020
;; Keywords: docopt, tools, processes
;; Homepage: https://github.com/r0man/docopt.el

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; util version 3, or (at
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

;; The Docopt util tests

;;; Code:

(require 'buttercup)
(require 'docopt-util)

(describe "Stripping a string"
  (it "should remove whitespace at the beginning and end"
    (expect (docopt-strip " \nA\n ") :to-equal "A"))

  (it "should return when only a blank string is left"
    (expect (docopt-strip " \n\n ") :to-equal nil)))

;;; docopt-util-test.el ends here
