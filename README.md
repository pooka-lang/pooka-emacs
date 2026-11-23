# Pooka for Emacs

A small Emacs home for Pooka source and specs, with Tree-sitter highlighting and a regex fallback.

## Install locally

Copy this directory to `~/.emacs.d/site-lisp/pooka-emacs`, then add:

```elisp
(add-to-list 'load-path
             (expand-file-name "site-lisp/pooka-emacs" user-emacs-directory))
(require 'pooka-mode)
```

The mode selects `.pooka` and `.spec.pooka` automatically. Emacs 29.1+ is supported.

## Tree-sitter

With an Emacs build that supports Tree-sitter, Git, the Tree-sitter CLI and a C compiler, run `M-x pooka-install-grammar` or press `C-c C-i`. Emacs downloads the pinned public grammar itself and generates a compatible ABI 14 parser; no neighbouring checkout is required. Reopen Pooka buffers afterwards.

Without the grammar, the mode uses regex font-lock. Both sets of rules live in this package's `pooka-font-lock.el`.

## Language server

Install a compiler build that includes `pooka lsp`. To enable it through Eglot, add:

```elisp
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(pooka-mode . ("pooka" "lsp"))))
(add-hook 'pooka-mode-hook #'eglot-ensure)
```

If needed, replace `"pooka"` with the absolute compiler path. Open a Pooka file and use `M-.` to jump to a definition or `M-x eglot-format-buffer` to format. Run `pooka deps download` in the project if dependencies are missing, then save a Pooka file. Use `M-x eglot-reconnect` after upgrading the compiler.

## Development

Edit `pooka-mode.el` and `pooka-font-lock.el` directly. Run from this directory:

```sh
emacs -Q --batch -L . -l tests/pooka-mode-test.el -f ert-run-tests-batch-and-exit
```

The tests check file detection, comment and string syntax, keyword and numeric highlighting, and function names. CI also installs the pinned grammar and exercises Tree-sitter highlighting.

## Licence

Apache-2.0. See [LICENSE](LICENSE).
