;;; docopt-program.el --- The Docopt program class -*- lexical-binding: t -*-

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

;; The Docopt program class

;;; Code:

(require 'docopt-generic)
(require 'docopt-option)
(require 'eieio)
(require 'seq)

(defclass docopt-program ()
  ((arguments
    :accessor docopt-program-arguments
    :documentation "The arguments of the program."
    :initarg :arguments
    :initform nil
    :type (or list null))
   (header
    :accessor docopt-program-header
    :documentation "The header of the program."
    :initarg :header
    :initform nil
    :type (or string null))
   (examples
    :accessor docopt-program-examples
    :documentation "The examples of the program."
    :initarg :examples
    :initform nil
    :type (or list null))
   (footer
    :accessor docopt-program-footer
    :documentation "The footer of the program."
    :initarg :footer
    :initform nil
    :type (or string null))
   (usage
    :accessor docopt-program-usage
    :documentation "The usage information of the program."
    :initarg :usage
    :initform nil
    :type (or list null))
   (options
    :accessor docopt-program-options
    :documentation "The options of the program."
    :initarg :options
    :initform nil
    :type (or list null)))
  "A class representing a Docopt program.")

(cl-defmethod docopt-collect-arguments ((program docopt-program))
  "Collect the arguments from the Docopt PROGRAM."
  (delete-dups (seq-mapcat #'docopt-collect-arguments (docopt-program-usage program))))

(cl-defmethod docopt-collect-commands ((program docopt-program))
  "Collect the commands from the Docopt PROGRAM."
  (delete-dups (seq-mapcat #'docopt-collect-commands (docopt-program-usage program))))

(cl-defmethod docopt-collect-options ((program docopt-program))
  "Collect the options from the Docopt PROGRAM."
  (cl-remove-duplicates
   (seq-concatenate
    'list
    (seq-mapcat #'docopt-collect-options (docopt-program-usage program))
    (docopt-program-options program))
   :key #'eieio-object-name-string
   :test 'string=))

(defun docopt-program-option (program name)
  "Return the long or short option of PROGRAM by NAME."
  (seq-find (lambda (option) (equal name (oref option object-name)))
            (docopt-program-options program)))

(defun docopt-program-argv-normalize (program)
  "Return a list of normalized Docopt argv elements for PROGRAM."
  (seq-concatenate 'list
                   (docopt-program-arguments program)
                   (docopt-collect-commands program)
                   (seq-remove (lambda (option)
                                 (and (docopt-short-option-p option)
                                      (docopt-option-synonym option)))
                               (docopt-program-options program))))

(provide 'docopt-program)

;;; docopt-program.el ends here
