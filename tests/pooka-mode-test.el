;;; pooka-mode-test.el --- Mode checks -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: Apache-2.0
(require 'ert)
(require 'pooka-mode)

(unless (getenv "POOKA_TEST_TREESITTER")
  (fset 'pooka--treesit-setup (lambda () nil)))

(defun pooka-test-face (source word &optional declaration)
  (with-temp-buffer
    (insert (if declaration
                (concat "module demo\n" source "\n")
              (concat "module demo\nmain() {\n" source "\n}\n")))
    (pooka-mode)
    (font-lock-ensure)
    (goto-char (point-min))
    (search-forward word)
    (get-text-property (- (point) (length word)) 'face)))

(ert-deftest pooka-file-detection ()
  (dolist (name '("main.pooka" "main.spec.pooka"))
    (with-temp-buffer
      (setq buffer-file-name name)
      (set-auto-mode)
      (should (eq major-mode 'pooka-mode)))))

(ert-deftest pooka-keywords-and-functions ()
  (should (eq (pooka-test-face "native Bridge from \"bridge\" { run() -> Int }" "native" t) 'font-lock-keyword-face))
  (should (eq (pooka-test-face "read(value)" "read") 'font-lock-function-name-face)))

(ert-deftest pooka-number-formats ()
  (dolist (number '("42" "0x2A" "0b1010" "0o52" "1.25" "2e3"))
    (should (eq (pooka-test-face (concat "let number = " number) number)
                'font-lock-number-face))))

(ert-deftest pooka-comments-and-strings ()
  (should (eq (pooka-test-face "// native" "native") 'font-lock-comment-face))
  (should (eq (pooka-test-face "\"native\"" "native") 'font-lock-string-face)))

(ert-deftest pooka-sample-fontifies ()
  (with-temp-buffer
    (insert-file-contents "tests/sample.spec.pooka")
    (pooka-mode)
    (font-lock-ensure)
    (should (equal comment-start "// "))))

(ert-deftest pooka-tree-sitter-when-requested ()
  (when (getenv "POOKA_TEST_TREESITTER")
    (should (treesit-ready-p 'pooka t))
    (with-temp-buffer
      (insert-file-contents "tests/sample.spec.pooka")
      (pooka-mode)
      (font-lock-ensure)
      (should (treesit-parser-list)))))
