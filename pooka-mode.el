;;; pooka-mode.el --- Major mode for Pooka source files -*- lexical-binding: t; -*-

;; Author: Pooka contributors
;; Version: 0.1.0
;; URL: https://github.com/pooka-lang/pooka-emacs
;; SPDX-License-Identifier: Apache-2.0
;; Keywords: languages, pooka
;; Package-Requires: ((emacs "29.1"))

;;; Commentary:

;; Syntax highlighting for `.pooka` and `.spec.pooka` files.
;;
;; Emacs 29+ uses the Tree-sitter query in `pooka-font-lock.el`
;; when it is installed. Older Emacs, or an Emacs without the grammar, uses the
;; regex font-lock rules instead. No language server is started.
;;
;; Install the grammar with `M-x pooka-install-grammar' (requires the
;; Tree-sitter command line tool and a C compiler).

;;; Code:

;; Fallback faces for the newer font-lock faces on older Emacs versions.
(dolist (spec '((font-lock-operator-face font-lock-builtin-face "Operator face.")
                (font-lock-bracket-face font-lock-builtin-face "Bracket face.")
                (font-lock-delimiter-face font-lock-builtin-face "Delimiter face.")
                (font-lock-escape-face font-lock-builtin-face "Escape face.")
                (font-lock-number-face font-lock-constant-face "Number face.")
                (font-lock-property-face font-lock-variable-name-face "Property face.")))
  (let ((face (nth 0 spec))
        (inherit (nth 1 spec))
        (doc (nth 2 spec)))
    (unless (facep face)
      (eval `(defface ,face '((t :inherit ,inherit)) ,doc :group 'font-lock-faces)))))

(require 'treesit nil t)
(require 'pooka-font-lock)

(defconst pooka-grammar-repository
  "https://github.com/pooka-lang/tree-sitter-pooka"
  "Repository used to install the Pooka Tree-sitter grammar.")

(defconst pooka-grammar-revision
  "d7412722bdb1f60d34ebdd30426bdd613bbb41ba"
  "Pinned revision of the Pooka Tree-sitter grammar.")

(defun pooka--git (directory &rest arguments)
  "Run Git in DIRECTORY, reporting a failed command with its output."
  (let ((default-directory directory))
    (with-temp-buffer
      (unless (zerop (apply #'call-process "git" nil t nil arguments))
        (error "Pooka grammar Git command failed: %s" (buffer-string))))))

(defun pooka-install-grammar ()
  "Install the pinned Pooka grammar without relying on another checkout."
  (interactive)
  (unless (and (fboundp 'treesit-available-p) (treesit-available-p))
    (error "This Emacs build has no Tree-sitter support"))
  (let* ((cache (expand-file-name "pooka-mode/grammar/" user-emacs-directory))
         (parent (file-name-directory (directory-file-name cache))))
    (make-directory parent t)
    (unless (file-directory-p (expand-file-name ".git" cache))
      (pooka--git parent "clone" "--no-checkout" pooka-grammar-repository cache))
    (pooka--git cache "fetch" "--depth" "1" "origin" pooka-grammar-revision)
    (pooka--git cache "checkout" "--detach" pooka-grammar-revision)
    ;; ABI 14 keeps the grammar usable by Emacs builds linked to older
    ;; Tree-sitter runtimes. Generate only inside this mode's own cache.
    (let ((default-directory cache))
      (unless (zerop (call-process "tree-sitter" nil "*Pooka grammar build*" nil
                                  "generate" "--abi" "14"))
        (error "Could not generate the Pooka parser; check *Pooka grammar build*")))
    ;; Emacs treats its recipe revision as a branch or tag. Check out the
    ;; commit ourselves, then let its installer compile that exact local tree.
    (let ((treesit-language-source-alist `((pooka ,cache))))
      (treesit-install-language-grammar 'pooka))
    (unless (treesit-language-available-p 'pooka)
      (error "Pooka grammar was not installed; inspect the compiler messages"))))

(defvar pooka-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?/ ". 124b" table)
    (modify-syntax-entry ?\n "> b" table)
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "\\" table)
    (modify-syntax-entry ?_ "w" table)
    table)
  "Syntax table used in `pooka-mode'.")

(defvar pooka-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-i") #'pooka-install-grammar)
    map)
  "Keymap for `pooka-mode'.")

(defun pooka--treesit-setup ()
  "Enable Tree-sitter highlighting when the Pooka grammar is available."
  (when (and (fboundp 'treesit-ready-p)
             (treesit-ready-p 'pooka t)
             pooka--treesit-font-lock-settings)
    (treesit-parser-create 'pooka)
    (setq-local treesit-font-lock-settings pooka--treesit-font-lock-settings)
    (setq-local treesit-font-lock-feature-list
                '((font-lock)))
    (treesit-major-mode-setup)))

;;;###autoload
(define-derived-mode pooka-mode prog-mode "Pooka"
  "Major mode for Pooka source and spec files.

The mode uses Tree-sitter when the `pooka' grammar is installed and
falls back to regex font-lock otherwise."
  :syntax-table pooka-mode-syntax-table
  (setq-local comment-start "// ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "//+\\s-*")
  (setq-local font-lock-defaults '(pooka-font-lock-keywords nil nil nil nil))
  (pooka--treesit-setup))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.pooka\\'" . pooka-mode))

(provide 'pooka-mode)
;;; pooka-mode.el ends here
