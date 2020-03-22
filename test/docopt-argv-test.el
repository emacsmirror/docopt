;;; docopt-argv-test.el --- The Docopt argument parser tests -*- lexical-binding: t -*-

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

;; The Docopt argument parser tests

;;; Code:

(require 'buttercup)
(require 'docopt)
(require 'docopt-argv)
(require 'test-helper)

(describe "The `docopt-argv-parser` parser"
  :var ((program (docopt-parse docopt-naval-fate-str)))

  (it "should parse an argument"
    (expect (parsec-with-input "my-arg"
              (docopt-argv-parser program (docopt-argument :object-name "ARG")))
            :to-equal (docopt-argument :object-name "ARG" :value "my-arg")))

  (it "should parse a short option"
    (expect (parsec-with-input "-h"
              (docopt-argv-parser program (docopt-short-option :object-name "h")))
            :to-equal (docopt-short-option :object-name "h")))

  (it "should parse a long option"
    (expect (parsec-with-input "--help"
              (docopt-argv-parser program (docopt-long-option :object-name "help")))
            :to-equal (docopt-long-option :object-name "help")))

  (it "should parse a long option prefix"
    (expect (parsec-with-input "--hel"
              (docopt-argv-parser program (docopt-long-option :object-name "help" :prefixes '("hel"))))
            :to-equal (docopt-long-option :object-name "help" :prefixes '("hel"))))

  (it "should parse a long option with argument separated by equals sign"
    (expect (parsec-with-input "--speed=20"
              (docopt-argv-parser program (docopt-long-option :object-name "speed" :argument (docopt-argument :object-name "kn"))))
            :to-equal (docopt-long-option :object-name "speed" :argument (docopt-argument :object-name "kn" :value "20"))))

  (it "should parse a long option with argument separated by whitespace"
    (expect (parsec-with-input "--speed 10"
              (docopt-argv-parser program (docopt-long-option :object-name "speed" :argument (docopt-argument :object-name "kn"))))
            :to-equal (docopt-long-option :object-name "speed" :argument (docopt-argument :object-name "kn" :value "10"))))

  (it "should parse a command"
    (expect (parsec-with-input "naval_fate"
              (docopt-argv-parser program (docopt-command :object-name "naval_fate")))
            :to-equal (docopt-command :object-name "naval_fate")))

  (it "should parse a list of arguments"
    (expect (parsec-with-input "a b" (docopt-argv-parser program (parsec-with-input "A B" (docopt--parse-usage-expr))))
            :to-equal (list (docopt-argument :object-name "A" :value "a")
                            (docopt-argument :object-name "B" :value "b"))))

  (it "should parse an optional group"
    (expect (parsec-with-input "a b" (docopt-argv-parser program (parsec-with-input "[A B]" (docopt--parse-usage-expr))))
            :to-equal (list (docopt-argument :object-name "A" :value "a" :optional t)
                            (docopt-argument :object-name "B" :value "b" :optional t))))

  (it "should parse a required group"
    (expect (parsec-with-input "a b" (docopt-argv-parser program (parsec-with-input "(A B)" (docopt--parse-usage-expr))))
            :to-equal (list (docopt-argument :object-name "A" :value "a")
                            (docopt-argument :object-name "B" :value "b"))))

  (it "should parse a usage pattern"
    (expect (parsec-with-input "naval_fate --help"
              (docopt-argv-parser program
                                  (parsec-with-input "Usage: naval_fate -h | --help"
                                    (docopt--parse-usage))))
            :to-equal (list (docopt-command :object-name "naval_fate")
                            (docopt-long-option :object-name "help"))))

  (it "should parse a sequence of short options"
    (let ((options (list (docopt-short-option :object-name "a")
                         (docopt-short-option :object-name "b")
                         (docopt-short-option :object-name "c"))))
      (expect (parsec-with-input "-a -b -c" (docopt-argv-parser program options))
              :to-equal options))))

(describe "Parsing an either"
  :var ((program (docopt-parse docopt-naval-fate-str))
        (exprs (parsec-with-input "a|-b|--c" (docopt--parse-usage-expr))))

  (it "should parse the branch with a command"
    (expect (parsec-with-input "a" (docopt-argv-parser program exprs))
            :to-equal (list (docopt-command :object-name "a"))))

  (it "should parse the branch with a short option"
    (expect (parsec-with-input "-b" (docopt-argv-parser program exprs))
            :to-equal (list (docopt-short-option :object-name "b"))))

  (it "should parse the branch with a long option"
    (expect (parsec-with-input "--c" (docopt-argv-parser program exprs))
            :to-equal (list (docopt-long-option :object-name "c")))))

(describe "Parsing optional short options within an either"
  :var ((program (docopt-parse docopt-naval-fate-str))
        (exprs (parsec-with-input "[-a|-b]" (docopt--parse-usage-expr))))

  (it "should parse the empty string"
    (expect (parsec-with-input "" (docopt-argv-parser program exprs))
            :to-equal nil))

  (it "should parse the first branch"
    (expect (parsec-with-input "-a" (docopt-argv-parser program exprs))
            :to-equal (list (docopt-short-option :object-name "a"))))

  (it "should parse the second branch"
    (expect (parsec-with-input "-b" (docopt-argv-parser program exprs))
            :to-equal (list (docopt-short-option :object-name "b")))))

(describe "Parsing a command followed by optional short options within an either"
  :var ((program (docopt-parse docopt-naval-fate-str))
        (exprs (parsec-with-input "cmd [-a|-b]" (docopt--parse-usage-expr))))

  (it "should parse just the command"
    (expect (parsec-with-input "cmd" (docopt-argv-parser program exprs))
            :to-equal (list (docopt-command :object-name "cmd"))))

  (it "should parse the command and the first branch"
    (expect (parsec-with-input "cmd -a" (docopt-argv-parser program exprs))
            :to-equal  (list (docopt-command :object-name "cmd")
                             (docopt-short-option :object-name "a"))))

  (it "should parse the command and the second branch"
    (expect (parsec-with-input "cmd -b" (docopt-argv-parser program exprs))
            :to-equal  (list (docopt-command :object-name "cmd")
                             (docopt-short-option :object-name "b")))))

(describe "Parsing Naval Fate options"
  :var ((program (docopt-parse docopt-naval-fate-str)))

  (it "should parse no options"
    (expect (parsec-with-input "" (docopt-argv--parse-options program))
            :to-equal nil))

  (it "should parse a single short option"
    (expect (parsec-with-input "-h" (docopt-argv--parse-options program))
            :to-equal (list docopt-naval-fate-option-h)))

  (it "should parse a single long option"
    (expect (parsec-with-input "--help" (docopt-argv--parse-options program))
            :to-equal (list docopt-naval-fate-option-help)))

  (it "should parse a multiple options"
    (expect (parsec-with-input "-h --moored --version" (docopt-argv--parse-options program))
            :to-equal (list docopt-naval-fate-option-h
                            docopt-naval-fate-option-moored
                            docopt-naval-fate-option-version))))

(setq program (docopt-parse "Usage: program
Options:
  --aa=AA
  --bb
  -a=A
  -b
  -c
"))

(describe "Parsing program options"
  :var ((program (docopt-parse "Usage: program
Options:
  --aa=AA
  --bb
  -a=A
  -b
  -c
")))

  (it "should parse a single short option without argument"
    (expect (parsec-with-input "-b" (docopt-argv--parse-options program))
            :to-equal (list (docopt-short-option :object-name "b"))))

  (it "should parse a single short option with argument separated by equals sign"
    (expect (parsec-with-input "-a=x" (docopt-argv--parse-options program))
            :to-equal (list (docopt-short-option :object-name "a" :argument (docopt-argument :object-name "A" :value "x")))))

  (it "should parse a single short option with argument separated whitespace"
    (expect (parsec-with-input "-ax" (docopt-argv--parse-options program))
            :to-equal (list (docopt-short-option :object-name "a" :argument (docopt-argument :object-name "A" :value "x")))))

  (it "should parse a single short option with argument not separated"
    (expect (parsec-with-input "-ax" (docopt-argv--parse-options program))
            :to-equal (list (docopt-short-option :object-name "a" :argument (docopt-argument :object-name "A" :value "x")))))

  (it "should parse a single long option with argument separated by equals sign"
    (expect (parsec-with-input "--aa=x" (docopt-argv--parse-options program))
            :to-equal (list (docopt-long-option :object-name "aa" :argument (docopt-argument :object-name "AA" :value "x")))))

  (it "should parse a single long option with argument separated by whitespace"
    (expect (parsec-with-input "--aa x" (docopt-argv--parse-options program))
            :to-equal (list (docopt-long-option :object-name "aa" :argument (docopt-argument :object-name "AA" :value "x")))))

  (it "should parse multiple options"
    (expect (parsec-with-input "-a=x -b --bb --aa=x" (docopt-argv--parse-options program))
            :to-equal (list (docopt-short-option :object-name "a" :argument (docopt-argument :object-name "A" :value "x"))
                            (docopt-short-option :object-name "b")
                            (docopt-long-option :object-name "bb")
                            (docopt-long-option :object-name "aa" :argument (docopt-argument :object-name "AA" :value "x")))))

  (it "should parse multiple stacked option"
    (expect (parsec-with-input "--aa=x -bca=x -b --bb --aa=x" (docopt-argv--parse-options program))
            :to-equal (list (docopt-long-option :object-name "aa" :argument (docopt-argument :object-name "AA" :value "x"))
                            (docopt-short-option :object-name "b")
                            (docopt-short-option :object-name "c")
                            (docopt-short-option :object-name "a" :argument (docopt-argument :object-name "A" :value "x"))
                            (docopt-short-option :object-name "b")
                            (docopt-long-option :object-name "bb")
                            (docopt-long-option :object-name "aa" :argument (docopt-argument :object-name "AA" :value "x")))))

  ;; (it "should parse multiple stacked option and other elements"
  ;;   (expect (parsec-with-input "--aa=x -bca=x -b --bb --aa=x X"
  ;;             (parsec-collect (docopt-argv--parse-options program)
  ;;                             (parsec-str " X")))
  ;;           :to-equal (list (list (docopt-long-option :object-name "aa")
  ;;                                 (docopt-short-option :object-name "b")
  ;;                                 (docopt-short-option :object-name "c")
  ;;                                 (docopt-short-option
  ;;                                  :object-name "a"
  ;;                                  :argument (docopt-argument :object-name "A" :value "x"))
  ;;                                 (docopt-short-option :object-name "b")
  ;;                                 (docopt-long-option :object-name "bb")
  ;;                                 (docopt-long-option :object-name "aa"))
  ;;                           " X")))
  )

(describe "The `docopt-eval` function"
  :var ((program (docopt-parse docopt-naval-fate-str)))

  (it "should parse \"naval_fate mine set 1 2 --moored\""
    (expect (docopt-eval program "naval_fate mine set 1 2 --moored")
            :to-equal '((--drifting)
                        (--help)
                        (--moored . t)
                        (--speed . "10")
                        (--version)
                        (<name>)
                        (<x> . "1")
                        (<y> . "2")
                        (mine . t)
                        (move)
                        (new)
                        (remove)
                        (set . t)
                        (ship)
                        (shoot))))

  (it "should parse \"naval_fate mine set 1 2\""
    (expect (docopt-eval program "naval_fate mine set 1 2")
            :to-equal '((--drifting)
                        (--help)
                        (--moored)
                        (--speed . "10")
                        (--version)
                        (<name>)
                        (<x> . "1")
                        (<y> . "2")
                        (mine . t)
                        (move)
                        (new)
                        (remove)
                        (set . t)
                        (ship)
                        (shoot))))

  (it "should parse \"naval_fate mine set 1 2 --drifting\""
    (expect (docopt-eval program "naval_fate mine set 1 2 --drifting")
            :to-equal '((--drifting . t)
                        (--help)
                        (--moored)
                        (--speed . "10")
                        (--version)
                        (<name>)
                        (<x> . "1")
                        (<y> . "2")
                        (mine . t)
                        (move)
                        (new)
                        (remove)
                        (set . t)
                        (ship)
                        (shoot))))

  (it "should parse \"naval_fate ship SHIP-123 move 1 2 --speed=20\""
    (expect (docopt-eval program "naval_fate ship SHIP-123 move 1 2 --speed=20")
            :to-equal '((--drifting)
                        (--help)
                        (--moored)
                        (--speed . "20")
                        (--version)
                        (<name> . "SHIP-123")
                        (<x> . "1")
                        (<y> . "2")
                        (mine)
                        (move . t)
                        (new)
                        (remove)
                        (set)
                        (ship . t)
                        (shoot)))))

(describe "Parsing a program without arguments"
  (it "should return just the program"
    (expect (docopt-eval (docopt-parse "Usage: prog") "prog")
            :to-equal nil)))

(describe "Parsing naval fate argument vectors"
  :var ((program (docopt-parse docopt-naval-fate-str)))

  (it "should parse \"naval_fate --help\""
    (expect (docopt-eval-ast program "naval_fate --help")
            :to-equal (list docopt-naval-fate-option-help)))

  (it "should parse \"naval_fate ship SHIP-123 move 1 2 --speed=20\""
    (expect (docopt-eval-ast program "naval_fate ship SHIP-123 move 1 2 --speed=20")
            :to-equal (list (docopt-command :object-name "ship")
                            (docopt-argument :object-name "name" :value "SHIP-123")
                            (docopt-command :object-name "move")
                            (docopt-argument :object-name "x" :value "1")
                            (docopt-argument :object-name "y" :value "2")
                            (docopt-long-option
                             :argument (docopt-argument :object-name "kn" :default "10" :value "20")
                             :description "Speed in knots [default: 10]."
                             :object-name "speed"
                             :optional t
                             :prefixes '("spee" "spe" "sp" "s")))))

  (it "should parse \"naval_fate ship new SHIP-1 SHIP-2\""
    (expect (docopt-eval-ast program "naval_fate ship new SHIP-1 SHIP-2")
            :to-equal (list (docopt-command :object-name "ship")
                            (docopt-command :object-name "new")
                            (docopt-argument :object-name "name" :value "SHIP-1" :repeat t)
                            (docopt-argument :object-name "name" :value "SHIP-2" :repeat t)))))

;;; docopt-argv-test.el ends here
