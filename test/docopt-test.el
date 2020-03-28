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

(require 'docopt)
(require 'ert)

(defvar docopt-naval-fate-str
  "Naval Fate.
Usage:
  naval_fate.py ship new <name>...
  naval_fate.py ship <name> move <x> <y> [--speed=<kn>]
  naval_fate.py ship shoot <x> <y>
  naval_fate.py mine (set|remove) <x> <y> [--moored|--drifting]
  naval_fate.py -h | --help
  naval_fate.py --version
Options:
  -h --help     Show this screen.
  --version     Show version.
  --speed=<kn>  Speed in knots [default: 10].
  --moored      Moored (anchored) mine.
  --drifting    Drifting mine.")

(ert-deftest docopt--formal-usage-test ()
  (let* ((doc "Usage: prog [-hv] ARG\n       prog N M\n\nprog is a program.")
         (usage (car (docopt--parse-section "usage:" doc))))
    (should (equal "Usage: prog [-hv] ARG\n       prog N M"  usage))
    (should (equal "( [-hv] ARG ) | ( N M )" (docopt--formal-usage usage)))))

(ert-deftest docopt--parse-defaults-test ()
  (should (equal (list (docopt-option :arg-count 0 :description "Show this screen." :long "--help" :short "-h" )
                       (docopt-option :arg-count 0 :description "Show version." :long "--version")
                       (docopt-option :arg-count 1 :description "Speed in knots [default: 10]." :long "--speed" :value "10")
                       (docopt-option :arg-count 0 :description "Moored (anchored) mine." :long "--moored")
                       (docopt-option :arg-count 0 :description "Drifting mine." :long "--drifting"))
                 (docopt--parse-defaults docopt-naval-fate-str))))

(defvar docopt-test-usages "usage: this

usage:hai
usage: this that

usage: foo
       bar

PROGRAM USAGE:
 foo
 bar
usage:
\ttoo
\ttar
Usage: eggs spam
BAZZ
usage: pit stop")

(ert-deftest docopt--parse-section-test ()
  (should (equal (docopt--parse-section "usage:" "usage: prog")
                 (list "usage: prog")))
  (should (equal (docopt--parse-section "usage:" "usage: -x\n -y")
                 (list "usage: -x\n -y")))
  (should (equal (docopt--parse-section "usage:" docopt-test-usages)
                 '("usage: this"
                   "usage:hai"
                   "usage: this that"
                   "usage: foo\n       bar"
                   "PROGRAM USAGE:\n foo\n bar"
                   "usage:\n	too\n	tar"
                   "Usage: eggs spam"
                   "usage: pit stop"))))

(ert-deftest docopt--parse-program-test ()
  (let ((program (docopt-parse-program docopt-naval-fate-str)))
    (should (equal (list (docopt-option :arg-count 0 :description "Show this screen." :long "--help" :short "-h")
                         (docopt-option :arg-count 0 :description "Show version." :long "--version")
                         (docopt-option :arg-count 1 :description "Speed in knots [default: 10]." :long "--speed" :value "10")
                         (docopt-option :arg-count 0 :description "Moored (anchored) mine." :long "--moored")
                         (docopt-option :arg-count 0 :description "Drifting mine." :long "--drifting"))
                   (docopt-program-options program)))
    (should (equal docopt-naval-fate-str (docopt-program-source program)))))

(ert-deftest docopt-pattern--transform-test ()
  (should (equal (docopt-make-either (docopt-make-required (docopt-option :short "-h")))
                 (docopt-pattern--transform (docopt-option :short "-h"))))
  (should (equal (docopt-make-either (docopt-make-required (docopt-argument :name "A")))
                 (docopt-pattern--transform (docopt-argument :name "A"))))
  (should (equal (docopt-make-either
                  (docopt-make-required
                   (docopt-option :short "-a")
                   (docopt-option :short "-c"))
                  (docopt-make-required
                   (docopt-option :short "-b")
                   (docopt-option :short "-c")))
                 (docopt-pattern--transform
                  (docopt-make-required
                   (docopt-make-either
                    (docopt-option :short "-a")
                    (docopt-option :short "-b"))
                   (docopt-option :short "-c")))))
  (should (equal (docopt-make-either
                  (docopt-make-required
                   (docopt-option :short "-b")
                   (docopt-option :short "-a"))
                  (docopt-make-required
                   (docopt-option :short "-c")
                   (docopt-option :short "-a")))
                 (docopt-pattern--transform
                  (docopt-make-optional
                   (docopt-option :short "-a")
                   (docopt-make-either
                    (docopt-option :short "-b")
                    (docopt-option :short "-c"))))))
  (should (equal (docopt-make-either
                  (docopt-make-required
                   (docopt-option :short "-x"))
                  (docopt-make-required
                   (docopt-option :short "-y"))
                  (docopt-make-required
                   (docopt-option :short "-z")))
                 (docopt-pattern--transform
                  (docopt-make-either
                   (docopt-option :short "-x")
                   (docopt-make-either
                    (docopt-option :short "-y")
                    (docopt-option :short "-z"))))))
  (should (equal (docopt-make-either
                  (docopt-make-required
                   (docopt-argument :name "N")
                   (docopt-argument :name "M")
                   (docopt-argument :name "N")
                   (docopt-argument :name "M")))
                 (docopt-pattern--transform
                  (docopt-make-one-or-more
                   (docopt-argument :name "N")
                   (docopt-argument :name "M"))))))

(ert-deftest docopt-pattern--flat-test ()
  (should (equal (list (docopt-argument :name "N")
                       (docopt-option :short "-a")
                       (docopt-argument :name "M"))
                 (docopt--flat
                  (docopt-make-required
                   (docopt-make-one-or-more (docopt-argument :name "N"))
                   (docopt-option :short "-a")
                   (docopt-argument :name "M")))))
  (should (equal (list (docopt-options-shortcut))
                 (docopt--flat
                  (docopt-make-required
                   (docopt-make-optional (docopt-options-shortcut))
                   (docopt-make-optional (docopt-option :short "-a")))
                  '(docopt-options-shortcut)))))

(ert-deftest docopt-pattern--fix-identities-test ()
  (let ((pattern (docopt-make-required
                  (docopt-argument :name "N")
                  (docopt-argument :name "N"))))
    (should (not (eq (nth 0 (docopt-children pattern))
                     (nth 1 (docopt-children pattern)))))
    (docopt-pattern--fix-identities pattern)
    (should (eq (nth 0 (docopt-children pattern))
                (nth 1 (docopt-children pattern))))))

(ert-deftest docopt-pattern--fix-repeating-arguments-test ()
  (should (equal (docopt-make-required
                  (docopt-argument :name "N" :value [])
                  (docopt-argument :name "N" :value []))
                 (docopt-pattern--fix-repeating-arguments
                  (docopt-make-required
                   (docopt-argument :name "N")
                   (docopt-argument :name "N")))))
  (should (equal (docopt-make-either
                  (docopt-argument :name "N" :value [])
                  (docopt-make-one-or-more (docopt-argument :name "N" :value [])))
                 (docopt-pattern--fix-repeating-arguments
                  (docopt-make-either
                   (docopt-argument :name "N")
                   (docopt-make-one-or-more (docopt-argument :name "N")))))))

(ert-deftest docopt--parse-argv-test ()
  (let ((program (docopt-parse-program docopt-naval-fate-str)))
    (should (equal (list (docopt-argument :value "naval_fate.py")
                         (docopt-option
                          :arg-count 0
                          :description "Show this screen."
                          :long "--help"
                          :short "-h"))
                   (docopt--parse-argv program "naval_fate.py --help")))))

(ert-deftest docopt-test-match-argument ()
  (should (equal (list t nil (list (docopt-argument :name "N" :value 9)))
                 (docopt--match (docopt-argument :name "N") (list (docopt-argument :name "N" :value 9))))))

(ert-deftest docopt-test-match-command ()
  (should (equal (list t nil (list (docopt-command :name "c" :value t)))
                 (docopt--match (docopt-command :name "c") (list (docopt-argument :name "c"))))))

(provide 'docopt-test)

;;; docopt-test.el ends here
