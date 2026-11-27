;;; pooka-font-lock.el --- Pooka highlighting rules -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: Apache-2.0

(defconst pooka--keyword-regexp (regexp-opt '("actor" "assert" "as" "be" "break" "class" "continue" "echo" "enum" "external" "fn" "from" "if" "import" "in" "interface" "is" "let" "loop" "match" "module" "native" "new" "panic" "skip" "test" "todo" "var" "with") 'symbols))
(defconst pooka--constant-regexp (regexp-opt '("False" "Nil" "True" "self" "super") 'symbols))
(defconst pooka--operator-regexp (regexp-opt '("!" "!=" "%" "&" "&&" "*" "*=" "+" "+=" "-" "-=" "/" "<" "<=" "=" "==" ">" ">=" "?" "|" "|>" "||" ".." "->")))
(defconst pooka--bracket-regexp (regexp-opt '("(" ")" "#(" "[" "]" "{" "}" "<<" ">>")))
(defconst pooka--delimiter-regexp (regexp-opt '("," ":" ".")))
(defconst pooka--number-regexp "\\(?:0[xX][0-9a-fA-F_]+\\|0[bB][01_]+\\|0[oO][0-7_]+\\|[0-9][0-9_]*\\(?:\\.[0-9][0-9_]*\\)?\\(?:[eE][+-]?[0-9][0-9_]*\\)?\\)")
(defconst pooka--type-regexp "\\_<_*[A-Z][a-zA-Z0-9_]*\\_>")

(defun pooka--match-function (limit)
  "Find a lowercase function name before LIMIT, leaving arguments untouched."
  (when (re-search-forward "\\_<_*[a-z][a-zA-Z0-9_]*\\_>[[:space:]]*(" limit t)
    (let ((start (match-beginning 0)))
      (goto-char start)
      (skip-chars-forward "a-zA-Z0-9_")
      (set-match-data (list start (point)))
      t)))

(defvar pooka-font-lock-keywords
  `((,pooka--constant-regexp 0 'font-lock-constant-face)
    (,pooka--keyword-regexp 0 'font-lock-keyword-face)
    (,pooka--number-regexp 0 'font-lock-number-face)
    (pooka--match-function (0 'font-lock-function-name-face))
    (,pooka--type-regexp 0 'font-lock-type-face)
    (,pooka--operator-regexp 0 'font-lock-operator-face)
    (,pooka--bracket-regexp 0 'font-lock-bracket-face)
    (,pooka--delimiter-regexp 0 'font-lock-delimiter-face))
  "Highlighting used when the Tree-sitter grammar is unavailable.")

(defconst pooka--treesit-query "(comment) @font-lock-comment-face
(doc_comment) @font-lock-doc-face
(module_comment) @font-lock-doc-face
(string) @font-lock-string-face
(escape_sequence) @font-lock-escape-face
(number) @font-lock-number-face
(boolean) @font-lock-constant-face
(nil) @font-lock-constant-face
(continue_expression) @font-lock-keyword-face
(type_identifier) @font-lock-type-face
(self) @font-lock-constant-face
(super) @font-lock-constant-face
(parameter (identifier) @font-lock-variable-name-face)
(function_declaration name: (identifier) @font-lock-function-name-face)
(signature name: (identifier) @font-lock-function-name-face)
(external_signature name: (identifier) @font-lock-function-name-face)
(external_declaration name: (type_identifier) @font-lock-type-face)
(native_declaration name: (type_identifier) @font-lock-type-face)
(behavior name: (identifier) @font-lock-function-name-face)
(field_declaration name: (identifier) @font-lock-property-face)
(member_expression member: (identifier) @font-lock-property-face)
(call_expression function: (identifier) @font-lock-function-name-face)
(call_expression function: (member_expression member: (identifier) @font-lock-function-name-face))
(module_declaration name: (identifier) @font-lock-type-face)
(module_path (identifier) @font-lock-type-face)
(bit_option (identifier) @font-lock-property-face)
(enum_declaration name: (type_identifier) @font-lock-type-face)
(enum_variant name: (type_identifier) @font-lock-constant-face)
(enum_pattern module: (identifier) @font-lock-type-face)
(enum_pattern variant: (type_identifier) @font-lock-constant-face)
(member_expression object: (type_identifier) member: (type_identifier) @font-lock-constant-face)
(concise_field name: (identifier) @font-lock-property-face)
[\"module\" \"import\" \"as\" \"class\" \"actor\" \"interface\" \"external\" \"native\" \"enum\" \"from\"
 \"is\" \"with\" \"let\" \"var\" \"new\" \"be\" \"fn\" \"match\" \"if\" \"loop\" \"in\"
 \"break\" \"assert\" \"panic\" \"todo\" \"echo\" \"test\" \"skip\"] @font-lock-keyword-face
[\"+\" \"-\" \"*\" \"/\" \"%\" \"=\" \"+=\" \"-=\" \"*=\" \"==\" \"!=\" \"<\" \"<=\" \">\" \">=\"
 \"!\" \"&&\" \"||\" \"&\" \"|\" \"|>\" \"?\" \"->\" \"..\"] @font-lock-operator-face
[\"(\" \")\" \"#(\" \"[\" \"]\" \"{\" \"}\" \"<<\" \">>\"] @font-lock-bracket-face
[\",\" \":\" \".\"] @font-lock-delimiter-face
")

(defvar pooka--treesit-font-lock-settings
  (when (fboundp 'treesit-font-lock-rules)
    (treesit-font-lock-rules :language 'pooka :feature 'font-lock :override t pooka--treesit-query)))

(provide 'pooka-font-lock)
;;; pooka-font-lock.el ends here
