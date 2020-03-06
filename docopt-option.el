;;; docopt-option.el --- The Docopt option class -*- lexical-binding: t -*-

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

;; The Docopt option class

;;; Code:

(require 'docopt-generic)
(require 'docopt-argument)
(require 'eieio)
(require 'eieio-base)

(defclass docopt-option (eieio-named)
  ((argument
    :accessor docopt-option-argument
    :documentation "The argument of the option."
    :initarg :argument
    :initform nil
    :type (or docopt-argument null))
   (description
    :accessor docopt-option-description
    :documentation "The description of the option."
    :initarg :description
    :initform nil
    :type (or string null))
   (synonym
    :accessor docopt-option-synonym
    :documentation "The synonym of the option."
    :initarg :synonym
    :initform nil
    :type (or string null)))
  "A class representing a Docopt base option.")

;;; Long Option

(defclass docopt-long-option (docopt-option) ()
  "A class representing a Docopt long option.")

;;; Short option

(defclass docopt-short-option (docopt-option) ()
  "A class representing a Docopt short option.")

(cl-defmethod docopt-collect-arguments ((_ docopt-option))
  "Collect the arguments from the Docopt OPTION." nil)

(cl-defmethod docopt-collect-commands ((option docopt-option))
  "Collect the commands from the Docopt OPTION." nil)

(cl-defmethod docopt-collect-options ((option docopt-option))
  "Collect the options from the Docopt OPTION." option)

(cl-defmethod docopt-collect-options ((lst list))
  "Collect the options from the list LST."
  (delete-dups (docopt--flatten (seq-map #'docopt-collect-options lst))))

(defun docopt-option-set-default (option default)
  "Set the default argument value of OPTION to DEFAULT."
  (when-let ((argument (docopt-option-argument option)))
    (oset argument :default default)))

(defun docopt-option-set-description-and-default (option description default)
  "Set the DESCRIPTION and DEFAULT of the OPTION."
  (when option
    (oset option :description description)
    (docopt-option-set-default option default)))

(defun docopt-option-set-synonym (option synonym)
  "Set the :synonym slot of OPTION to :object-name of SYNONYM."
  (when (and option synonym)
    (oset option :synonym (oref synonym :object-name))))

(defun docopt-option-link (long-option short-option description default)
  "Link LONG-OPTION and SHORT-OPTION using DESCRIPTION and DEFAULT."
  (when long-option
    (docopt-option-set-description-and-default long-option description default)
    (docopt-option-set-synonym long-option short-option))
  (when short-option
    (docopt-option-set-description-and-default short-option description default)
    (docopt-option-set-synonym short-option long-option))
  (list long-option short-option))

(cl-defun docopt-make-options (&key description default long-name short-name argument argument-name)
  "Make a new Docopt option line instance.

Initialize the DESCRIPTION, DEFAULT, LONG-NAME, SHORT-NAME,
ARGUMENT and ARGUMENT-NAME slots of the instance."
  (let* ((argument (cond
                    ((and argument
                          (object-of-class-p argument 'docopt-argument)) argument)
                    (argument-name (docopt-argument :object-name argument-name))))
         (long-option (when long-name
                        (docopt-long-option
                         :object-name long-name
                         :argument argument
                         :description description)))
         (short-option (when short-name
                         (docopt-short-option
                          :object-name short-name
                          :argument argument
                          :description description))))
    (seq-remove #'null (docopt-option-link long-option short-option description default))))

(provide 'docopt-option)

;;; docopt-option.el ends here
