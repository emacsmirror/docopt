;;; docopt.el --- A Docopt implementation in Elisp -*- lexical-binding: t -*-

;; Copyright (C) 2019-2020 r0man

;; Author: r0man <roman@burningswell.com>
;; Maintainer: r0man <roman@burningswell.com>
;; Keywords: docopt, tools, processes
;; Homepage: https://github.com/r0man/docopt.el
;; Version: 0.1.0

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

;; A Docopt implementation in Elisp

;;; Code:

(require 'docopt-argv)
(require 'docopt-parser)
(require 'docopt-transient)
(require 'docopt-util)
(require 'parsec)
(require 's)

(define-error 'docopt-invalid-program
  "Invalid Docopt program.")

;;;###autoload
(defun docopt (command)
  "Invoke the transient command for the Docopt shell COMMAND."
  (interactive (list (read-from-minibuffer "Docopt: ")))
  (docopt-transient (docopt-program-shell-command command)))

;;;###autoload
(defun docopt-parse (s)
  "Parse the Docopt program from S."
  (let ((program (parsec-with-input s (docopt-parser-program))))
    (when (docopt--parsec-error-p program)
      (signal 'docopt-invalid-program program))
    (setf (oref program :source) (docopt-strip s))
    program))

;;;###autoload
(defun docopt-eval-ast (program s)
  "Parse the argument vector from S using the Docopt PROGRAM."
  (docopt-argv-parse program s))

;;;###autoload
(defun docopt-eval (program s)
  "Parse the argument vector from S using the Docopt PROGRAM."
  (docopt--argv-to-alist program (docopt-argv-parse program s)))

(provide 'docopt)

;;; docopt.el ends here