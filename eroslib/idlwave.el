;; idlwave.el --- IDL and WAVE CL editing mode for GNU Emacs
;; Copyright (c) 1994-1997 Chris Chase
;; Copyright (c) 1999 Carsten Dominik

;; Author: Chris Chase <chase@att.com>
;; Maintainer: Carsten Dominik <dominik@strw.leidenuniv.nl>
;; Version: 3.3b
;; Date: $Date: 2002/12/13 21:32:37 $
;; Keywords: languages
;;
;; This file is not part of the GNU Emacs distribution but is
;; intended for use with GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with the GNU Emacs distribution; if not, write to the Free
;; Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139,
;; USA.

;;; Commentary:

;; In distant past, based on pascal.el.  Though bears little
;; resemblance to that now.
;;
;; Incorporates many ideas, such as abbrevs, action routines, and
;; continuation line indenting, from wave.el.
;; wave.el original written by Lubos Pochman, Precision Visuals, Boulder.
;;
;; See the mode description ("C-h m" in idlwave-mode or "C-h f idlwave-mode")
;; for features, key bindings, and info.
;;
;;
;; INSTALLATION
;; ============
;;
;; Follow the instructions in the INSTALL file of the distribution.
;; In short, put this file on your load path and add the following
;; lines to your .emacs file:
;;
;; (autoload 'idlwave-mode "idlwave" "IDLWAVE Mode" t)
;; (autoload 'idlwave-shell "idlwave-shell" "IDLWAVE Shell" t)
;; (setq auto-mode-alist (cons '("\\.pro\\'" . idlwave-mode) auto-mode-alist))
;;
;;
;; SOURCE
;; ======
;;
;; The newest version of this file is available from the maintainers
;; Webpage.
;;
;;   http://www.strw.leidenuniv.el/~dominik/Tools/idlwave
;;
;; ACKNOWLEDGMENTS
;; ===============
;;
;;   Thanks to the following people for their contributions and comments:
;;
;;     Chris Chase <chris.chase@jhuapl.edu>    The Author
;;
;;     Lubos Pochman <lubos@rsinc.com>
;;     Phil <sterne@dublin.llnl.gov>
;;     David Huenemoerder <dph@space.mit.edu>
;;     Patrick M. Ryan <pat@jaameri.gsfc.nasa.gov>
;;     Xuyong Liu <liu@stsci.edu>
;;     Marty Ryba <ryba@ll.mit.edu>
;;     Phil Williams <williams@irc.chmcc.org>
;;     Ulrik Dickow <dickow@nbi.dk>
;;     Laurent mugnier <mugnier@onera.fr>
;;     Stein Vidar H. Haugan <s.v.h.haugan@astro.uio.no>
;;     Simon Marshall <Simon.Marshall@esrin.esa.it>
;;     Kevin Ivory <Kevin.Ivory@linmpi.mpg.de>
;;
;;
;; Here is some old documentation about how Code indentation works, and
;; which variables are involved.  This stuff is incomlete and should
;; be revised.
;;
;; CODE INDENTATION
;; ----------------
;; 
;;   Like other Emacs programming modes, \\C-j inserts a newline and
;;   indents.  TAB is used for explicit indentation of the current line.
;; 
;;   Comment Indentation
;;   -------------------
;;     Variable `idlwave-block-indent' specifies relative indent for
;;     block statements(begin|case...end),
;; 
;;     Variable `idlwave-continuation-indent' specifies relative indent for
;;     continuation lines.
;; 
;;     Continuation lines inside {}, [], (), are indented
;;     `idlwave-continuation-indent' spaces after rightmost unmatched opening
;;     parenthesis.
;; 
;;     Continuation lines in PRO, FUNCTION declarations are indented
;;     just after the prodcedure/function name.
;; 
;;     Labels are indented with the code unless they are on a line by
;;     themselves and at the beginning of the line.
;; 
;;     Actions can be performed when a line is indented, e.g., surrounding
;;     `=' and `>' with spaces.  See help for `idlwave-indent-action-table'.
;; 
;;   Comment Indentation
;;   -------------------
;; 
;;     Controlled by customizable varibles that match the start of a comment.
;;     Indentation for comments beginning with (default settings):
;; 
;;     1) ; in first column - unchanged (see `idlwave-begin-line-comment').
;;     2) `idlwave-no-change-comment' (\";;;\") - indentation is not changed.
;;     3) `idlwave-code-comment' (\";;[^;]\"\ i.e. exactly two `;' )
;;         - indented as IDL code.
;;     4) None of the above (i.e. single `;' not in first column) - indented
;;          to a minimum of `comment-column' (called a right-margin comment).
;; 
;;   Indentation of text inside a comment paragraph
;;   ----------------------------------------------
;; 
;;     A line whose first non-whitespace character is `;' is called
;;     a `comment line'.
;; 
;;     This mode handles comment paragraphs to a limited degree.
;;     Specifically, comment paragraphs only have meaning for auto-fill
;;     and the idlwave-fill-paragraph command `M-q'.  A
;;     comment line is considered blank if there is only whitespace
;;     besides the comment delimeters.  A comment paragraph consists of
;;     consecutive nonblank comment lines containing the same comment
;;     leader (the whitespace at the beginning of the line plus comment
;;     delimiters). Thus, blank comment lines or a change in the comment
;;     leader will separate comment paragraphs. The indentation of a
;;     comment paragraph is given by first, the hanging indent or second,
;;     the minimum indentation of the paragraph lines after the first
;;     line. A hanging indent is specified by the presence of a string
;;     matching `idlwave-hang-indent-regexp' in the first line of the
;;     paragraph.
;; 
;;     To fill the current comment paragraph use idlwave-fill-paragraph, `M-q'.
;; 
;;     ; Variable - this is a hanging indent. Text on following lines will
;;     ;            be indented like this, past the hyphen and the following
;;     ;            single space. (Note that in auto fill mode that an
;;     ;            automatic return on a line containing a hyphen will cause
;;     ;            a hanging indent. If this happens in the middle of a
;;     ;            paragraph where you don't want it, using
;;     ;            idlwave-fill-paragraph, `M-q', will re-fill the paragraph
;;     ;            according to the hanging-indent in the first paragraph
;;     ;            line.) You can change the expression for the hanging
;;     ;            indent, `idlwave-hang-indent-regexp'.
;;     ;
;;     ;    Indentation will also automatically follow that of the
;;     ;       of the previous line when you are in auto-fill mode
;;     ;       like this.
;; 
;;   Indentation in auto-fill-mode
;;   -----------------------------
;; 
;;     When in auto-fill mode code lines are continued and indented
;;     appropriately.  Comments within a comment paragraph are wrapped
;;     and indented.  The comment text is indented as explained above.  To
;;     toggle on/off the auto-fill mode use `idlwave-auto-fill-mode',
;;     \\[idlwave-auto-fill-mode], rather than the normal `auto-fill-mode'
;;     function.
;; 
;;   Variables controlling indentation style and other features
;;   ----------------------------------------------------------
;; 
;;   `idlwave-block-indent'
;;      Extra indentation within blocks.  (default 4)
;;   `idlwave-continuation-indent'
;;      Extra indentation within continuation lines.  (default 2)
;;   `idlwave-end-offset'
;;      Extra indentation applied to block end lines. (default -4)
;;   `idlwave-main-block-indent'
;;      Extra indentation for a units main block of code. That is the
;;      block between the FUNCTION/PRO statement and the end statement for
;;      that program unit. (default 0)
;;   `idlwave-surround-by-blank'
;;      Automatically surround '=','<','>' with blanks, appends blank to comma.
;;      (default is t)
;;   `idlwave-startup-message'
;;      Set to nil to inhibit message first time idlwave-mode is used.
;;   `idlwave-hanging-indent'
;;      If set non-nil make hanging indents. (default t)
;;   `idlwave-indent-action-table'
;;      An associated list of strings to match and commands to perform
;;      when indenting a line. Enabled with `idlwave-do-actions'.  To make
;;      additions use `idlwave-action-and-binding' (which can also be used to
;;      make key bindings).
;;   
;;
;; CUSTOMIZATION:
;; =============
;;
;; IDLWAVE has customize support - so if you want to learn about the
;;  variables which control the behavior of the mode, use
;; `M-x idlwave-customize'.
;;
;; You can set your own preferred values with Customize, or with Lisp code in
;; .emacs.  Here is an example of what to place in your .emacs file.
;;
;;  (setq idlwave-block-indent 3)           ; Indentation settings
;;  (setq idlwave-main-block-indent 3)
;;  (setq idlwave-end-offset -3)
;;  (setq idlwave-continuation-indent 1)
;;  (setq idlwave-begin-line-comment "^;[^;]")  ; Leave ";" but not ";;" 
;;                                              ; anchored at start of line.
;;  (setq idlwave-surround-by-blank t)      ; Turn on padding ops =,<,>
;;  (setq idlwave-pad-keyword nil)          ; Remove spaces for keyword '='
;;  (setq idlwave-expand-generic-end t)     ; convert END to ENDIF etc...
;;  (setq idlwave-reserved-word-upcase t)   ; Make reserved words upper case
;;                                          ; (with abbrevs only)
;;  (setq idlwave-abbrev-change-case nil)   ; Don't force case of expansions
;;  (setq idlwave-hang-indent-regexp ": ")  ; Change from "- " for auto-fill
;;  (setq idlwave-show-block nil)           ; Turn off blinking to begin
;;  (setq idlwave-abbrev-move t)            ; Allow abbrevs to move point
;;
;;  ;; Some setting can only be done from a mode hook.  Here is an example:
;;
;;  (add-hook 'idlwave-mode-hook
;;    (lambda ()
;;      (setq abbrev-mode 1)                 ; Turn on abbrevs (-1 for off)
;;      (setq case-fold-search nil)          ; Make searches case sensitive
;;
;;      ;; Run other functions here
;;      (font-lock-mode 1)                   ; Turn on font-lock mode
;;      (idlwave-auto-fill-mode 0)           ; Turn off auto filling
;;      ;;
;;      ;; Pad with with 1 space (if -n is used then make the
;;      ;; padding a minimum of n spaces.)  The defaults use -1
;;      ;; instead of 1.
;;      (idlwave-action-and-binding "=" '(idlwave-expand-equal 1 1))
;;      (idlwave-action-and-binding "<" '(idlwave-surround 1 1))
;;      (idlwave-action-and-binding ">" '(idlwave-surround 1 1 '(?-)))
;;      (idlwave-action-and-binding "&" '(idlwave-surround 1 1))
;;      ;;
;;      ;; Only pad after comma and with exactly 1 space
;;      (idlwave-action-and-binding "," '(idlwave-surround nil 1))
;;      ;;
;;      ;; Set some personal bindings
;;      ;; (In this case, makes `,' have the normal self-insert behavior.)
;;      (local-set-key "," 'self-insert-command)
;;      ;; Create a newline, indenting the original and new line.
;;      ;; A similar function that does _not_ reindent the original
;;      ;; line is on "\C-j" (The default for emacs programming modes).
;;      (local-set-key "\n" 'idlwave-newline)
;;      ;; (local-set-key "\C-j" 'idlwave-newline) ; My preference.
;;      ))
;;
;; You can get a pop-up menu of the functions in an IDL file from the menu
;; item "PRO/FUNC menu".  This uses internally imenu.el on Emacs and
;; func-menu.el on XEmacs.  You can also bind the corresponding functions to
;; a mouse event.
;;
;; You will automatically get an IDLWAVE menu of standard formatting
;; functions in the main menu bar.
;;
;; Highlighting of keywords, comments, and strings can be accomplished
;; with font-lock.  To enable font-lock unconditionally in your
;; idlwave-mode-hook place the following line (see example hook above):
;;
;;    (font-lock-mode 1)
;;
;; The amount of fontification depends upon the variable
;; `font-lock-maximum-decoration', which see.
;;
;; KNOWN PROBLEMS:
;; ==============
;;
;;   Moving the point backwards in conjunction with abbrev expansion
;;   does not work as I would like it, but this is a problem with
;;   emacs abbrev expansion done by the self-insert-command.  It ends
;;   up inserting the character that expanded the abbrev after moving
;;   point backward, e.g., "\cl" expanded with a space becomes
;;   "LONG( )" with point before the close paren.  This is solved by
;;   using a temporary function in `post-command-hook' - not pretty, 
;;   but it works.<
;;
;;   Tabs and spaces are treated equally as whitespace when filling a
;;   comment paragraph.  To accomplish this, tabs are permanently
;;   replaced by spaces in the text surrounding the paragraph, which
;;   may be an undesirable side-effect.  Replacing tabs with spaces is
;;   limited to comments only and occurs only when a comment
;;   paragraph is filled via `idlwave-fill-paragraph'.
;;
;;   "&" is ignored when parsing statements.
;;   Avoid muti-statement lines (using "&") on block begin and end
;;   lines.  Multi-statement lines can mess up the formatting, for
;;   example, multiple end statements on a line: endif & endif.
;;   Using "&" outside of block begin/end lines should be okay.
;;
;; Revision History:
;; =================
;;
;; Revision 3.1
;;
;; Revision 3.0
;; - New maintainer Carsten Dominik <dominik@strw.leidenuniv.nl>
;; - Renamed mode and all variables and functions.  The new prefix is
;;   `idlwave-' instead of `idl-'.  This was necessary to evade a name
;;   clash with the idl-mode defined in `cc-mode.el' which is part of
;;   X/Emacs 20 distributions.
;; - Added Customize support.
;; - New commands `idlwave-beginning-of-block' and `idlwave-end-of-block'.
;; - New command `idlwave-close-block'.
;; - Font-lock enhancements.  Multi-level fontification based on the
;;   value of `font-lock-maximum-decoration'.  Reunified the different
;;   expressions for Emacs and XEmacs.
;; - `idlwave-show-begin' check the correctness of the endstatement.
;; - `idlwave-surround' exception for `->'.
;; - Better listing of abbreviations with `idlwave-list-abbrevs'.
;; - Some general cleanup of the code.  Menu reorganized.
;; - Both imenu (Emacs) and func-menu (XEmacs) are now supported.
;; - Dropped support for Emacs 18 and hilit19.el.
;; - Rewrite of the docstring for the Mode.  Made more compact, to
;;   make more people read it.  Too long parts moved to the Commentary.
;; - Revision number jumps to 3.0 to synchronize with idlwave-shell.el.
;;
;; Revision 1.42  1998/08/31 17:39:00  Kevin.Ivory@linmpi.mpg.de
;; The Idlde enhancements were somehow lost in 1.41.
;;
;; Revision 1.41  1998/05/22 17:42:00  Kevin.Ivory@linmpi.mpg.de
;; JD Smith <jdsmith@astrosun.tn.cornell.edu> corrected a bug in his
;;   1.39 fix (object fontification)
;; Due to minor number checking Emacs 20 was calling code intended for
;;   Emacs <19.30
;;
;; Revision 1.40  1998/03/18  9:12:00  Kevin.Ivory@linmpi.mpg.de
;; Updated source information.
;; Add support for editing, running the file from Emacs in Idlde
;; by Lubos Pochman <lubos@rsinc.com>
;;
;; Revision 1.39  1997/07/16 16:19:00  smith, J.D.
;; (idl-unit-name):  Hacked to recognize Class methods (Class::Method)
;; Amended Font-Lock function/pro name regexp for same purpose.
;;
;; Revision 1.38  1997/01/30 18:52:06  williams
;; Bookkeeping update.  New ftp and maintainer.
;;
;; Revision 1.37  1997/01/30 00:56:41  chase
;; (idl-abbrev-start-char): Allow the user to select the character that
;; start abbreviations in abbrev mode.  Previously '.'  was used which
;; caused a problem with structure fields acting as abbrevs.  Now
;; defaults to '\'.  Changes to this in idl-mode-hook will have no
;; effect.  Instead a user must set it directly using `setq' in the
;; .emacs file before idl.el is loaded.
;; (idl-calculate-cont-indent): Use forward-sexp instead of forward-word
;; to skip beyond an identifier.
;; (idl-mode): Added a check for availability for easy-menu.
;;

;;; Code:

(eval-when-compile (require 'cl))

(eval-and-compile
  ;; Kludge to allow `defcustom' for Emacs 19.
  (condition-case () (require 'custom) (error nil))
  (if (and (featurep 'custom) (fboundp 'custom-declare-variable))
      nil ;; We've got what we needed
    ;; We have the old or no custom-library, hack around it!
    (defmacro defgroup (&rest args) nil)
    (defmacro defcustom (var value doc &rest args) 
      (` (defvar (, var) (, value) (, doc))))))

(defgroup idlwave nil
  "Major mode for editing IDL/WAVE CL .pro files"
  :tag "IDLWAVE"
  :link '(url-link :tag "Home Page" 
		   "http://strw.leidenuniv.nl/~dominik/Tools/idlwave")
  :link '(emacs-commentary-link :tag "Commentary in idlwave-shell.el"
				"idlwave-shell.el")
  :link '(emacs-commentary-link :tag "Commentary in idlwave.el" "idlwave.el")
  ;; :link '(custom-manual "(idlwave)Top")  ; Does not exist yet
  :prefix "idlwave"
  :group 'languages)

;;; Variables for indentation behavior ---------------------------------------

(defgroup idlwave-indent-and-format nil
  "Indentation and formatting options for IDLWAVE mode."
  :group 'idlwave)

(defcustom idlwave-main-block-indent 0
  "*Extra indentation for the main block of code.
That is the block between the FUNCTION/PRO statement and the END
statement for that program unit."
  :group 'idlwave-indent-and-format
  :type 'integer)

(defcustom idlwave-block-indent 4
  "*Extra indentation applied to block lines.
If you change this, you probably also want to change `idlwave-end-offset'."
  :group 'idlwave-indent-and-format
  :type 'integer)

(defcustom idlwave-end-offset -4
  "*Extra indentation applied to block END lines.
A value equal to negative `idlwave-block-indent' will make END lines
line up with the block BEGIN lines."
  :group 'idlwave-indent-and-format
  :type 'integer)

(defcustom idlwave-continuation-indent 2
  "*Extra indentation applied to continuation lines.
This extra offset applies to the first of a set of continuation lines.
The following lines receive the same indentation as the first.
Also, the value of this variable applies to continuation lines inside
parenthesis.  When the current line contains an open unmatched ([{,
the next line is intented to that parenthesis plus the value of this variable."
  :group 'idlwave-indent-and-format
  :type 'integer)

(defcustom idlwave-hanging-indent t
  "*If set non-nil then comment paragraphs are indented under the
hanging indent given by `idlwave-hang-indent-regexp' match in the first line
of the paragraph."
  :group 'idlwave-indent-and-format
  :type 'boolean)

(defcustom idlwave-hang-indent-regexp "- "
  "*Regular expression matching the position of the hanging indent
in the first line of a comment paragraph. The size of the indent
extends to the end of the match for the regular expression."
  :group 'idlwave-indent-and-format
  :type 'regexp)

(defcustom idlwave-use-last-hang-indent nil
  "*If non-nil then use last match on line for `idlwave-indent-regexp'."
  :group 'idlwave-indent-and-format
  :type 'boolean)

(defcustom idlwave-fill-comment-line-only t
  "*If non-nil then auto fill will only operate on comment lines."
  :group 'idlwave-indent-and-format
  :type 'boolean)

(defcustom idlwave-auto-fill-split-string t
  "*If non-nil then auto fill will split strings with the IDL `+' operator.
When the line end falls within a string, string concatenation with the 
'+' operator will be used to distribute a long string over lines.  
If nil and a string is split then a terminal beep and warning are issued.

This variable is ignored when `idlwave-fill-comment-line-only' is
non-nil, since in this case code is not auto-filled."
  :group 'idlwave-indent-and-format
  :type 'boolean)

(defcustom idlwave-split-line-string t
  "*If non-nil then `idlwave-split-line' will split strings with `+'.
When the spltting point of a line falls inside a string, split the string
using the `+' string concatenation operator.  If nil and a string is
split then a terminal beep and warning are issued."
  :group 'idlwave-indent-and-format
  :type 'boolean)

;;; Types of comments -------------------------------------------------------

(defgroup idlwave-comments nil
  "Comment definitions for IDLWAVE mode."
  :group 'idlwave)

(defcustom idlwave-no-change-comment ";;;"
  "*The indentation of a comment that starts with this regular
expression will not be changed. Note that the indentation of a comment
at the beginning of a line is never changed."
  :group 'idlwave-comments
  :type 'string)

(defcustom idlwave-begin-line-comment nil
  "*A comment anchored at the beginning of line.
A comment matching this regular expression will not have its
indentation changed.  If nil the default is \"^;\", i.e., any line
beginning with a \";\".  Expressions for comments at the beginning of
the line should begin with \"^\"."
  :group 'idlwave-comments
  :type '(choice (const :tag "Any line beginning with `;'" nil)
		 'regexp))

(defcustom idlwave-code-comment ";;[^;]"
  "*A comment that starts with this regular expression on a line by
itself is indented as if it is a part of IDL code.  As a result if
the comment is not preceded by whitespace it is unchanged."
  :group 'idlwave-comments
  :type 'regexp)

;; Comments not matching any of the above will be indented as a
;; right-margin comment, i.e., to a minimum of `comment-column'.


;;; Variables for abbrev and action behavior -----------------------------

(defgroup idlwave-abbrev-and-indent-action nil
  "IDLWAVE performs actions when expanding abbreviations or indenting lines.
The variables in this group govern this."
  :group 'idlwave)

(defcustom idlwave-do-actions nil
  "*If non-nil then performs actions when indenting.
The actions that can be performed are listed in `idlwave-indent-action-table'."
  :group 'idlwave-abbrev-and-indent-action
  :type 'boolean)

(defcustom idlwave-abbrev-start-char "\\"
  "*A single character string used to start abbreviations in abbrev mode.
Possible characters to chose from: ~`\%
or even '?'.  '.' is not a good choice because it can make structure
field names act like abbrevs in certain circumstances.

Changes to this in `idlwave-mode-hook' will have no effect.  Instead a user
must set it directly using `setq' in the .emacs file before idlwave.el
is loaded."
  :group 'idlwave-abbrev-and-indent-action
  :type 'string)

(defcustom idlwave-surround-by-blank nil
  "*If nil disables `idlwave-surround'.
If non-nil, `=',`<',`>',`&',`,' are surrounded with spaces by
`idlwave-surround'.
See help for `idlwave-indent-action-table' for symbols using `idlwave-surround'.

Also see the default key bindings for keys using `idlwave-surround'.
Keys are bound and made into actions calling `idlwave-surround' with
`idlwave-action-and-binding'.
See help for `idlwave-action-and-binding' for examples.

Also see help for `idlwave-surround'."
  :group 'idlwave-abbrev-and-indent-action
  :type 'boolean)

(defcustom idlwave-pad-keyword t
  "*If non-nil then pad '=' for keywords like assignments.
Whenever `idlwave-surround' is non-nil then this affects how '=' is padded
for keywords.  If non-nil it is padded the same as for assignments.
If nil then spaces are removed."
  :group 'idlwave-abbrev-and-indent-action
  :type 'boolean)

(defcustom idlwave-show-block t
  "*If non-nil point blinks to block beginning for `idlwave-show-begin'."
  :group 'idlwave-abbrev-and-indent-action
  :type 'boolean)

(defcustom idlwave-expand-generic-end nil
  "*Expand generic END to ENDIF/ENDELSE/ENDWHILE etc."
  :group 'idlwave-abbrev-and-indent-action
  :type 'boolean)

(defcustom idlwave-abbrev-move t
  "*If non-nil the abbrev hook can move point.
Set to nil by `idlwave-expand-region-abbrevs'. To see the abbrev
definitions, use the command `list-abbrevs', for abbrevs that move
point. Moving point is useful, for example, to place point between
parentheses of expanded functions.

See `idlwave-check-abbrev'."
  :group 'idlwave-abbrev-and-indent-action
  :type 'boolean)

(defcustom idlwave-abbrev-change-case nil
  "*If non-nil, then all abbrevs will be forced to either upper or lower case.
If the value t, all expanded abbrevs will be upper case.
If the value is 'down then abbrevs will be forced to lower case.
If nil, the case will not change.
If `idlwave-reserved-word-upcase' is non-nil, reserved words will always be
upper case, regardless of this variable."
  :group 'idlwave-abbrev-and-indent-action
  :type 'boolean)

(defcustom idlwave-reserved-word-upcase nil
  "*If non-nil, reserved words will be made upper case via abbrev expansion.
If nil case of reserved words is controlled by `idlwave-abbrev-change-case'.
Has effect only if in abbrev-mode."
  :group 'idlwave-abbrev-and-indent-action
  :type 'boolean)

;;; Action/Expand Tables.
;;
;; The average user may have difficulty modifying this directly.  It
;; can be modified/set in idlwave-mode-hook, but it is easier to use
;; idlwave-action-and-binding. See help for idlwave-action-and-binding for
;; examples of how to add an action.
;;
;; The action table is used by `idlwave-indent-line' whereas both the
;; action and expand tables are used by `idlwave-indent-and-action'.  In
;; general, the expand table is only used when a line is explicitly
;; indented.  Whereas, in addition to being used when the expand table
;; is used, the action table is used when a line is indirectly
;; indented via line splitting, auto-filling or a new line creation.
;;
;; Example actions:
;;
;;  Capitalize system vars
;;   (idlwave-action-and-binding idlwave-sysvar '(capitalize-word 1) t)
;;
;;  Capitalize procedure name
;;   (idlwave-action-and-binding "\\<\\(pro\\|function\\)\\>[ \t]*\\<"
;;                           '(capitalize-word 1) t)
;;
;;  Capitalize common block name
;;   (idlwave-action-and-binding "\\<common\\>[ \t]+\\<"
;;                           '(capitalize-word 1) t)
;;  Capitalize label
;;   (idlwave-action-and-binding (concat "^[ \t]*" idlwave-label)
;;                           '(capitalize-word -1) t)

(defvar idlwave-indent-action-table nil
  "*Associated array containing action lists of search string (car),
and function as a cdr. This table is used by `idlwave-indent-line'.
See documentation for `idlwave-do-action' for a complete description of
the action lists.

Additions to the table are made with `idlwave-action-and-binding' when a
binding is not requested.
See help on `idlwave-action-and-binding' for examples.")

(defvar idlwave-indent-expand-table nil
  "*Associated array containing action lists of search string (car),
and function as a cdr. The table is used by the
`idlwave-indent-and-action' function. See documentation for
`idlwave-do-action' for a complete description of the action lists.

Additions to the table are made with `idlwave-action-and-binding' when a
binding is requested.
See help on `idlwave-action-and-binding' for examples.")

;;; Routine info (see file idlwave-rinfo.el)---------------------------------

(defgroup idlwave-routine-info-and-completion nil
  "Routine info and name/keyword completion options for IDLWAVE mode."
  :group 'idlwave)

(defcustom idlwave-scan-all-buffers-for-routine-info t
  "*Non-nil means, scan all buffers for IDL programs when updating info.
`idlwave-update-routine-info' scans buffers of the current Emacs session
for routine definitions.  When this variable is nil, it only parses the
current buffer.  When non-nil, all buffers are searched.
A prefix to \\[idlwave-update-routine-info] toggles the meaning of this
variable for the duration of the command."
  :group 'idlwave-routine-info-and-completion
  :type 'boolean)

(defcustom idlwave-resize-routine-help-window nil
  "*Non-nil means, resize the Routine-info *Help* windo to fit the content."
  :group 'idlwave-routine-info-and-completion
  :type 'boolean)

(defcustom idlwave-default-completion-case-is-down nil
  "*Non-nil means, use lower case for completion when case cannot be inferred.
Normally, case is inferred from the string which is being completed.  When
that string is all lower case, lower case is ised for completion.  If
it contains at least one upper case letter, upper case is used for the
whole completed string.
Only when completing the empty string, we need a default case, and that is
specified by this variable."
  :group 'idlwave-routine-info-and-completion
  :type 'boolean)

(defcustom idlwave-keyword-completion-adds-equal t
  "*Non-nil means, completion automatically adds `=' after completed keywords."
  :group 'idlwave-routine-info
  :type 'boolean)

(defcustom idlwave-function-completion-adds-paren t
  "*Non-nil means, completion automatically adds `(' after completed function.
Nil means, don't add anything.
A value of `2' means, also add the closing parenthesis and position cursor
between the two."
  :group 'idlwave-routine-info
  :type '(choice (const :tag "Nothing" nil)
		 (const :tag "(" t)
		 (const :tag "()" 2)))

;;; Documentation header and history keyword ---------------------------------

(defgroup idlwave-documentation nil
  "Options for documenting IDLWAVE files."
  :group 'idlwave)

;; FIXME: make defcustom?
(defvar idlwave-file-header
  (list nil
        ";+
; NAME:
;
; PURPOSE:
;
;
; CALLING SEQUENCE:
;
;
; INPUTS:
;
;
; KEYWORD PARAMETERS:
;
;
; OUTPUTS:
;
;
; MODIFICATION HISTORY:
;
;-
")
  "*A list (PATHNAME STRING) specifying the doc-header template to use for
summarizing a file. If PATHNAME is non-nil then this file will be included.
Otherwise STRING is used. If NIL, the file summary will be omitted.
For example you might set PATHNAME to the path for the
lib_template.pro file included in the IDL distribution.")

(defcustom idlwave-timestamp-hook 'idlwave-default-insert-timestamp
  "*The hook function used to update the timestamp of a function."
  :group 'idlwave-documentation
  :type 'function)

(defcustom idlwave-doc-modifications-keyword "HISTORY"
  "*The modifications keyword to use with the log documentation commands.
A ':' is added to the keyword end.
Inserted by doc-header and used to position logs by doc-modification.
If nil it will not be inserted."
  :group 'idlwave-documentation
  :type 'string)

(defcustom idlwave-doclib-start "^;+\\+"
  "*Start of document library header."
  :group 'idlwave-documentation
  :type 'regexp)

(defcustom idlwave-doclib-end "^;+-"
  "*End of document library header."
  :group 'idlwave-documentation
  :type 'regexp)

;;; External Programs -------------------------------------------------------

(defgroup idlwave-external-programs nil
  "Miscellaneous options for IDLWAVE mode."
  :group 'idlwave)

;; WARNING: The following variable has recently been moved from
;; idlwave-shell.el to this file.  I hope this does not break
;; anything.

(defcustom idlwave-shell-explicit-file-name "idl"
  "*If non-nil, is the command to run IDL.
Should be an absolute file path or path relative to the current environment
execution search path."
  :group 'idlwave-external-programs
  :type 'string)

(defcustom idlwave-help-application "idlhelp"
  "*The application providing reference help for programming."
  :group 'idlwave-external-programs
  :type 'string)

;;; Miscellaneous variables -------------------------------------------------

(defgroup idlwave-misc nil
  "Miscellaneous options for IDLWAVE mode."
  :group 'idlwave)

(defcustom idlwave-startup-message t
  "*Non-nil displays a startup message when `idlwave-mode' is first called."
  :group 'idlwave-misc
  :type 'boolean)

(defcustom idlwave-default-font-lock-items 
  '(pros-and-functions batch-files idl-keywords label goto common-blocks)
  "Items which should be fontified on the default fontification level 2.
IDLWAVE defines 3 levels of fontification.  Level 1 is very little, level 3
is everything and level 2 is specified by this list.
This variablle must be set before IDLWAVE gets loaded.  It is
a list of symbols, the following symbols are allowed.

pros-and-functions   Procedure and Function definitions
batch-files          Batch Files
idl-keywords         IDL Keywords
label                Statement Labels
goto                 Goto Statements
common-blocks        Common Blocks
keyword-parameters   Keyword Parameters in routine definitions and calls
system-variables     System Variables
fixme                FIXME: Warning in comments (on XEmacs only v. 21.0 and up)"
  :group 'idlwave-misc
  :type '(set
	  :indent 4 :inline t :greedy t
	  (const :tag "Procedure and Function definitions" pros-and-functions)
	  (const :tag "Batch Files"                        batch-files)
	  (const :tag "IDL Keywords (reserved words)"      idl-keywords)
	  (const :tag "Statement Labels"                   label)
	  (const :tag "Goto Statements"                    goto)
	  (const :tag "Common Blocks"                      common-blocks)
	  (const :tag "Keyword Parameters"                 keyword-parameters)
	  (const :tag "System Variables"                   system-variables)
	  (const :tag "FIXME: Warning"                     fixme)))

(defcustom idlwave-mode-hook nil
  "Normal hook.  Executed when a buffer is put into `idlwave-mode'."
  :group 'idlwave-misc
  :type 'hook)

(defcustom idlwave-load-hook nil
  "Normal hook.  Executed when idlwave.el is loaded."
  :group 'idlwave-misc
  :type 'hook)

;;;
;;; End customization variables section
;;;

;;; Non customization variables

;;; font-lock mode - Additions by Phil Williams, Ulrik Dickow and
;;; Simon Marshall <simon@gnu.ai.mit.edu>
;;; and Carsten Dominik...

(defconst idlwave-font-lock-keywords-1 nil
  "Subdued level highlighting for IDLWAVE mode.")

(defconst idlwave-font-lock-keywords-2 nil
  "Medium level highlighting for IDLWAVE mode.")

(defconst idlwave-font-lock-keywords-3 nil
  "Gaudy level highlighting for IDLWAVE mode.")

(let* ((oldp (or (string-match "Lucid" emacs-version)
		 (not (boundp 'emacs-minor-version))
		 (and (<= emacs-major-version 19) 
		      (<= emacs-minor-version 29))))

       ;; The following are the reserved words in idl.  Maybe we should
       ;; highlight some more stuff as well?       
       (idl-keywords
;	'("and" "or" "xor" "not"
;	  "eq" "ge" "gt" "le" "lt" "ne" 
;	  "for" "do" "endfor"
;	  "if" "then" "endif" "else" "endelse" 
;	  "case" "of" "endcase"
;	  "begin" "end"
;	  "repeat" "until" "endrep"
;	  "while" "endwhile" 
;	  "goto" "return"
;         "inherits" "mod" "on_error" "on_ioerror")  ;; on_error is not reserved
	(concat	"\\<\\("
		"and\\|begin\\|case\\|do\\|e\\(lse\\|nd\\(case\\|else\\|"
		"for\\|if\\|rep\\|while\\)?\\|q\\)\\|for\\|g\\(oto\\|[et]\\)"
		"\\|i\\(f\\|nherits\\)\\|l[et]\\|mod\\|n\\(e\\|ot\\)\\|"
		"o\\(n_ioerror\\|[fr]\\)\\|re\\(peat\\|turn\\)\\|then\\|"
		"until\\|while\\|xor"
		"\\)\\>"))

       ;; Procedure declarations.  Fontify keyword plus procedure name.
       ;; Function  declarations.  Fontify keyword plus function  name.
       (pros-and-functions
	'("\\<\\(function\\|pro\\)\\>[ \t]+\\(\\sw+\\(::\\sw+\\)?\\)"
	  (1 font-lock-keyword-face)
	  (2 font-lock-function-name-face nil t)))

       ;; Common blocks
       (common-blocks
	'("\\<\\(common\\)\\>[ \t]*\\(\\sw+\\)?[ \t]*,?"
	  (1 font-lock-keyword-face)	          ; "common"
	  (2 font-lock-reference-face nil t)      ; block name
	  (font-lock-match-c++-style-declaration-item-and-skip-to-next
	   ;; Start with point after block name and comma
	   (goto-char (match-end 0))  ; needed for XEmacs, could be nil 
	   nil
	   (1 font-lock-variable-name-face)       ; variable names
	   )))

       ;; Batch files
       (batch-files
	'("^[ \t]*\\(@[^ \t\n]+\\)" (1 font-lock-string-face)))

       ;; FIXME warning.  Unfortunately XEmacs does not have warning-face,
       ;; so we don't implement it by default.
       (fixme
	'("\\<FIXME:" (0 font-lock-warning-face t)))

       ;; Labels
       (label
	'("^[ \t]*\\([a-zA-Z]\\sw*:\\)" (1 font-lock-reference-face)))

       ;; The goto statement and its label
       (goto
	'("\\(goto\\)[ \t]*,[ \t]*\\([a-zA-Z]\\sw*\\)"
	  (1 font-lock-keyword-face)
	  (2 font-lock-reference-face)))

       ;; Named parameters, like /xlog or ,xrange=[]
       ;; This is anchored to the comma preceeding the keyword.
       ;; With continuation lines, works only during whole buffer fontification.
       (keyword-parameters
	'("[(,][ \t]*\\(\\$[ \t]*\n[ \t]*\\)?\\(/[a-zA-Z_]\\sw*\\|[a-zA-Z_]\\sw*[ \t]*=\\)"
	  (2 font-lock-reference-face)))

       ;; System variables stars with a bang.
       (system-variables
	'("\\(![a-zA-Z_]+\\(\\.\\sw+\\)?\\)"
	  (1 font-lock-variable-name-face)))
       ;; Special and unusual operators (not used because too noisy)
       (special-operators
	'("[<>#]" (0 font-lock-keyword-face)))

       ;; All single char operators (not used because too noisy)
       (all-operators
	'("[<>#]" (0 font-lock-keyword-face)))
	
       )

  ;; The following line is just a dummy to make the compiler shut up
  ;; about veraibles bound but not used.
  (setq oldp oldp
	idl-keywords idl-keywords
	pros-and-functions pros-and-functions
	common-blocks common-blocks
	batch-files batch-files
	fixme fixme
	label label
	goto goto
	keyword-parameters keyword-parameters
	system-variables system-variables
	special-operators special-operators
	all-operators all-operators)	

  (setq idlwave-font-lock-keywords-1
	(list pros-and-functions
	      batch-files
	      ))

  (setq idlwave-font-lock-keywords-2
	(mapcar 'symbol-value idlwave-default-font-lock-items))

;  (setq idlwave-font-lock-keywords-2 
;	(append idlwave-font-lock-keywords-1
;		(list idl-keywords
;		      label goto
;		      common-blocks
;		      )))

  (setq idlwave-font-lock-keywords-3 
	(append idlwave-font-lock-keywords-2
		(list 
		 keyword-parameters
		 system-variables
		 )))
  )
     


(defvar idlwave-font-lock-keywords idlwave-font-lock-keywords-2
  "Default expressions to highlight in IDLWAVE mode.")

(defvar idlwave-font-lock-defaults
  '((idlwave-font-lock-keywords
     idlwave-font-lock-keywords-1 
     idlwave-font-lock-keywords-2
     idlwave-font-lock-keywords-3)
    nil t 
    ((?$ . "w") (?_ . "w") (?. . "w")) 
    beginning-of-line))

(put 'idlwave-mode 'font-lock-defaults 
     idlwave-font-lock-defaults) ; XEmacs

(defconst idlwave-comment-line-start-skip "^[ \t]*;"
  "Regexp to match the start of a full-line comment.
That is the _beginning_ of a line containing a comment delmiter `;' preceded
only by whitespace.")

(defconst idlwave-begin-block-reg "\\<\\(pro\\|function\\|begin\\|case\\)\\>"
  "Regular expression to find the beginning of a block. The case does
not matter. The search skips matches in comments.")

(defconst idlwave-begin-unit-reg "\\<\\(pro\\|function\\)\\>\\|\\`"
  "Regular expression to find the beginning of a unit. The case does
not matter.")

(defconst idlwave-end-unit-reg "\\<\\(pro\\|function\\)\\>\\|\\'"
  "Regular expression to find the line that indicates the end of unit.
This line is the end of buffer or the start of another unit. The case does
not matter. The search skips matches in comments.")

(defconst idlwave-continue-line-reg "\\<\\$"
  "Regular expression to match a continued line.")

(defconst idlwave-end-block-reg
  "\\<end\\(\\|case\\|else\\|for\\|if\\|rep\\|while\\)\\>"
  "Regular expression to find the end of a block. The case does
not matter. The search skips matches found in comments.")

(defconst idlwave-block-matches
  '(("pro"      . "end")
    ("function" . "end")
    ("case"     . "endcase")
    ("else"     . "endelse")
    ("for"      . "endfor")
    ("then"     . "endif")
    ("repeat"   . "endrep")
    ("while"    . "endwhile"))
  "Matches between statements and the corresponding END variant.
The cars are the reservedwords starting a block.  If the block really
begins with BEGIN, the cars are the reserved words before the begin
which can be used to identify the block type.
This is used to check for the correct END type, to close blocks and
to expand generic end statements to their detailed form.")

(defconst idlwave-block-match-regexp
  "\\<\\(else\\|for\\|then\\|repeat\\|while\\)\\>"
"Regular expression matching reserved words which can stand before
blocks starting with a BEGIN statement.  The matches must have associations
`idlwave-block-matches'")

;; FIXME: do we need a colon in this class?  Are class names like a::b
;; identifyers?
;; FIXME: can we have other general regexp stuffer here which can be reused
;;        elsewhere?
(defconst idlwave-identifier "[a-zA-Z][a-zA-Z0-9$_]+"
  "Regular expression matching an IDL identifier.")

(defconst idlwave-sysvar (concat "!" idlwave-identifier)
  "Regular expression matching IDL system variables.")

(defconst idlwave-variable (concat idlwave-identifier "\\|" idlwave-sysvar)
  "Regular expression matching IDL variable names.")

(defconst idlwave-label (concat idlwave-identifier ":")
  "Regular expression matching IDL labels.")

(defconst idlwave-statement-match
  (list
   ;; "endif else" is the the only possible "end" that can be
   ;; followed by a statement on the same line.
   '(endelse . ("end\\(\\|if\\)\\s +else" "end\\(\\|if\\)\\s +else"))
   ;; all other "end"s can not be followed by a statement.
   (cons 'end (list idlwave-end-block-reg nil))
   '(if . ("if\\>" "then"))
   '(for . ("for\\>" "do"))
   '(begin . ("begin\\>" nil))
   '(pdef . ("pro\\>\\|function\\>" nil))
   '(while . ("while\\>" "do"))
   '(repeat . ("repeat\\>" "repeat"))
   '(goto . ("goto\\>" nil))
   '(case . ("case\\>" nil))
   (cons 'call (list (concat idlwave-identifier "\\(\\s *$\\|\\s *,\\)") nil))
   '(assign . ("[^=\n]*=" nil)))
  
  "Associated list of statement matching regular expresssions.
Each regular expression matches the start of an IDL statment.  The
first element of each association is a symbol giving the statement
type.  The associated value is a list.  The first element of this list
is a regular expression matching the start of an IDL statement for
identifying the statement type.  The second element of this list is a
regular expression for finding a substatement for the type.  The
substatement starts after the end of the found match modulo
whitespace.  If it is nil then the statement has no substatement.  The
list order matters since matching an assignment statement exactly is
not possible without parsing.  Thus assignment statement become just
the leftover unidentified statments containing and equal sign. "  )

(defvar idlwave-fill-function 'auto-fill-function
  "IDL mode auto fill function.")

(defvar idlwave-comment-indent-function 'comment-indent-function
  "IDL mode comment indent function.")

;; Note that this is documented in the v18 manuals as being a string
;; of length one rather than a single character.
;; The code in this file accepts either format for compatibility.
(defvar idlwave-comment-indent-char ?\ 
  "Character to be inserted for IDL comment indentation.
Normally a space.")

(defconst idlwave-continuation-char ?$
  "Character which is inserted as a last character on previous line by
   \\[idlwave-split-line] to begin a continuation line.  Normally $.")

(defconst idlwave-mode-version " 3.3b")

(defmacro idlwave-keyword-abbrev (&rest args)
  "Creates a function for abbrev hooks to call `idlwave-check-abbrev' with args."
  (` (quote (lambda ()
              (, (append '(idlwave-check-abbrev) args))))))

;; If I take the time I can replace idlwave-keyword-abbrev with
;; idlwave-code-abbrev and remove the quoted abbrev check from
;; idlwave-check-abbrev.  Then, e.g, (idlwave-keyword-abbrev 0 t) becomes
;; (idlwave-code-abbrev idlwave-check-abbrev 0 t).  In fact I should change
;; the name of idlwave-check-abbrev to something like idlwave-modify-abbrev.

(defmacro idlwave-code-abbrev (&rest args)
  "Creates a function for abbrev hooks that ensures abbrevs are not quoted.
Specifically, if the abbrev is in a comment or string it is unexpanded.
Otherwise ARGS forms a list that is evaluated."
  (` (quote (lambda ()
	      (, (prin1-to-string args))  ;; Puts the code in the doc string
              (if (idlwave-quoted) (progn (unexpand-abbrev) nil)
                (, (append args)))))))

(defvar idlwave-mode-map (make-sparse-keymap)
  "Keymap used in IDL mode.")

(defvar idlwave-mode-syntax-table (make-syntax-table)
  "Syntax table in use in `idlwave-mode' buffers.")

(modify-syntax-entry ?+   "."  idlwave-mode-syntax-table)
(modify-syntax-entry ?-   "."  idlwave-mode-syntax-table)
(modify-syntax-entry ?*   "."  idlwave-mode-syntax-table)
(modify-syntax-entry ?/   "."  idlwave-mode-syntax-table)
(modify-syntax-entry ?^   "."  idlwave-mode-syntax-table)
(modify-syntax-entry ?#   "."  idlwave-mode-syntax-table)
(modify-syntax-entry ?=   "."  idlwave-mode-syntax-table)
(modify-syntax-entry ?%   "."  idlwave-mode-syntax-table)
(modify-syntax-entry ?<   "."  idlwave-mode-syntax-table)
(modify-syntax-entry ?>   "."  idlwave-mode-syntax-table)
(modify-syntax-entry ?\'  "\"" idlwave-mode-syntax-table)
(modify-syntax-entry ?\"  "\"" idlwave-mode-syntax-table)
(modify-syntax-entry ?\\  "."  idlwave-mode-syntax-table)
(modify-syntax-entry ?_   "_"  idlwave-mode-syntax-table)
(modify-syntax-entry ?{   "(}" idlwave-mode-syntax-table)
(modify-syntax-entry ?}   "){" idlwave-mode-syntax-table)
(modify-syntax-entry ?$   "_"  idlwave-mode-syntax-table)
(modify-syntax-entry ?.   "."  idlwave-mode-syntax-table)
(modify-syntax-entry ?\;  "<"  idlwave-mode-syntax-table)
(modify-syntax-entry ?\n  ">"  idlwave-mode-syntax-table)
(modify-syntax-entry ?\f  ">"  idlwave-mode-syntax-table)

(defvar idlwave-find-symbol-syntax-table
  (copy-syntax-table idlwave-mode-syntax-table)
  "Syntax table that treats symbol characters as word characters.")

(modify-syntax-entry ?$   "w"  idlwave-find-symbol-syntax-table)
(modify-syntax-entry ?_   "w"  idlwave-find-symbol-syntax-table)

(defun idlwave-action-and-binding (key cmd &optional select)
  "KEY and CMD are made into a key binding and an indent action.
KEY is a string - same as for the `define-key' function.  CMD is a
function of no arguments or a list to be evalauated.  CMD is bound to
KEY in `idlwave-mode-map' by defining an anonymous function calling
`self-insert-command' followed by CMD.  If KEY contains more than one
character a binding will only be set if SELECT is 'both.

(KEY . CMD\ is also placed in the `idlwave-indent-expand-table',
replacing any previous value for KEY.  If a binding is not set then it
will instead be placed in `idlwave-indent-action-table'.

If the optional argument SELECT is nil then an action and binding are
created.  If SELECT is 'noaction, then a binding is always set and no
action is created.  If SELECT is 'both then an action and binding
will both be created even if KEY contains more than one character.
Otherwise, if SELECT is non-nil then only an action is created.

Some examples:
No spaces before and 1 after a comma
   (idlwave-action-and-binding \",\"  '(idlwave-surround 0 1))
A minimum of 1 space before and after `=' (see `idlwave-expand-equal').
   (idlwave-action-and-binding \"=\"  '(idlwave-expand-equal -1 -1))
Capitalize system variables - action only
   (idlwave-action-and-binding idlwave-sysvar '(capitalize-word 1) t)"
  (if (not (equal select 'noaction))
      ;; Add action
      (let* ((table (if select 'idlwave-indent-action-table
                      'idlwave-indent-expand-table))
             (cell (assoc key (eval table))))
        (if cell
            ;; Replace action command
            (setcdr cell cmd)
          ;; New action
          (set table (append (eval table) (list (cons key cmd)))))))
  ;; Make key binding for action
  (if (or (and (null select) (= (length key) 1))
          (equal select 'noaction)
          (equal select 'both))
      (define-key idlwave-mode-map key
        (append '(lambda ()
                            (interactive)
                            (self-insert-command 1))
                (list (if (listp cmd)
                          cmd
                        (list cmd)))))))

;(defvar idlwave-debug-map nil
;  "Keymap used in debugging in conjunction with `idlwave-shell-mode'.
;It is set upon starting `idlwave-shell-mode'.")
(fset 'idlwave-debug-map (make-sparse-keymap))

(define-key idlwave-mode-map "'"        'idlwave-show-matching-quote)
(define-key idlwave-mode-map "\""       'idlwave-show-matching-quote)
(define-key idlwave-mode-map "\M-\t"    'idlwave-hard-tab)
(define-key idlwave-mode-map "\C-c;"    'idlwave-toggle-comment-region)
(define-key idlwave-mode-map "\C-\M-a"  'idlwave-beginning-of-subprogram)
(define-key idlwave-mode-map "\C-\M-e"  'idlwave-end-of-subprogram)
(define-key idlwave-mode-map "\C-c{"    'idlwave-beginning-of-block)
(define-key idlwave-mode-map "\C-c}"    'idlwave-end-of-block)
(define-key idlwave-mode-map "\C-c]"    'idlwave-close-block)
(define-key idlwave-mode-map "\M-\C-h"  'idlwave-mark-subprogram)
(define-key idlwave-mode-map "\M-\C-n"  'idlwave-forward-block)
(define-key idlwave-mode-map "\M-\C-p"  'idlwave-backward-block)
(define-key idlwave-mode-map "\M-\C-d"  'idlwave-down-block)
(define-key idlwave-mode-map "\M-\C-u"  'idlwave-backward-up-block)
(define-key idlwave-mode-map "\M-\r"    'idlwave-split-line)
(define-key idlwave-mode-map "\M-\C-q"  'idlwave-indent-subprogram)
(define-key idlwave-mode-map "\C-c\C-p" 'idlwave-previous-statement)
(define-key idlwave-mode-map "\C-c\C-n" 'idlwave-next-statement)
;; (define-key idlwave-mode-map "\r"       'idlwave-newline)
;; (define-key idlwave-mode-map "\t"       'idlwave-indent-line)
(define-key idlwave-mode-map "\C-c\C-a" 'idlwave-auto-fill-mode)
(define-key idlwave-mode-map "\M-q"     'idlwave-fill-paragraph)
(define-key idlwave-mode-map "\M-s"     'idlwave-edit-in-idlde)
(define-key idlwave-mode-map "\C-c\C-i" 'idlwave-doc-header)
(define-key idlwave-mode-map "\C-c\C-m" 'idlwave-doc-modification)
(define-key idlwave-mode-map "\C-c\C-c" 'idlwave-case)
(define-key idlwave-mode-map "\C-c\C-d" 'idlwave-debug-map)
(define-key idlwave-mode-map "\C-c\C-f" 'idlwave-for)
;;  (define-key idlwave-mode-map "\C-c\C-f" 'idlwave-function)
;;  (define-key idlwave-mode-map "\C-c\C-p" 'idlwave-procedure)
(define-key idlwave-mode-map "\C-c\C-r" 'idlwave-repeat)
(define-key idlwave-mode-map "\C-c\C-w" 'idlwave-while)
(define-key idlwave-mode-map "\C-c\C-s" 'idlwave-shell)
(define-key idlwave-mode-map "\C-l"     'idlwave-indent-and-fontify)


;;  Rycho's indent fcn
(defun idlwave-indent-and-fontify ()
  (interactive)
  (save-excursion
;;      (mark-whole-buffer)
;;  (indent-region nil nil nil)
        (idlwave-indent-subprogram)
        (font-lock-fontify-buffer)))

;;



;; Routine info stuff: autoloads and keys
(autoload 'idlwave-find-module "idlwave-rinfo" 
  "Find source code of a module." t)
(autoload 'idlwave-routine-info "idlwave-rinfo"
  "Display routine info of a module." t)
(autoload 'idlwave-complete "idlwave-rinfo"
  "Complete module or keyword." t)
(autoload 'idlwave-update-routine-info "idlwave-rinfo"
  "Update the routine info stuff." t)
(define-key idlwave-mode-map "\C-c\C-v"   'idlwave-find-module)
(define-key idlwave-mode-map "\C-c?"      'idlwave-routine-info)
(define-key idlwave-mode-map [(meta tab)] 'idlwave-complete)
(define-key idlwave-mode-map "\C-c\C-u"   'idlwave-update-routine-info)

;; Set action and key bindings.
;; See description of the function `idlwave-action-and-binding'.
;; Automatically add spaces for the following characters
(idlwave-action-and-binding "&"  '(idlwave-surround -1 -1))
(idlwave-action-and-binding "<"  '(idlwave-surround -1 -1))
(idlwave-action-and-binding ">"  '(idlwave-surround -1 -1 '(?-)))
(idlwave-action-and-binding ","  '(idlwave-surround 0 -1))
;; Automatically add spaces to equal sign if not keyword
(idlwave-action-and-binding "="  '(idlwave-expand-equal -1 -1))

;;;
;;; Abbrev Section
;;;
;;; When expanding abbrevs and the abbrev hook moves backward, an extra
;;; space is inserted (this is the space typed by the user to expanded
;;; the abbrev).
;;;

(condition-case nil
    (modify-syntax-entry (string-to-char idlwave-abbrev-start-char) 
			 "w" idlwave-mode-syntax-table)
  (error nil))

(defvar idlwave-mode-abbrev-table nil
  "Abbreviation table used for IDLWAVE mode")
(define-abbrev-table 'idlwave-mode-abbrev-table ())
(let ((abbrevs-changed nil)          ;; mask the current value to avoid save
      (tb idlwave-mode-abbrev-table)
      (c idlwave-abbrev-start-char))
  ;;
  ;; Templates
  ;;
  (define-abbrev tb (concat c "c")   "" (idlwave-code-abbrev idlwave-case))
  (define-abbrev tb (concat c "f")   "" (idlwave-code-abbrev idlwave-for))
  (define-abbrev tb (concat c "fu")  "" (idlwave-code-abbrev idlwave-function))
  (define-abbrev tb (concat c "pr")  "" (idlwave-code-abbrev idlwave-procedure))
  (define-abbrev tb (concat c "r")   "" (idlwave-code-abbrev idlwave-repeat))
  (define-abbrev tb (concat c "w")   "" (idlwave-code-abbrev idlwave-while))
  (define-abbrev tb (concat c "i")   "" (idlwave-code-abbrev idlwave-if))
  (define-abbrev tb (concat c "elif") "" (idlwave-code-abbrev idlwave-elif))
  ;;
  ;; Keywords, system functions, conversion routines
  ;;
  (define-abbrev tb (concat c "b")  "begin"        (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb (concat c "co") "common"       (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb (concat c "cb") "byte()"       (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "cx") "fix()"        (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "cl") "long()"       (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "cf") "float()"      (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "cs") "string()"     (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "cc") "complex()"    (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "cd") "double()"     (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "e")  "else"         (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb (concat c "ec") "endcase"      'idlwave-show-begin)
  (define-abbrev tb (concat c "ee") "endelse"      'idlwave-show-begin)
  (define-abbrev tb (concat c "ef") "endfor"       'idlwave-show-begin)
  (define-abbrev tb (concat c "ei") "endif else if" 'idlwave-show-begin)
  (define-abbrev tb (concat c "el") "endif else"   'idlwave-show-begin)
  (define-abbrev tb (concat c "en") "endif"        'idlwave-show-begin)
  (define-abbrev tb (concat c "er") "endrep"       'idlwave-show-begin)
  (define-abbrev tb (concat c "ew") "endwhile"     'idlwave-show-begin)
  (define-abbrev tb (concat c "g")  "goto,"        (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb (concat c "h")  "help,"        (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "k")  "keyword_set()" (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "n")  "n_elements()" (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "on") "on_error,"    (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "oi") "on_ioerror,"  (idlwave-keyword-abbrev 0 1))
  (define-abbrev tb (concat c "ow") "openw,"       (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "or") "openr,"       (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "ou") "openu,"       (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "p")  "print,"       (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "pt") "plot,"        (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "re") "read,"        (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "rf") "readf,"       (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "ru") "readu,"       (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "rt") "return"       (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "sc") "strcompress()" (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "sn") "strlen()"     (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "sl") "strlowcase()" (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "su") "strupcase()"  (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "sm") "strmid()"     (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "sp") "strpos()"     (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "st") "strput()"     (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "sr") "strtrim()"    (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "t")  "then"         (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb (concat c "u")  "until"        (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb (concat c "wu") "writeu,"      (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "ine") "if n_elements() eq 0 then"
    (idlwave-keyword-abbrev 11))
  (define-abbrev tb (concat c "inn") "if n_elements() ne 0 then"
    (idlwave-keyword-abbrev 11))
  (define-abbrev tb (concat c "np") "n_params()"   (idlwave-keyword-abbrev 0))
  (define-abbrev tb (concat c "s")  "size()"       (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "wi") "widget_info()" (idlwave-keyword-abbrev 1))
  (define-abbrev tb (concat c "wc") "widget_control," (idlwave-keyword-abbrev 0))
  
  ;; This section is reserved words only. (From IDL user manual)
  ;;
  (define-abbrev tb "and"        "and"        (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "begin"      "begin"      (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "case"       "case"       (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "common"     "common"     (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "do"         "do"         (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "else"       "else"       (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "end"        "end"        'idlwave-show-begin-check)
  (define-abbrev tb "endcase"    "endcase"    'idlwave-show-begin-check)
  (define-abbrev tb "endelse"    "endelse"    'idlwave-show-begin-check)
  (define-abbrev tb "endfor"     "endfor"     'idlwave-show-begin-check)
  (define-abbrev tb "endif"      "endif"      'idlwave-show-begin-check)
  (define-abbrev tb "endrep"     "endrep"     'idlwave-show-begin-check)
  (define-abbrev tb "endwhi"     "endwhi"     'idlwave-show-begin-check)
  (define-abbrev tb "endwhile"   "endwhile"   'idlwave-show-begin-check)
  (define-abbrev tb "eq"         "eq"         (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "for"        "for"        (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "function"   "function"   (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "ge"         "ge"         (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "goto"       "goto"       (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "gt"         "gt"         (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "if"         "if"         (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "le"         "le"         (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "lt"         "lt"         (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "mod"        "mod"        (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "ne"         "ne"         (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "not"        "not"        (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "of"         "of"         (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "on_ioerror" "on_ioerror" (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "or"         "or"         (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "pro"        "pro"        (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "repeat"     "repeat"     (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "then"       "then"       (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "until"      "until"      (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "while"      "while"      (idlwave-keyword-abbrev 0 t))
  (define-abbrev tb "xor"        "xor"        (idlwave-keyword-abbrev 0 t)))
;;
;;
;;

(defvar imenu-create-index-function)
(defvar extract-index-name-function)
(defvar prev-index-position-function)
(defvar imenu-extract-index-name-function)
(defvar imenu-prev-index-position-function)
;; defined later - so just make the compiler shut up
(defvar idlwave-mode-menu)  
(defvar idlwave-mode-debug-menu)

;;;###autoload
(defun idlwave-mode ()
  "Major mode for editing IDL and WAVE CL .pro files.

The main features of this mode are

1. Indentation and Formatting
   --------------------------
   Like other Emacs programming modes, C-j inserts a newline and indents.
   TAB is used for explicit indentation of the current line.

   To start a continuation line, use \\[idlwave-split-line].  This function can also
   be used in the middle of a line to split the line at that point.
   When used inside a long constant string, the string is split at
   that point with the `+' concatenation operator.

   Comments are indented as follows:

   `;;;' Indentation remains unchanged.
   `;;'  Indent like the surrounding code
   `;'   Indent to a minimum column.

   The indentation of comments starting in column 0 is never changed.

   Use \\[idlwave-fill-paragraph] to refill a paragraph inside a comment.  The indentation
   of the second line of the paragraph relative to the first will be
   retained.  Use \\[idlwave-auto-fill-mode] to toggle auto-fill mode for these comments.
   When the variable `idlwave-fill-comment-line-only' is nil, code
   can also be auto-filled and auto-indented (not recommended).

   To convert pre-existing IDL code to your formatting style, mark the
   entire buffer with \\[mark-whole-buffer] and execute \\[idlwave-expand-region-abbrevs].
   Then mark the entire buffer again followed by \\[indent-region] (`indent-region').

2. Code Templates and Abbreviations
   --------------------------------
   Many Abbreviations are predifine to expand to code fragments and templates.
   The abbreviations start generally with a `\\`.  Some examples

   \\pr        PROCEDURE template
   \\fu        FUNCTION template
   \\c         CASE statement template
   \\f         FOR loop template
   \\r         REPEAT Loop template
   \\w         WHILE loop template
   \\i         IF statement template
   \\elif      IF-ELSE statement template
   \\b         BEGIN
   
   For a full list, use \\[idlwave-list-abbrevs].  Some templates also have
   direct keybindings - see the list of keybindings below.

   \\[idlwave-doc-header] inserts a documentation header at the beginning of the
   current program unit (pro, function or main).  Change log entries
   can be added to the current program unit with \\[idlwave-doc-modification].

3. Automatic Case Conversion
   -------------------------
   The case of reserved words and some abbrevs is controlled by
   `idlwave-reserved-word-upcase' and `idlwave-abbrev-change-case'.

4. Automatic END completion
   ------------------------
   If the variable `idlwave-expand-generic-end' is non-nil, each END typed
   will be converted to the specific version, like ENDIF, ENDFOR, etc.

5. Routine Info
   ------------
   IDLWAVE displays information about the calling sequence and the accepted
   keyword parameters of a procedure or function with \\[idlwave-routine-info].
   \\[idlwave-find-module] jumps to the source file of a module.
   These commands know about system routines, all routines in idlwave-mode
   buffers and (when the idlwave-shell is active) about all modules
   currently compiled under this shell.  Use \\[idlwave-update-routine-info] to update this
   information, which is also used for completion (see next item).

6. Completion
   ----------
   \\[idlwave-complete] completes the names of procedures, functions and
   keyword parameters.  It is context sensitive and figures out what
   is expected at point (procedure/function/keyword).

7. Hooks
   -----
   Loading idlwave.el runs `idlwave-load-hook'.
   Turning on IDLWAVE mode runs `idlwave-mode-hook'.

8. Documentation and Customization
   -------------------------------
   A detailed description of this mode and how to customize it is
   available in the comment section of the file `idlwavel.el'.  To
   view this information, use \\[idlwave-show-commentary].

9. Keybindings
   -----------
   Here is a list of all keybindings of this mode.
   If some of the key bindings below show with ??, use \\[describe-key]
   followed by the key sequence to see what the key sequence does.

\\{idlwave-mode-map}"

  (interactive)
  (kill-all-local-variables)
  
  (if idlwave-startup-message
      (message "Emacs IDLWAVE mode version %s." idlwave-mode-version))
  (setq idlwave-startup-message nil)
  
  (setq local-abbrev-table idlwave-mode-abbrev-table)
  (set-syntax-table idlwave-mode-syntax-table)
  
  (set (make-local-variable 'indent-line-function) 'idlwave-indent-and-action)
  
  (make-local-variable idlwave-comment-indent-function)
  (set idlwave-comment-indent-function 'idlwave-comment-hook)
  
  (set (make-local-variable 'comment-start-skip) ";+[ \t]*")
  (set (make-local-variable 'comment-start) ";")
  (set (make-local-variable 'require-final-newline) t)
  (set (make-local-variable 'abbrev-all-caps) t)
  (set (make-local-variable 'indent-tabs-mode) nil)
  
  (use-local-map idlwave-mode-map)

  (when (featurep 'easymenu)
    (easy-menu-add idlwave-mode-menu idlwave-mode-map)
    (easy-menu-add idlwave-mode-debug-menu idlwave-mode-map))

  (setq mode-name "IDLWAVE")
  (setq major-mode 'idlwave-mode)
  (setq abbrev-mode t)
  
  (set (make-local-variable idlwave-fill-function) 'idlwave-auto-fill)
  (setq comment-end "")
  (set (make-local-variable 'comment-multi-line) nil)
  (set (make-local-variable 'paragraph-separate) "[ \t\f]*$\\|[ \t]*;+[ \t]*$")
  (set (make-local-variable 'paragraph-start) "[ \t\f]\\|[ \t]*;+[ \t]")
  (set (make-local-variable 'paragraph-ignore-fill-prefix) nil)
  (set (make-local-variable 'parse-sexp-ignore-comments) nil)
  
  ;; Set tag table list to use IDLTAGS as file name.
  (if (boundp 'tag-table-alist)
      (add-to-list 'tag-table-alist '("\\.pro$" . "IDLTAGS")))
  
  ;; Font-lock additions - originally Phil Williams, then Ulrik Dickow
  ;; Following line is for Emacs - XEmacs uses the corresponding porperty
  ;; on the `idlwave-mode' symbol.
  (set (make-local-variable 'font-lock-defaults) idlwave-font-lock-defaults)

  ;; Imenu setup
  (set (make-local-variable 'imenu-create-index-function)
       'imenu-default-create-index-function)
  (set (make-local-variable 'imenu-extract-index-name-function)
       'idlwave-unit-name)
  (set (make-local-variable 'imenu-prev-index-position-function)
       'idlwave-prev-index-position)

  ;; Make a local post-command-hook and add our hook to it
  (make-local-hook 'post-command-hook)
  (add-hook 'post-command-hook 'idlwave-command-hook nil t)

  ;; Run the mode hook
  (run-hooks 'idlwave-mode-hook))

;;
;;  Done with start up and initialization code.
;;  The remaining routines are the code formatting functions.
;;

(defun idlwave-push-mark (&rest rest)
  "Push mark for compatibility with Emacs 18/19."
  (if (fboundp 'iconify-frame)
      (apply 'push-mark rest)
    (push-mark)))

(defun idlwave-hard-tab ()
  "Inserts TAB in buffer in current position."
  (interactive)
  (insert "\t"))

;;; This stuff is experimental

(defvar idlwave-command-hook nil
  "If non-nil, a list that can be evaluated using `eval'.
It is evaluated in the lisp function `idlwave-command-hook' which is
placed in `post-command-hook'.")

(defun idlwave-command-hook ()
  "Command run after every command.
Evaluates a non-nil value of the *variable* `idlwave-command-hook' and
sets the variable to zero afterwards."
  (and idlwave-command-hook
       (listp idlwave-command-hook)
       (condition-case nil
	   (eval idlwave-command-hook)
	 (error nil)))
  (setq idlwave-command-hook nil))

;;; End experiment

;; It would be better to use expand.el for better abbrev handling and
;; versatility.

(defun idlwave-check-abbrev (arg &optional reserved)
  "Reverses abbrev expansion if in comment or string.
Argument ARG is the number of characters to move point
backward if `idlwave-abbrev-move' is non-nil.
If optional argument RESERVED is non-nil then the expansion
consists of reserved words, which will be capitalized if
`idlwave-reserved-word-upcase' is non-nil.
Otherwise, the abbrev will be capitalized if `idlwave-abbrev-change-case'
is non-nil, unless its value is \`down in which case the abbrev will be
made into all lowercase.
Returns non-nil if abbrev is left expanded."
  (if (idlwave-quoted)
      (progn (unexpand-abbrev)
             nil)
    (if (and reserved idlwave-reserved-word-upcase)
        (upcase-region last-abbrev-location (point))
      (cond
       ((equal idlwave-abbrev-change-case 'down)
        (downcase-region last-abbrev-location (point)))
       (idlwave-abbrev-change-case
        (upcase-region last-abbrev-location (point)))))
    (if (and idlwave-abbrev-move (> arg 0))
        (if (boundp 'post-command-hook)
            (setq idlwave-command-hook (list 'backward-char (1+ arg)))
          (backward-char arg)))
    t))

(defun idlwave-in-comment ()
  "Returns t if point is inside a comment, nil otherwise."
  (save-excursion
    (let ((here (point)))
      (and (idlwave-goto-comment) (> here (point))))))

(defun idlwave-goto-comment ()
  "Move to start of comment delimiter on current line.
Moves to end of line if there is no comment delimiter.
Ignores comment delimiters in strings.
Returns point if comment found and nil otherwise."
  (let ((eos (progn (end-of-line) (point)))
        (data (match-data))
        found)
    ;; Look for first comment delimiter not in a string
    (beginning-of-line)
    (setq found (search-forward comment-start eos 'lim))
    (while (and found (idlwave-in-quote))
      (setq found (search-forward comment-start eos 'lim)))
    (store-match-data data)
    (and found (not (idlwave-in-quote))
         (progn
           (backward-char 1)
           (point)))))

(defun idlwave-show-matching-quote ()
  "Insert quote and show matching quote if this is end of a string."
  (interactive)
  (let ((bq (idlwave-in-quote))
        (inq last-command-char))
    (if (and bq (not (idlwave-in-comment)))
        (let ((delim (char-after bq)))
          (insert inq)
          (if (eq inq delim)
              (save-excursion
                (goto-char bq)
                (sit-for 1))))
      ;; Not the end of a string
      (insert inq))))

(defun idlwave-show-begin-check ()
  "Ensure that the previous word was a token before `idlwave-show-begin'.
An END token must be preceded by whitespace."
  (if
      (save-excursion
        (backward-word 1)
        (backward-char 1)
        (looking-at "[ \t\n\f]"))
      (idlwave-show-begin)))

(defun idlwave-show-begin ()
  "Finds the start of current block and blinks to it for a second.
Also checks if the correct end statement has been used."
  ;; All end statements are reserved words
  (let* ((pos (point))
	 end end1)
    (when (and (idlwave-check-abbrev 0 t)
	       idlwave-show-block)
      (save-excursion
	;; Move inside current block
	(setq end (buffer-substring 
		   (save-excursion (skip-chars-backward "a-zA-Z")
				   (point))
		   (point)))
	(idlwave-beginning-of-statement)
	(idlwave-block-jump-out -1 'nomark)
	(when (setq end1 (cdr (idlwave-block-master)))
	  (cond
	   ((null end1)) ; no-opeartion
	   ((string= (downcase end) (downcase end1))
	    (sit-for 1))
	   ((string= (downcase end) "end")
	    ;; A generic end
	    (if idlwave-expand-generic-end
		(save-excursion
		  (goto-char pos)
		  (backward-char 3)
		  (insert (if (string= end "END") (upcase end1) end1))
		  (delete-char 3)))
	    (sit-for 1))
	   (t
	    (beep)
	    (message "Warning: Shouldn't this be \"%s\" instead of \"%s\"?" 
		     end1 end)
	    (sit-for 1))))))))

(defun idlwave-block-master ()
  (let ((case-fold-search t))
    (save-excursion
      (cond
       ((looking-at "pro\\|case\\|function\\>")
	(assoc (downcase (match-string 0)) idlwave-block-matches))
       ((and (looking-at "begin\\>")
	     (re-search-backward idlwave-block-match-regexp nil t))
	(assoc (downcase (match-string 1))
	       idlwave-block-matches))
       (t nil)))))

(defun idlwave-close-block ()
  "Terminate the current block with the correct END statement."
  (interactive)
  (let ((case-fold-search t) end)
    (save-excursion
      (idlwave-beginning-of-statement)
      (idlwave-block-jump-out -1 'nomark)
      (if (setq end (idlwave-block-master))
	  (setq end (cdr end))
	(error "Cannot close block")))
    (insert end)
    (idlwave-newline)))

(defun idlwave-surround (&optional before after escape-chars)
  "Surround the character before point with blanks.
Optional arguments BEFORE and AFTER affect the behavior before and
after the previous character. See description of `idlwave-make-space'.

The function does nothing if any of the following conditions is true:
- `idlwave-surround-by-blank' is nil
- the character before point is inside a string or comment

When the character 2 positions before point is a member of
ESCAPE-CHARS, BEFORE is forced to nil."

  (if (and idlwave-surround-by-blank
	   (not (idlwave-quoted)))
      (progn
	(if (memq (char-after (- (point) 2)) escape-chars)
	    (setq before nil))
        (backward-char 1)
        (save-restriction
          (let ((here (point)))
            (skip-chars-backward " \t")
            (if (bolp)
                ;; avoid clobbering indent
                (progn
                  (move-to-column (idlwave-calculate-indent))
                  (if (<= (point) here)
                      (narrow-to-region (point) here))
                  (goto-char here)))
            (idlwave-make-space before))
          (skip-chars-forward " \t"))
        (forward-char 1)
        (idlwave-make-space after)
        ;; Check to see if the line should auto wrap
        (if (and (equal (char-after (1- (point))) ? )
                 (> (current-column) fill-column))
            (funcall auto-fill-function)))))

(defun idlwave-make-space (n)
  "Make space at point.
The space affected is all the spaces and tabs around point.
If n is non-nil then point is left abs(n) spaces from the beginning of
the contiguous space.
The amount of space at point is determined by N.
If the value of N is:
nil   - do nothing.
c > 0 - exactly c spaces.
c < 0 - a minimum of -c spaces, i.e., do not change if there are
        already -c spaces.
0     - no spaces."
  (if (integerp n)
      (let
          ((start-col (progn (skip-chars-backward " \t") (current-column)))
           (left (point))
           (end-col (progn (skip-chars-forward " \t") (current-column))))
        (delete-horizontal-space)
        (cond
         ((> n 0)
          (idlwave-indent-to (+ start-col n))
          (goto-char (+ left n)))
         ((< n 0)
          (idlwave-indent-to end-col (- n))
          (goto-char (- left n)))
         ;; n = 0, done
         ))))

(defun idlwave-newline ()
  "Inserts a newline and indents the current and previous line."
  (interactive)
  ;;
  ;; Handle unterminated single and double quotes
  ;; If not in a comment and in a string then insertion of a newline
  ;; will mean unbalanced quotes.
  ;;
  (if (and (not (idlwave-in-comment)) (idlwave-in-quote))
      (progn (beep)
             (message "Warning: unbalanced quotes?")))
  (newline)
  ;;
  ;; The current line is being split, the cursor should be at the
  ;; beginning of the new line skipping the leading indentation.
  ;;
  ;; The reason we insert the new line before indenting is that the
  ;; indenting could be confused by keywords (e.g. END) on the line
  ;; after the split point.  This prevents us from just using
  ;; `indent-for-tab-command' followed by `newline-and-indent'.
  ;;
  (beginning-of-line 0)
  (idlwave-indent-line)
  (forward-line)
  (idlwave-indent-line))

;;
;;  Use global variable 'comment-column' to set parallel comment
;;
;; Modeled on lisp.el
;; Emacs Lisp and IDL (Wave CL) have identical comment syntax
(defun idlwave-comment-hook ()
  "Compute indent for the beginning of the IDL comment delimiter."
  (if (or (looking-at idlwave-no-change-comment)
          (if idlwave-begin-line-comment
              (looking-at idlwave-begin-line-comment)
	    (looking-at "^;")))
      (current-column)
    (if (looking-at idlwave-code-comment)
        (if (save-excursion (skip-chars-backward " \t") (bolp))
            ;; On line by itself, indent as code
            (let ((tem (idlwave-calculate-indent)))
              (if (listp tem) (car tem) tem))
          ;; after code - do not change
          (current-column))
      (skip-chars-backward " \t")
      (max (if (bolp) 0 (1+ (current-column)))
           comment-column))))

(defun idlwave-split-line ()
  "Continue line by breaking line at point and indent the lines.
For a code line insert continuation marker. If the line is a line comment
then the new line will contain a comment with the same indentation.
Splits strings with the IDL operator `+' if `idlwave-split-line-string' is
non-nil."
  (interactive)
  (let (beg)
    (if (not (idlwave-in-comment))
        ;; For code line add continuation.
        ;; Check if splitting a string.
        (progn
          (if (setq beg (idlwave-in-quote))
              (if idlwave-split-line-string
                  ;; Split the string.
                  (progn (insert (setq beg (char-after beg)) " + "
                                 idlwave-continuation-char beg)
                         (backward-char 1))
                ;; Do not split the string.
                (beep)
                (message "Warning: continuation inside string!!")
                (insert " " idlwave-continuation-char))
            ;; Not splitting a string.
            (insert " " idlwave-continuation-char))
          (newline-and-indent))
      (indent-new-comment-line))
    ;; Indent previous line
    (setq beg (- (point-max) (point)))
    (forward-line -1)
    (idlwave-indent-line)
    (goto-char (- (point-max) beg))
    ;; Reindent new line
    (idlwave-indent-line)))

(defun idlwave-beginning-of-subprogram ()
  "Moves point to the beginning of the current program unit."
  (interactive)
  (idlwave-find-key idlwave-begin-unit-reg -1))

(defun idlwave-end-of-subprogram ()
  "Moves point to the start of the next program unit."
  (interactive)
  (idlwave-end-of-statement)
  (idlwave-find-key idlwave-end-unit-reg 1))

(defun idlwave-mark-statement ()
  "Mark current IDL statement."
  (interactive)
  (idlwave-end-of-statement)
  (let ((end (point)))
    (idlwave-beginning-of-statement)
    (idlwave-push-mark end nil t)))

(defun idlwave-mark-block ()
  "Mark containing block."
  (interactive)
  (idlwave-end-of-statement)
  (idlwave-backward-up-block -1)
  (idlwave-end-of-statement)
  (let ((end (point)))
    (idlwave-backward-block)
    (idlwave-beginning-of-statement)
    (idlwave-push-mark end nil t)))


(defun idlwave-mark-subprogram ()
  "Put mark at beginning of program, point at end.
The marks are pushed."
  (interactive)
  (idlwave-end-of-statement)
  (idlwave-beginning-of-subprogram)
  (let ((beg (point)))
    (idlwave-forward-block)
    (idlwave-push-mark beg nil t))
  (exchange-point-and-mark))

(defun idlwave-backward-up-block (&optional arg)
  "Move to beginning of enclosing block if prefix ARG >= 0.
If prefix ARG < 0 then move forward to enclosing block end."
  (interactive "p")
  (idlwave-block-jump-out (- arg) 'nomark))

(defun idlwave-beginning-of-block ()
  "Go to the beginning of the current block."
  (interactive)
  (idlwave-block-jump-out -1 'nomark)
  (forward-word 1))

(defun idlwave-end-of-block ()
  "Go to the beginning of the current block."
  (interactive)
  (idlwave-block-jump-out 1 'nomark)
  (backward-word 1))

(defun idlwave-forward-block ()
  "Move across next nested block."
  (interactive)
  (if (idlwave-down-block 1)
      (idlwave-block-jump-out 1 'nomark)))

(defun idlwave-backward-block ()
  "Move backward across previous nested block."
  (interactive)
  (if (idlwave-down-block -1)
      (idlwave-block-jump-out -1 'nomark)))

(defun idlwave-down-block (&optional arg)
  "Go down a block.
With ARG: ARG >= 0 go forwards, ARG < 0 go backwards.
Returns non-nil if successfull."
  (interactive "p")
  (let (status)
    (if (< arg 0)
        ;; Backward
        (let ((eos (save-excursion
                     (idlwave-block-jump-out -1 'nomark)
                     (point))))
          (if (setq status (idlwave-find-key 
			    idlwave-end-block-reg -1 'nomark eos))
              (idlwave-beginning-of-statement)
            (message "No nested block before beginning of containing block.")))
      ;; Forward
      (let ((eos (save-excursion
                   (idlwave-block-jump-out 1 'nomark)
                   (point))))
        (if (setq status (idlwave-find-key 
			  idlwave-begin-block-reg 1 'nomark eos))
            (idlwave-end-of-statement)
          (message "No nested block before end of containing block."))))
    status))

(defun idlwave-mark-doclib ()
  "Put point at beginning of doc library header, mark at end.
The marks are pushed."
  (interactive)
  (let (beg
        (here (point)))
    (goto-char (point-max))
    (if (re-search-backward idlwave-doclib-start nil t)
        (progn 
	  (setq beg (progn (beginning-of-line) (point)))
	  (if (re-search-forward idlwave-doclib-end nil t)
	      (progn
		(forward-line 1)
		(idlwave-push-mark beg nil t)
		(message "Could not find end of doc library header.")))
	  (message "Could not find doc library header start.")
	  (goto-char here)))))

(defun idlwave-beginning-of-statement ()
  "Move to beginning of the current statement.
Skips back past statement continuations.
Point is placed at the beginning of the line whether or not this is an
actual statement."
  (interactive)
  (if (save-excursion (forward-line -1) (idlwave-is-continuation-line))
      (idlwave-previous-statement)
    (beginning-of-line)))

(defun idlwave-previous-statement ()
  "Moves point to beginning of the previous statement.
Returns t if the current line before moving is the beginning of
the first non-comment statement in the file, and nil otherwise."
  (interactive)
  (let (first-statement)
    (if (not (= (forward-line -1) 0))
        ;; first line in file
        t
      ;; skip blank lines, label lines, include lines and line comments
      (while (and
              ;; The current statement is the first statement until we
              ;; reach another statement.
              (setq first-statement
                    (or
                     (looking-at idlwave-comment-line-start-skip)
                     (looking-at "[ \t]*$")
                     (looking-at (concat "[ \t]*" idlwave-label "[ \t]*$"))
                     (looking-at "^@")))
              (= (forward-line -1) 0)))
      ;; skip continuation lines
      (while (and
              (save-excursion
                (forward-line -1)
                (idlwave-is-continuation-line))
              (= (forward-line -1) 0)))
      first-statement)))

(defun idlwave-end-of-statement ()
  "Moves point to the end of the current IDL statement.
If not in a statement just moves to end of line. Returns position."
  (interactive)
  (while (and (idlwave-is-continuation-line)
              (= (forward-line 1) 0)))
  (end-of-line) (point))

(defun idlwave-next-statement ()
  "Moves point to beginning of the next IDL statement.
 Returns t if that statement is the last
 non-comment IDL statement in the file, and nil otherwise."
  (interactive)
  (let (last-statement)
    (idlwave-end-of-statement)
    ;; skip blank lines, label lines, include lines and line comments
    (while (and (= (forward-line 1) 0)
                ;; The current statement is the last statement until
                ;; we reach a new statement.
                (setq last-statement
                      (or
                       (looking-at idlwave-comment-line-start-skip)
                       (looking-at "[ \t]*$")
                       (looking-at (concat "[ \t]*" idlwave-label "[ \t]*$"))
                       (looking-at "^@")))))
    last-statement))

(defun idlwave-skip-label ()
  "Skip label or case statement element.
Returns position after label.
If there is no label point is not moved and nil is returned."
  ;; Just look for the first non quoted colon and check to see if it
  ;; is inside a sexp.  If is not in a sexp it must be part of a label
  ;; or case statement element.
  (let ((start (point))
        (end (idlwave-find-key ":" 1 'nomark
			       (save-excursion
				 (idlwave-end-of-statement) (point)))))
    (if (and end
             (= (nth 0 (parse-partial-sexp start end)) 0))
        (progn
          (forward-char)
          (point))
      (goto-char start)
      nil)))

(defun idlwave-start-of-substatement (&optional pre)
  "Move to start of next IDL substatement after point.
Uses the type of the current IDL statement to determine if the next
statement is on a new line or is a subpart of the current statement.
Returns point at start of substatement modulo whitespace.
If optional argument is non-nil move to beginning of current
substatement. "
  (let ((orig (point))
        (eos (idlwave-end-of-statement))
        (ifnest 0)
        st nst last)
    (idlwave-beginning-of-statement)
    (idlwave-skip-label)
    (setq last (point))
    ;; Continue looking for substatements until we are past orig
    (while (and (<= (point) orig) (not (eobp)))
      (setq last (point))
      (setq nst (nth 1 (cdr (setq st (car (idlwave-statement-type))))))
      (if (equal (car st) 'if) (setq ifnest (1+ ifnest)))
      (cond ((and nst
                  (idlwave-find-key nst 1 'nomark eos))
             (goto-char (match-end 0)))
            ((and (> ifnest 0) (idlwave-find-key "\\<else\\>" 1 'nomark eos))
             (setq ifnest (1- ifnest))
             (goto-char (match-end 0)))
            (t (setq ifnest 0)
               (idlwave-next-statement))))
    (if pre (goto-char last))
    (point)))

(defun idlwave-statement-type ()
  "Return the type of the current IDL statement.
Uses `idlwave-statement-match' to return a cons of (type . point) with
point the ending position where the type was determined. Type is the
association from `idlwave-statment-match', i.e. the cons cell from the
list not just the type symbol. Returns nil if not an identifiable
statement."
  (save-excursion
    ;; Skip whitespace within a statement which is spaces, tabs, continuations
    (while (looking-at "[ \t]*\\<\\$")
      (forward-line 1))
    (skip-chars-forward " \t")
    (let ((st idlwave-statement-match)
          (case-fold-search t))
      (while (and (not (looking-at (nth 0 (cdr (car st)))))
                  (setq st (cdr st))))
      (if st
          (append st (match-end 0))))))

(defun idlwave-expand-equal (&optional before after)
  "Pad '=' with spaces.
Two cases: Assignment statement, and keyword assignment.
The case is determined using `idlwave-start-of-substatement' and
`idlwave-statement-type'.
The equal sign will be surrounded by BEFORE and AFTER blanks.
If `idlwave-pad-keyword' is non-nil then keyword
assignment is treated just like assignment statements.  Otherwise,
spaces are removed for keyword assignment.
Limits in for loops are treated as keyword assignment.
See `idlwave-surround'. "
  ;; Even though idlwave-surround checks `idlwave-surround-by-blank' this
  ;; check saves the time of finding the statement type.
  (if idlwave-surround-by-blank
      (let ((st (save-excursion
                  (idlwave-start-of-substatement t)
                  (idlwave-statement-type))))
        (if (or
             (and (equal (car (car st)) 'assign)
                  (equal (cdr st) (point)))
             idlwave-pad-keyword)
            ;; An assignment statement
            (idlwave-surround before after)
          (idlwave-surround 0 0)))))

(defun idlwave-indent-and-action ()
  "Call `idlwave-indent-line' and do expand actions."
  (interactive)
  (idlwave-indent-line t)
  )

(defun idlwave-indent-line (&optional expand)
  "Indents current IDL line as code or as a comment.
The actions in `idlwave-indent-action-table' are performed.
If the optional argument EXPAND is non-nil then the actions in
`idlwave-indent-expand-table' are performed."
  (interactive)
  ;; Move point out of left margin.
  (if (save-excursion
        (skip-chars-backward " \t")
        (bolp))
      (skip-chars-forward " \t"))
  (let ((mloc (point-marker)))
    (save-excursion
      (beginning-of-line)
      (if (looking-at idlwave-comment-line-start-skip)
          ;; Indentation for a line comment
          (progn
            (skip-chars-forward " \t")
            (idlwave-indent-left-margin (idlwave-comment-hook)))
        ;;
        ;; Code Line
        ;;
        ;; Before indenting, run action routines.
        ;;
        (if (and expand idlwave-do-actions)
            (mapcar 'idlwave-do-action idlwave-indent-expand-table))
        ;;
        (if idlwave-do-actions
            (mapcar 'idlwave-do-action idlwave-indent-action-table))
        ;;
        ;; No longer expand abbrevs on the line.  The user can do this
        ;; manually using expand-region-abbrevs.
        ;;
        ;; Indent for code line
        ;;
        (beginning-of-line)
        (if (or
             ;; a label line
             (looking-at (concat "^" idlwave-label "[ \t]*$"))
             ;; a batch command
             (looking-at "^[ \t]*@"))
            ;; leave flush left
            nil
          ;; indent the line
          (idlwave-indent-left-margin (idlwave-calculate-indent)))
        ;; Adjust parallel comment
        (end-of-line)
        (if (idlwave-in-comment)
            (indent-for-comment))))
    (goto-char mloc)
    ;; Get rid of marker
    (set-marker mloc nil)
    ))

(defun idlwave-do-action (action)
  "Perform an action repeatedly on a line.
ACTION is a list (REG . FUNC).  REG is a regular expression.  FUNC is
either a function name to be called with `funcall' or a list to be
evaluated with `eval'.  The action performed by FUNC should leave point
after the match for REG - otherwise an infinite loop may be entered."
  (let ((action-key (car action))
        (action-routine (cdr action)))
    (beginning-of-line)
    (while (idlwave-look-at action-key)
      (if (listp action-routine)
          (eval action-routine)
        (funcall action-routine)))))

(defun idlwave-indent-to (col &optional min)
  "Indent from point with spaces until column COL.
Inserts space before markers at point."
  (if (not min) (setq min 0))
  (insert-before-markers
   (make-string (max min (- col (current-column))) ? )))

(defun idlwave-indent-left-margin (col)
  "Indent the current line to column COL.
Indents such that first non-whitespace character is at column COL
Inserts spaces before markers at point."
  (save-excursion
    (beginning-of-line)
    (delete-horizontal-space)
    (idlwave-indent-to col)))

(defun idlwave-indent-subprogram ()
  "Indents program unit which contains point."
  (interactive)
  (save-excursion
    (idlwave-end-of-statement)
    (idlwave-beginning-of-subprogram)
    (let ((beg (point)))
      (idlwave-forward-block)
      (message "Indenting subprogram...")
      (indent-region beg (point) nil))
    (message "Indenting subprogram...done.")))

(defun idlwave-calculate-indent ()
  "Return appropriate indentation for current line as IDL code."
  (save-excursion
    (beginning-of-line)
    (cond
     ;; Check for beginning of unit - main (beginning of buffer), pro, or
     ;; function
     ((idlwave-look-at idlwave-begin-unit-reg)
      0)
     ;; Check for continuation line
     ((save-excursion
        (and (= (forward-line -1) 0)
             (idlwave-is-continuation-line)))
      (idlwave-calculate-cont-indent))
     ;; calculate indent based on previous and current statements
     (t (let ((the-indent
               ;; calculate indent based on previous statement
               (save-excursion
                 (cond
                  ((idlwave-previous-statement)
                   0)
                  ;; Main block
                  ((idlwave-look-at idlwave-begin-unit-reg t)
                   (+ (idlwave-current-statement-indent)
		      idlwave-main-block-indent))
                  ;; Begin block
                  ((idlwave-look-at idlwave-begin-block-reg t)
                   (+ (idlwave-current-statement-indent)
		      idlwave-block-indent))
                  ((idlwave-look-at idlwave-end-block-reg t)
                   (- (idlwave-current-statement-indent)
		      idlwave-end-offset
		      idlwave-block-indent))
                  ((idlwave-current-statement-indent))))))
          ;; adjust the indentation based on the current statement
          (cond
           ;; End block
           ((idlwave-look-at idlwave-end-block-reg t)
            (+ the-indent idlwave-end-offset))
           (the-indent)))))))

;;
;; Parenthesses balacing/indent
;;

(defun idlwave-calculate-cont-indent ()
  "Calculates the IDL continuation indent column from the previous statement.
Note that here previous statement means the beginning of the current
statement if this statement is a continuation of the previous line.
Intervening comments or comments within the previous statement can
screw things up if the comments contain parentheses characters."
  (save-excursion
    (let* (open
           (case-fold-search t)
           (end-reg (progn (beginning-of-line) (point)))
           (close-exp (progn (skip-chars-forward " \t") (looking-at "\\s)")))
           (beg-reg (progn (idlwave-previous-statement) (point))))
      ;;
      ;; If PRO or FUNCTION declaration indent after name, and first comma.
      ;;
      (if (idlwave-look-at "\\<\\(pro\\|function\\)\\>")
          (progn
            (forward-sexp 1)
            (if (looking-at "[ \t]*,[ \t]*")
                (goto-char (match-end 0)))
            (current-column))
        ;;
        ;; Not a PRO or FUNCTION
        ;;
        ;; Look for innermost unmatched open paren
        ;;
        (if (setq open (car (cdr (parse-partial-sexp beg-reg end-reg))))
            ;; Found innermost open paren.
            (progn
              (goto-char open)
	      ;; Line up with next word unless this is a closing paren.
              (cond
               ;; This is a closed paren - line up under open paren.
               (close-exp
                (current-column))
               ;; Empty - just add regular indent. Take into account
               ;; the forward-char
               ((progn
                  ;; Skip paren
                  (forward-char 1)
                  (looking-at "[ \t$]*$"))
                (+ (current-column) idlwave-continuation-indent -1))
               ;; Line up with first word
               ((progn
                  (skip-chars-forward " \t")
                  (current-column)))))
          ;; No unmatched open paren. Just a simple continuation.
          (goto-char beg-reg)
          (+ (idlwave-current-indent)
             ;; Make adjustments based on current line
             (cond
              ;; Else statement
              ((progn
                 (goto-char end-reg)
                 (skip-chars-forward " \t")
                 (looking-at "else"))
               0)
              ;; Ordinary continuation
              (idlwave-continuation-indent))))))))

(defun idlwave-find-key (key-reg &optional dir nomark limit)
  "Move in direction of the optional second argument DIR to the
next keyword not contained in a comment or string and ocurring before
optional fourth argument LIMIT. DIR defaults to forward direction.  If
DIR is negative the search is backwards, otherwise, it is
forward. LIMIT defaults to the beginning or end of the buffer
according to the direction of the search. The keyword is given by the
regular expression argument KEY-REG.  The search is case insensitive.
Returns position if successful and nil otherwise.  If found
`push-mark' is executed unless the optional third argument NOMARK is
non-nil. If found, the point is left at the keyword beginning."
  (or dir (setq dir 0))
  (or limit (setq limit (cond ((>= dir 0) (point-max)) ((point-min)))))
  (let (found
        (old-syntax-table (syntax-table))
        (case-fold-search t))
    (unwind-protect
	(save-excursion
	  (set-syntax-table idlwave-find-symbol-syntax-table)
	  (if (>= dir 0)
	      (while (and (setq found (and
				       (re-search-forward key-reg limit t)
				       (match-beginning 0)))
			  (idlwave-quoted)
			  (not (eobp))))
	    (while (and (setq found (and
				     (re-search-backward key-reg limit t)
				     (match-beginning 0)))
			(idlwave-quoted)
			(not (bobp))))))
      (set-syntax-table old-syntax-table))
    (if found (progn
                (if (not nomark) (push-mark))
                (goto-char found)))))

(defun idlwave-block-jump-out (&optional dir nomark)
  "When optional argument DIR is non-negative, move forward to end of
current block using the `idlwave-begin-block-reg' and `idlwave-end-block-reg'
regular expressions. When DIR is negative, move backwards to block beginning.
Recursively calls itself to skip over nested blocks. DIR defualts to
forward. Calls `push-mark' unless the optional argument NOMARK is
non-nil. Movement is limited by the start of program units because of
possibility of unbalanced blocks."
  (interactive "P")
  (or dir (setq dir 0))
  (let* ((here (point))
         (case-fold-search t)
         (limit (if (>= dir 0) (point-max) (point-min)))
         (block-limit (if (>= dir 0) 
			  idlwave-begin-block-reg
			idlwave-end-block-reg))
         found
         (block-reg (concat idlwave-begin-block-reg "\\|"
			    idlwave-end-block-reg))
         (unit-limit (or (save-excursion
			   (if (< dir 0)
			       (idlwave-find-key
				idlwave-begin-unit-reg dir t limit)
			     (end-of-line)
			     (idlwave-find-key 
			      idlwave-end-unit-reg dir t limit)))
			 limit)))
    (if (>= dir 0) (end-of-line)) ;Make sure we are in current block
    (if (setq found (idlwave-find-key  block-reg dir t unit-limit))
        (while (and found (looking-at block-limit))
          (if (>= dir 0) (forward-word 1))
          (idlwave-block-jump-out dir t)
          (setq found (idlwave-find-key block-reg dir t unit-limit))))
    (if (not nomark) (push-mark here))
    (if (not found) (goto-char unit-limit)
      (if (>= dir 0) (forward-word 1)))))

(defun idlwave-current-statement-indent ()
  "Return indentation of the current statement.
If in a statement, moves to beginning of statement before finding indent."
  (idlwave-beginning-of-statement)
  (idlwave-current-indent))

(defun idlwave-current-indent ()
  "Return the column of the indentation of the current line.
Skips any whitespace. Returns 0 if the end-of-line follows the whitespace."
  (save-excursion
    (beginning-of-line)
    (skip-chars-forward " \t")
    ;; if we are at the end of blank line return 0
    (cond ((eolp) 0)
          ((current-column)))))

(defun idlwave-is-continuation-line ()
  "Tests if current line is continuation line."
  (save-excursion
    (idlwave-look-at "\\<\\$")))

(defun idlwave-look-at (regexp &optional cont beg)
  "Searches current line from current point for the regular expression
REGEXP. If optional argument CONT is non-nil, searches to the end of
the current statement. If optional arg BEG is non-nil, search starts
from the beginning of the current statement. Ignores matches that end
in a comment or inside a string expression. Returns point if
successful, nil otherwise.  This function produces unexpected results
if REGEXP contains quotes or a comment delimiter. The search is case
insensitive.  If successful leaves point after the match, otherwise,
does not move point."
  (let ((here (point))
        (old-syntax-table (syntax-table))
        (case-fold-search t)
        eos
        found)
    (unwind-protect
	(progn
	  (set-syntax-table idlwave-find-symbol-syntax-table)
	  (setq eos
		(if cont
		    (save-excursion (idlwave-end-of-statement) (point))
		  (save-excursion (end-of-line) (point))))
	  (if beg (idlwave-beginning-of-statement))
	  (while (and (setq found (re-search-forward regexp eos t))
		      (idlwave-quoted))))
      (set-syntax-table old-syntax-table))
    (if (not found) (goto-char here))
    found))

(defun idlwave-fill-paragraph (&optional nohang)
  "Fills paragraphs in comments.
A paragraph is made up of all contiguous lines having the same comment
leader (the leading whitespace before the comment delimiter and the
coment delimiter).  In addition, paragraphs are separated by blank
line comments. The indentation is given by the hanging indent of the
first line, otherwise by the minimum indentation of the lines after
the first line. The indentation of the first line does not change.
Does not effect code lines. Does not fill comments on the same line
with code.  The hanging indent is given by the end of the first match
matching `idlwave-hang-indent-regexp' on the paragraph's first line . If the
optional argument NOHANG is non-nil then the hanging indent is
ignored."
  (interactive "P")
  ;; check if this is a line comment
  (if (save-excursion
        (beginning-of-line)
        (skip-chars-forward " \t")
        (looking-at comment-start))
      (let
          ((indent 999)
           pre here diff fill-prefix-reg bcl first-indent
           hang start end)
        ;; Change tabs to spaces in the surrounding paragraph.
        ;; The surrounding paragraph will be the largest containing block of
        ;; contiguous line comments. Thus, we may be changing tabs in
        ;; a much larger area than is needed, but this is the easiest
        ;; brute force way to do it.
        ;;
        ;; This has the undesirable side effect of replacing the tabs
        ;; permanently without the user's request or knowledge.
        (save-excursion
          (backward-paragraph)
          (setq start (point)))
        (save-excursion
          (forward-paragraph)
          (setq end (point)))
        (untabify start end)
        ;;
        (setq here (point))
        (beginning-of-line)
        (setq bcl (point))
        (re-search-forward
         (concat "^[ \t]*" comment-start "+")
         (save-excursion (end-of-line) (point))
         t)
        ;; Get the comment leader on the line and its length
        (setq pre (current-column))
        ;; the comment leader is the indentation plus exactly the
        ;; number of consecutive ";".
        (setq fill-prefix-reg
              (concat
               (setq fill-prefix
                     (regexp-quote
                      (buffer-substring (save-excursion
                                          (beginning-of-line) (point))
                                        (point))))
               "[^;]"))
	
        ;; Mark the beginning and end of the paragraph
        (goto-char bcl)
        (while (and (looking-at fill-prefix-reg)
                    (not (looking-at paragraph-separate))
                    (not (bobp)))
          (forward-line -1))
        ;; Move to first line of paragraph
        (if (/= (point) bcl)
            (forward-line 1))
        (setq start (point))
        (goto-char bcl)
        (while (and (looking-at fill-prefix-reg)
                    (not (looking-at paragraph-separate))
                    (not (eobp)))
          (forward-line 1))
        (beginning-of-line)
        (if (or (not (looking-at fill-prefix-reg))
                (looking-at paragraph-separate))
            (forward-line -1))
        (end-of-line)
        ;; if at end of buffer add a newline (need this because
        ;; fill-region needs END to be at the beginning of line after
        ;; the paragraph or it will add a line).
        (if (eobp)
            (progn (insert ?\n) (backward-char 1)))
        ;; Set END to the beginning of line after the paragraph
        ;; END is calculated as distance from end of buffer
        (setq end (- (point-max) (point) 1))
        ;;
        ;; Calculate the indentation for the paragraph.
        ;;
        ;; In the following while statements, after one iteration
        ;; point will be at the beginning of a line in which case
        ;; the while will not be executed for the
        ;; the first paragraph line and thus will not affect the
        ;; indentation.
        ;;
        ;; First check to see if indentation is based on hanging indent.
        (if (and (not nohang) idlwave-hanging-indent
                 (setq hang
                       (save-excursion
                         (goto-char start)
                         (idlwave-calc-hanging-indent))))
            ;; Adjust lines of paragraph by inserting spaces so that
            ;; each line's indent is at least as great as the hanging
            ;; indent. This is needed for fill-paragraph to work with
            ;; a fill-prefix.
            (progn
              (setq indent hang)
              (beginning-of-line)
              (while (> (point) start)
                (re-search-forward comment-start-skip
                                   (save-excursion (end-of-line) (point))
                                   t)
                (if (> (setq diff (- indent (current-column))) 0)
                    (progn
                      (if (>= here (point))
                          ;; adjust the original location for the
                          ;; inserted text.
                          (setq here (+ here diff)))
                      (insert (make-string diff ? ))))
                (forward-line -1))
              )
	  
          ;; No hang. Instead find minimum indentation of paragraph
          ;; after first line.
          ;; For the following while statement, since START is at the
          ;; beginning of line and END is at the the end of line
          ;; point is greater than START at least once (which would
          ;; be the case for a single line paragraph).
          (while (> (point) start)
            (beginning-of-line)
            (setq indent
                  (min indent
                       (progn
                         (re-search-forward
                          comment-start-skip
                          (save-excursion (end-of-line) (point))
                          t)
                         (current-column))))
            (forward-line -1))
          )
        (setq fill-prefix (concat fill-prefix
                                  (make-string (- indent pre)
                                               ? )))
        ;; first-line indent
        (setq first-indent
              (max
               (progn
                 (re-search-forward
                  comment-start-skip
                  (save-excursion (end-of-line) (point))
                  t)
                 (current-column))
               indent))
	
        ;; try to keep point at its original place
        (goto-char here)
;       ;; fill the paragraph
;       ;; This version of fill-region-as-paragraph is only
;       ;; available in GNU emacs 19.31 or later (and not in
;       ;; Xemacs 19.14)
;       (save-excursion
;         (fill-region-as-paragraph
;          start
;          (- (point-max) end)
;          (current-justification)
;          nil
;          (+ start indent -1)))
        ;; In place of the more modern fill-region-as-paragraph, a hack
        ;; to keep whitespace untouched on the first line within the
        ;; indent length and to preserve any indent on the first line
        ;; (first indent).
        (save-excursion
          (setq diff
                (buffer-substring start (+ start first-indent -1)))
          (subst-char-in-region start (+ start first-indent -1) ?  ?~ nil)
          (fill-region-as-paragraph
           start
           (- (point-max) end)
           (current-justification)
           nil)
          (delete-region start (+ start first-indent -1))
          (goto-char start)
          (insert diff))
        ;; When we want the point at the beginning of the comment
        ;; body fill-region will put it at the beginning of the line.
        (if (bolp) (skip-chars-forward (concat " \t" comment-start)))
        (setq fill-prefix nil))))

(defun idlwave-calc-hanging-indent ()
  "Calculate the position of the hanging indent for the comment
paragraph.  The hanging indent position is given by the first match
with the `idlwave-hang-indent-regexp'.  If `idlwave-use-last-hang-indent' is
non-nil then use last occurrence matching `idlwave-hang-indent-regexp' on
the line.
If not found returns nil."
  (if idlwave-use-last-hang-indent
      (save-excursion
        (end-of-line)
        (if (re-search-backward
             idlwave-hang-indent-regexp
             (save-excursion (beginning-of-line) (point))
             t)
            (+ (current-column) (length idlwave-hang-indent-regexp))))
    (save-excursion
      (beginning-of-line)
      (if (re-search-forward
           idlwave-hang-indent-regexp
           (save-excursion (end-of-line) (point))
           t)
          (current-column)))))

(defun idlwave-auto-fill ()
  "Called to break lines in auto fill mode.
Only fills comment lines if `idlwave-fill-comment-line-only' is non-nil.
Places a continuation character at the end of the line
if not in a comment.  Splits strings with IDL concantenation operator
`+' if `idlwave-auto-fill-split-string is non-nil."
  (if (<= (current-column) fill-column)
      nil                             ; do not to fill
    (if (or (not idlwave-fill-comment-line-only)
	    (save-excursion
	      ;; Check for comment line
	      (beginning-of-line)
	      (looking-at idlwave-comment-line-start-skip)))
	(let (beg)
	  (idlwave-indent-line)
	  ;; Prevent actions do-auto-fill which calls indent-line-function.
	  (let (idlwave-do-actions
		(paragraph-start ".")
		(paragraph-separate "."))
	    (do-auto-fill))
	  (save-excursion
	    (end-of-line 0)
	    ;; Indent the split line
	    (idlwave-indent-line)
	    )
	  (if (save-excursion
		(beginning-of-line)
		(looking-at idlwave-comment-line-start-skip))
	      ;; A continued line comment
	      ;; We treat continued line comments as part of a comment
	      ;; paragraph. So we check for a hanging indent.
	      (if idlwave-hanging-indent
		  (let ((here (- (point-max) (point)))
			(indent
			 (save-excursion
			   (forward-line -1)
			   (idlwave-calc-hanging-indent))))
		    (if indent
			(progn
			  ;; Remove whitespace between comment delimiter and
			  ;; text, insert spaces for appropriate indentation.
			  (beginning-of-line)
			  (re-search-forward
			   comment-start-skip
			   (save-excursion (end-of-line) (point)) t)
			  (delete-horizontal-space)
			  (idlwave-indent-to indent)
			  (goto-char (- (point-max) here)))
		      )))
	    ;; Split code or comment?
	    (if (save-excursion
		  (end-of-line 0)
		  (idlwave-in-comment))
		;; Splitting a non-line comment.
		;; Insert the comment delimiter from split line
		(progn
		  (save-excursion
		    (beginning-of-line)
		    (skip-chars-forward " \t")
		    ;; Insert blank to keep off beginning of line
		    (insert " "
			    (save-excursion
			      (forward-line -1)
			      (buffer-substring (idlwave-goto-comment)
						(progn
						  (skip-chars-forward "; ")
						  (point))))))
		  (idlwave-indent-line))
	      ;; Split code line - add continuation character
	      (save-excursion
		(end-of-line 0)
		;; Check to see if we split a string
		(if (and (setq beg (idlwave-in-quote))
			 idlwave-auto-fill-split-string)
		    ;; Split the string and concatenate.
		    ;; The first extra space is for the space
		    ;; the line was split. That space was removed.
		    (insert " " (char-after beg) " +"))
		(insert " $"))
	      (if beg
		  (if idlwave-auto-fill-split-string
		      ;; Make the second part of continued string
		      (save-excursion
			(beginning-of-line)
			(skip-chars-forward " \t")
			(insert (char-after beg)))
		    ;; Warning
		    (beep)
		    (message "Warning: continuation inside a string.")))
	      ;; Although do-auto-fill (via indent-new-comment-line) calls
	      ;; idlwave-indent-line for the new line, re-indent again
	      ;; because of the addition of the continuation character.
	      (idlwave-indent-line))
	    )))))

(defun idlwave-auto-fill-mode (arg)
  "Toggle auto-fill mode for IDL mode.
With arg, turn auto-fill mode on iff arg is positive.
In auto-fill mode, inserting a space at a column beyond `fill-column'
automatically breaks the line at a previous space."
  (interactive "P")
  (prog1 (set idlwave-fill-function
              (if (if (null arg)
                      (not (symbol-value idlwave-fill-function))
                    (> (prefix-numeric-value arg) 0))
                  'idlwave-auto-fill
                nil))
    ;; update mode-line
    (set-buffer-modified-p (buffer-modified-p))))

(defun idlwave-doc-header (&optional nomark )
  "Insert a documentation header at the beginning of the unit.
Inserts the value of the variable idlwave-file-header. Sets mark before
moving to do insertion unless the optional prefix argument NOMARK
is non-nill."
  (interactive "P")
  (or nomark (push-mark))
  ;; make sure we catch the current line if it begins the unit
  (end-of-line)
  (idlwave-beginning-of-subprogram)
  (beginning-of-line)
  ;; skip function or procedure line
  (if (idlwave-look-at "\\<\\(pro\\|function\\)\\>")
      (progn
        (idlwave-end-of-statement)
        (if (> (forward-line 1) 0) (insert "\n"))))
  (if idlwave-file-header
      (cond ((car idlwave-file-header)
             (insert-file (car idlwave-file-header)))
            ((stringp (car (cdr idlwave-file-header)))
             (insert (car (cdr idlwave-file-header)))))))


(defun idlwave-default-insert-timestamp ()
  "Default timestamp insertion function"
  (insert (current-time-string))
  (insert ", " (user-full-name))
  (insert " <" (user-login-name) "@" (system-name) ">")
  ;; Remove extra spaces from line
  (idlwave-fill-paragraph)
  ;; Insert a blank line comment to separate from the date entry -
  ;; will keep the entry from flowing onto date line if re-filled.
  (insert "\n;\n;\t\t"))

(defun idlwave-doc-modification ()
  "Insert a brief modification log at the beginning of the current program.
Looks for an occurrence of the value of user variable
`idlwave-doc-modifications-keyword' if non-nil. Inserts time and user name
and places the point for the user to add a log. Before moving, saves
location on mark ring so that the user can return to previous point."
  (interactive)
  (push-mark)
  ;; make sure we catch the current line if it begins the unit
  (end-of-line)
  (idlwave-beginning-of-subprogram)
  (let ((pro (idlwave-look-at "\\<\\(function\\|pro\\)\\>"))
        (case-fold-search nil))
    (if (re-search-forward
         (concat idlwave-doc-modifications-keyword ":")
         ;; set search limit at next unit beginning
         (save-excursion (idlwave-end-of-subprogram) (point))
         t)
        (end-of-line)
      ;; keyword not present, insert keyword
      (if pro (idlwave-next-statement))  ; skip past pro or function statement
      (beginning-of-line)
      (insert "\n" comment-start "\n")
      (forward-line -2)
      (insert comment-start " " idlwave-doc-modifications-keyword ":")))
  (idlwave-newline)
  (beginning-of-line)
  (insert ";\n;\t")
  (run-hooks 'idlwave-timestamp-hook))

;;; CJC 3/16/93
;;; Interface to expand-region-abbrevs which did not work when the
;;; abbrev hook associated with an abbrev moves point backwards
;;; after abbrev expansion, e.g., as with the abbrev '.n'.
;;; The original would enter an infinite loop in attempting to expand
;;; .n (it would continually expand and unexpand the abbrev without expanding
;;; because the point would keep going back to the beginning of the
;;; abbrev instead of to the end of the abbrev). We now keep the
;;; abbrev hook from moving backwards.
;;;
(defun idlwave-expand-region-abbrevs (start end)
  "Expand each abbrev occurrence in the region.
Calling from a program, arguments are START END."
  (interactive "r")
  (save-excursion
    (goto-char (min start end))
    (let ((idlwave-show-block nil)          ;Do not blink
          (idlwave-abbrev-move nil))        ;Do not move
      (expand-region-abbrevs start end 'noquery))))

(defun idlwave-quoted ()
  "Returns t if point is in a comment or quoted string.
nil otherwise."
  (or (idlwave-in-comment) (idlwave-in-quote)))

(defun idlwave-in-quote ()
  "Returns location of the opening quote
if point is in a IDL string constant, nil otherwise.
Ignores comment delimiters on the current line.
Properly handles nested quotation marks and octal
constants - a double quote followed by an octal digit."
;;; Treat an octal inside an apostrophe to be a normal string. Treat a
;;; double quote followed by an octal digit to be an octal constant
;;; rather than a string. Therefore, there is no terminating double
;;; quote.
  (save-excursion
    ;; Because single and double quotes can quote each other we must
    ;; search for the string start from the beginning of line.
    (let* ((start (point))
           (eol (progn (end-of-line) (point)))
           (bq (progn (beginning-of-line) (point)))
           (endq (point))
           (data (match-data))
           delim
           found)
      (while  (< endq start)
	;; Find string start
	;; Don't find an octal constant beginning with a double quote
	(if (re-search-forward "\"[^0-7]\\|'\\|\"$" eol 'lim)
	    ;; Find the string end.
	    ;; In IDL, two consecutive delimiters after the start of a
	    ;; string act as an
	    ;; escape for the delimiter in the string.
	    ;; Two consecutive delimiters alone (i.e., not after the
	    ;; start of a string) is the the null string.
	    (progn
	      ;; Move to position after quote
	      (goto-char (1+ (match-beginning 0)))
	      (setq bq (1- (point)))
	      ;; Get the string delimiter
	      (setq delim (char-to-string (preceding-char)))
	      ;; Check for null string
	      (if (looking-at delim)
		  (progn (setq endq (point)) (forward-char 1))
		;; Look for next unpaired delimiter
		(setq found (search-forward delim eol 'lim))
		(while (looking-at delim)
		  (forward-char 1)
		  (setq found (search-forward delim eol 'lim)))
		(if found
		    (setq endq (- (point) 1))
		  (setq endq (point)))
		))
	  (progn (setq bq (point)) (setq endq (point)))))
      (store-match-data data)
      ;; return string beginning position or nil
      (if (> start bq) bq))))

;; Statement templates

;; Replace these with a general template function, something like
;; expand.el (I think there was also something with a name similar to
;; dmacro.el)

(defun idlwave-template (s1 s2 &optional prompt noindent)
  "Build a template with optional prompt expression.

Opens a line if point is not followed by a newline modulo intervening
whitespace.  S1 and S2 are strings.  S1 is inserted at point followed
by S2.  Point is inserted between S1 and S2.  If optional argument
PROMPT is a string then it is displayed as a message in the
minibuffer.  The PROMPT serves as a reminder to the user of an
expression to enter.

The lines containing S1 and S2 are reindented using `indent-region'
unless the optional second argument NOINDENT is non-nil."
  (let ((beg (save-excursion (beginning-of-line) (point)))
        end)
    (if (not (looking-at "\\s-*\n"))
        (open-line 1))
    (insert s1)
    (save-excursion
      (insert s2)
      (setq end (point)))
    (if (not noindent)
        (indent-region beg end nil))
    (if (stringp prompt)
        (message prompt))))

(defun idlwave-elif ()
  "Build skeleton IDL if-else block."
  (interactive)
  (idlwave-template "if" 
		    " then begin\n\nendif else begin\n\nendelse"
		    "Condition expression"))

(defun idlwave-case ()
  "Build skeleton IDL case statement."
  (interactive)
  (idlwave-template "case" " of\n\nendcase" "Selector expression"))

(defun idlwave-for ()
  "Build skeleton for loop statment."
  (interactive)
  (idlwave-template "for" " do begin\n\nendfor" "Loop expression"))

(defun idlwave-if ()
  "Build skeleton for loop statment."
  (interactive)
  (idlwave-template "if" " then begin\n\nendif" "Scalar logical expression"))

(defun idlwave-procedure ()
  (interactive)
  (idlwave-template "pro" "\n\nreturn\nend" "Procedure name"))

(defun idlwave-function ()
  (interactive)
  (idlwave-template "function" "\n\nreturn\nend" "Function name"))

(defun idlwave-repeat ()
  (interactive)
  (idlwave-template "repeat begin\n\nendrep until" "" "Exit condition"))

(defun idlwave-while ()
  (interactive)
  (idlwave-template "while" " do begin\n\nendwhile" "Entry condition"))

; FIXME: This can probably go
;(defun idlwave-split-string (string)
;  (let* ((start 0)
;	 (last (length string))
;	 lst end)
;    (while (setq end (string-match "[ \t]+" string start))
;      (setq lst (append lst (list (substring string start end))))
;      (setq start (match-end 0)))
;    (setq lst (append lst (list (substring string start last))))))

(defun idlwave-split-string (string &optional pattern)
  "Return a list of substrings of STRING which are separated by PATTERN.
If PATTERN is omitted, it defaults to \"[ \\f\\t\\n\\r\\v]+\"."
  (or pattern
      (setq pattern "[ \f\t\n\r\v]+"))
  (let (parts (start 0))
    (while (string-match pattern string start)
      (setq parts (cons (substring string start (match-beginning 0)) parts)
	    start (match-end 0)))
    (nreverse (cons (substring string start) parts))))

(defun idlwave-replace-string (string replace_string replace_with)
  (let* ((start 0)
	 (last (length string))
	 (ret_string "")
	 end)
    (while (setq end (string-match replace_string string start))
      (setq ret_string
	    (concat ret_string (substring string start end) replace_with))
      (setq start (match-end 0)))
    (setq ret_string (concat ret_string (substring string start last)))))

(defun idlwave-get-buffer-visiting (file)
  ;; Return the buffer currently visiting FILE
  (cond
   ((boundp 'find-file-compare-truenames) ; XEmacs
    (let ((find-file-compare-truenames t))
      (get-file-buffer file)))
   ((fboundp 'find-buffer-visiting)       ; Emacs
    (find-buffer-visiting file))
   (t (error "This should not happen (idlwave-get-buffer-visiting)"))))

(defun idlwave-find-file-noselect (file)
  ;; Return a buffer visiting file.
  (or (idlwave-get-buffer-visiting file)
      (find-file-noselect file)))

(defun idlwave-make-tags ()
  "Creates the IDL tags file IDLTAGS in the current directory from
the list of directories specified in the minibuffer. Directories may be
for example: . /usr/local/rsi/idl/lib. All the subdirectories of the
specified top directories are searched if the directory name is prefixed
by @. Specify @ directories with care, it may take a long, long time if
you specify /."
  (interactive)
  (let (directory directories cmd append status numdirs dir getsubdirs
		  buffer save_buffer files numfiles item errbuf)
    
    ;;
    ;; Read list of directories
    (setq directory (read-string "Tag Directories: " "."))
    (setq directories (idlwave-split-string directory "[ \t]+"))
    ;;
    ;; Set etags command, vars
    (setq cmd "etags --output=IDLTAGS --language=none --regex='/[
\\t]*[pP][Rr][Oo][ \\t]+\\([^ \\t,]+\\)/' --regex='/[
\\t]*[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn][ \\t]+\\([^ \\t,]+\\)/' ")
    (setq append " ")
    (setq status 0)
    ;;
    ;; For each directory
    (setq numdirs 0)
    (setq dir (nth numdirs directories))
    (while (and dir)
      ;;
      ;; Find the subdirectories
      (if (string-match "^[@]\\(.+\\)$" dir)
	  (setq getsubdirs t) (setq getsubdirs nil))
      (if (and getsubdirs) (setq dir (substring dir 1 (length dir))))
      (setq dir (expand-file-name dir))
      (if (file-directory-p dir)
	  (progn
	    (if (and getsubdirs)
		(progn
		  (setq buffer (get-buffer-create "*idltags*"))
		  (call-process "sh" nil buffer nil "-c"
				(concat "find " dir " -type d -print"))
		  (setq save_buffer (current-buffer))
		  (set-buffer buffer)
		  (setq files (idlwave-split-string
			       (idlwave-replace-string
				(buffer-substring 1 (point-max))
				"\n" "/*.pro ")
			       "[ \t]+"))
		  (set-buffer save_buffer)
		  (kill-buffer buffer))
	      (setq files (list (concat dir "/*.pro"))))
	    ;;
	    ;; For each subdirectory
	    (setq numfiles 0)
	    (setq item (nth numfiles files))
	    (while (and item)
	      ;;
	      ;; Call etags
	      (if (not (string-match "^[ \\t]*$" item))
		  (progn
		    (message (concat "Tagging " item "..."))
		    (setq errbuf (get-buffer-create "*idltags-error*"))
		    (setq status (+ status
				    (call-process "sh" nil errbuf nil "-c"
						  (concat cmd append item))))
		    ;;
		    ;; Append additional tags
		    (setq append " --append ")
		    (setq numfiles (1+ numfiles))
		    (setq item (nth numfiles files)))
		(progn
		  (setq numfiles (1+ numfiles))
		  (setq item (nth numfiles files))
		  )))
	    
	    (setq numdirs (1+ numdirs))
	    (setq dir (nth numdirs directories)))
	(progn
	  (setq numdirs (1+ numdirs))
	  (setq dir (nth numdirs directories)))))
    
    (setq errbuf (get-buffer-create "*idltags-error*"))
    (if (= status 0)
	(kill-buffer errbuf))
    (message "")
    ))


(defun idlwave-toggle-comment-region (beg end &optional n)
  "Comment the lines in the region if the first non-blank line is
commented, and conversely, uncomment region. If optional prefix arg
N is non-nil, then for N positive, add N comment delimiters or for N
negative, remove N comment delimiters.
Uses `comment-region' which does not place comment delimiters on
blank lines."
  (interactive "r\nP")
  (if n
      (comment-region beg end (prefix-numeric-value n))
    (save-excursion
      (goto-char beg)
      (beginning-of-line)
      ;; skip blank lines
      (skip-chars-forward " \t\n")
      (if (looking-at (concat "[ \t]*\\(" comment-start "+\\)"))
          (comment-region beg end
                          (- (length (buffer-substring
                                      (match-beginning 1)
                                      (match-end 1)))))
        (comment-region beg end)))))

;; Additions for use with imenu.el and func-menu.el (pop-up a list of IDL units in
;; the current file).

(defun idlwave-prev-index-position ()
  "Search for the previous procedure or function.
Return nil if not found.  For use with imenu.el."
  (save-match-data
    (cond
     ((idlwave-find-key "\\<\\(pro\\|function\\)\\>" -1 'nomark))
     ;;   ((idlwave-find-key idlwave-begin-unit-reg 1 'nomark)
     (t nil))))

(defun idlwave-unit-name ()
  "Return the unit name.
Assumes that point is at the beginning of the unit as found by
`idlwave-prev-index-position'."
  (forward-sexp 2)
  (forward-sexp -1)
  (let ((begin (point)))
    (re-search-forward "[a-zA-Z][a-zA-Z0-9$_]+\\(::[a-zA-Z][a-zA-Z0-9$_]+\\)?")
    (if (fboundp 'buffer-substring-no-properties)
        (buffer-substring-no-properties begin (point))
      (buffer-substring begin (point)))))

(defun idlwave-function-menu ()
  "Use `imenu' or `function-menu' to jump to a procedure or function."
  (interactive)
  (if (string-match "XEmacs" emacs-version)
      (progn
	(require 'func-menu)
	(function-menu))
    (require 'imenu)
    (imenu (imenu-choose-buffer-index))))

;; Here we kack func-menu.el in order to support this new mode.
;; The latest versions of func-menu.el already have this stuff in, so
;; we hack only if it is not already there.
(eval-after-load "func-menu"
  '(progn
     (or (assq 'idlwave-mode fume-function-name-regexp-alist)
	 (setq fume-function-name-regexp-alist
	       (cons '(idlwave-mode . fume-function-name-regexp-idl)
		     fume-function-name-regexp-alist)))
     (or (assq 'idlwave-mode fume-find-function-name-method-alist)
	 (setq fume-find-function-name-method-alist
	       (cons '(idlwave-mode . fume-find-next-idl-function-name)
		     fume-find-function-name-method-alist)))))

(defun idlwave-edit-in-idlde ()
  "Edit the current file in IDL Development environment."
  (interactive)
  (start-process "idldeclient" nil
		 idlwave-shell-explicit-file-name "-c" "-e"
                 (buffer-file-name) "&"))
                
(defun idlwave-launch-idlhelp ()
  "Start the IDLhelp application."
  (interactive)
  (start-process "idlhelp" nil idlwave-help-application))
 
;; Menus - using easymenu.el
(defvar idlwave-mode-menu-def
  `("IDLWAVE"
    ["PRO/FUNC menu" idlwave-function-menu t]
    ("Motion"
     ["Subprogram Start" idlwave-beginning-of-subprogram t]
     ["Subprogram End" idlwave-end-of-subprogram t]
     ["Block Start" idlwave-beginning-of-block t]
     ["Block End" idlwave-end-of-block t]
     ["Up Block" idlwave-backward-up-block t]
     ["Down Block" idlwave-down-block t]
     ["Skip Block Backward" idlwave-backward-block t]
     ["Skip Block Forward" idlwave-forward-block t])
    ("Mark"
     ["Subprogram" idlwave-mark-subprogram t]
     ["Block" idlwave-mark-block t]
     ["Header" idlwave-mark-doclib t])
    ("Format"
     ["Indent Subprogram" idlwave-indent-subprogram t]
     ["(Un)Comment Region" idlwave-toggle-comment-region "C-c ;"]
     ["Continue/Split line" idlwave-split-line t]
     "--"
     ["Toggle Auto Fill" idlwave-auto-fill-mode :style toggle
      :selected idlwave-fill-function])
    ("Templates"
     ["Procedure" idlwave-procedure t]
     ["Function" idlwave-function t]
     ["Doc Header" idlwave-doc-header t]
     ["Log" idlwave-doc-modification t]
     "--"
     ["Case" idlwave-case t]
     ["For" idlwave-for t]
     ["Repeat" idlwave-repeat t]
     ["While" idlwave-while t]
     "--"
     ["Close Block" idlwave-close-block t])
    ("Routine Info"
     ["Show routine info" idlwave-routine-info t]
     ["Complete" idlwave-complete t]
     ["Find module source" idlwave-find-module t]
     "--"
     ["Update from buffers and shell" idlwave-update-routine-info t]
;     ["Complete function name" idlwave-complete-function
;      (featurep 'idlwave-rinfo)]
;     ["Complete procedure name" idlwave-complete-procedure
;      (featurep 'idlwave-rinfo)]
;     ["Complete function keyword" idlwave-complete-function-keyword
;      (featurep 'idlwave-rinfo)]
;     ["Complete procedure keyword" idlwave-complete-procedure-keyword
;      (featurep 'idlwave-rinfo)]
     )
    ("External"
     ["Generate IDL tags" idlwave-make-tags t]
     ["Start IDL shell" idlwave-shell t]
     ["Edit file in IDLDE" idlwave-edit-in-idlde t]
     ["Launch IDL Help" idlwave-launch-idlhelp t])
    "--"
    ("Customize"
     ["Browse IDLWAVE Group" idlwave-customize t]
     "--"
     ["Build Full Customize Menu" idlwave-create-customize-menu 
      (fboundp 'customize-menu-create)])
    ("Documentation"
     ["Describe Mode" describe-mode t]
     ["Abbreviation List" idlwave-list-abbrevs t]
     ["Info" idlwave-info nil]
     ["Commentary in idlwave.el" idlwave-show-commentary t]
     ["Commentary in idlwave-shell.el" idlwave-shell-show-commentary t]
     "--"
     ["Launch IDL Help" idlwave-launch-idlhelp t])))

(defvar idlwave-mode-debug-menu-def
  '("Debug"
    ["Start IDL shell" idlwave-shell t]))

(if (or (featurep 'easymenu) (load "easymenu" t))
    (progn
      (easy-menu-define idlwave-mode-menu idlwave-mode-map 
			"IDL and WAVE CL editing menu" 
			idlwave-mode-menu-def)
      (easy-menu-define idlwave-mode-debug-menu idlwave-mode-map 
			"IDL and WAVE CL editing menu" 
			idlwave-mode-debug-menu-def)))

(defun idlwave-customize ()
  "Call the customize function with idlwave as argument."
  (interactive)
  ;; Try to load the code for the shell, so that we can customize it 
  ;; as well.
  (or (featurep 'idlwave-shell)
      (load "idlwave-shell" t))
  (customize-browse 'idlwave))

(defun idlwave-create-customize-menu ()
  "Create a full customization menu for IDLWAVE, insert it into the menu."
  (interactive)
  (if (fboundp 'customize-menu-create)
      (progn
	;; Try to load the code for the shell, so that we can customize it 
	;; as well.
	(or (featurep 'idlwave-shell)
	    (load "idlwave-shell" t))
	(easy-menu-change 
	 '("IDLWAVE") "Customize"
	 `(["Browse IDLWAVE group" idlwave-customize t]
	   "--"
	   ,(customize-menu-create 'idlwave)
	   ["Set" Custom-set t]
	   ["Save" Custom-save t]
	   ["Reset to Current" Custom-reset-current t]
	   ["Reset to Saved" Custom-reset-saved t]
	   ["Reset to Standard Settings" Custom-reset-standard t]))
	(message "\"IDLWAVE\"-menu now contains full customization menu"))
    (error "Cannot expand menu (outdated version of cus-edit.el)")))

(defun idlwave-show-commentary ()
  "Use the finder to view the file documentation from `idlwave.el'."
  (interactive)
  (require 'finder)
  (finder-commentary "idlwave.el"))

(defun idlwave-shell-show-commentary ()
  "Use the finder to view the file documentation from `idlwave-shell.el'."
  (interactive)
  (require 'finder)
  (finder-commentary "idlwave-shell.el"))

(defun idlwave-info ()
  "Read documentation for IDLWAVE in the info system."
  (interactive)
  (require 'info)
  (Info-goto-node "(idlwave)"))

(defun idlwave-list-abbrevs (arg)
  "Show the code abbreviations define in IDLWAVE mode.
This lists all abbrevs where the replacement text differs from the input text.
These are the ones the users want to learn to speed up their writing.

The function does *not* list abbrevs which replace a word with itself
to call a hook.  These hooks are used to change the case of words or
to blink the matching `begin', and the user does not need to know them.

With arg, list all abrevs with the corresponding hook.

This function was written since `list-abbrevs' looks terrible for IDLWAVE mode."

  (interactive "P")
  (let ((table (symbol-value 'idlwave-mode-abbrev-table))
	abbrevs
	str rpl func fmt (len-str 0) (len-rpl 0))
    (mapatoms 
     (lambda (sym)
       (if (symbol-value sym)
	   (progn
	     (setq str (symbol-name sym)
		   rpl (symbol-value sym)
		   func (symbol-function sym))
	     (if arg
		 (setq func (prin1-to-string func))
	       (if (and (listp func) (stringp (nth 2 func)))
		   (setq rpl (concat "EVAL: " (nth 2 func))
			 func "")
		 (setq func "")))
	     (if (or arg (not (string= rpl str)))
		 (progn
		   (setq len-str (max len-str (length str)))
		   (setq len-rpl (max len-rpl (length rpl)))
		   (setq abbrevs (cons (list str rpl func) abbrevs)))))))
     table)
    ;; sort the list
    (setq abbrevs (sort abbrevs (lambda (a b) (string< (car a) (car b)))))
    ;; Make the format
    (setq fmt (format "%%-%ds   %%-%ds   %%s\n" len-str len-rpl))
    (with-output-to-temp-buffer "*Help*"
      (if arg
	  (progn
	    (princ "Abbreviations and Actions in IDLWAVE-Mode\n") 
	    (princ "=========================================\n\n")
	    (princ (format fmt "KEY" "REPLACE" "HOOK"))
	    (princ (format fmt "---" "-------" "----")))
	(princ "Code Abbreviations and Templates in IDLWAVE-Mode\n")
	(princ "================================================\n\n")
	(princ (format fmt "KEY" "ACTION" ""))
	(princ (format fmt "---" "------" "")))
      (mapcar
       (lambda (list)
	 (setq str (car list)
	       rpl (nth 1 list)
	       func (nth 2 list))
	 (princ (format fmt str rpl func)))
       abbrevs)))
  ;; Make sure each abbreviation uses only one display line
  (save-excursion
    (set-buffer "*Help*")
    (setq truncate-lines t)))

(run-hooks 'idlwave-load-hook)

(provide 'idlwave)

;;; idlwave.el ends here

