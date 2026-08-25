;;; canonical.el --- Emit rel=canonical on every exported page  -*- lexical-binding: t; -*-

;; GitHub Pages serves the same content at more than one URL: "/",
;; "/index.html" and even "/index.html" with a doubled slash all return
;; 200.  Without a canonical link Google picks a winner on its own and
;; splits ranking signals across the duplicates.  URL Inspection was
;; reporting "User-declared canonical: None" for every page.
;;
;; The canonical URL differs per page, so it cannot live in a static
;; #+HTML_HEAD line in setupfile.org.  Derive it from the file being
;; exported instead, via a final-output filter.
;;
;; Loaded by process.sh:  emacs --batch -l canonical.el <file> ...

(require 'ox-html)

(defconst wm/site-base-url "https://wmealing.github.io/"
  "Base URL of the published site.  Must end in a slash.")

(defun wm/canonical-url-for (input-file)
  "Return the canonical URL for INPUT-FILE, or nil if it has no name.
The site root is served at \"/\", so index.org canonicalises to the
bare base URL rather than to \"/index.html\"."
  (when input-file
    (let ((base (file-name-base input-file)))
      (if (string= base "index")
          wm/site-base-url
        (concat wm/site-base-url base ".html")))))

(defun wm/html-add-canonical (output backend info)
  "Insert a rel=canonical link into OUTPUT for HTML exports."
  (if (not (org-export-derived-backend-p backend 'html))
      output
    (let ((url (wm/canonical-url-for (plist-get info :input-file))))
      (cond
       ;; Nothing to point at (e.g. export from a buffer with no file).
       ((null url) output)
       ;; A page that already declares one wins; don't emit a second.
       ((string-match-p "rel=\"canonical\"" output) output)
       ;; No </head> to anchor to; leave the document alone.
       ((not (string-match-p "</head>" output)) output)
       (t
        (replace-regexp-in-string
         "</head>"
         (concat "<link rel=\"canonical\" href=\"" url "\" />\n</head>")
         output t t))))))

(add-to-list 'org-export-filter-final-output-functions #'wm/html-add-canonical)

(provide 'canonical)
;;; canonical.el ends here
