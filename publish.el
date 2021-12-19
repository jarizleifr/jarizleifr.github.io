(require 'ox-publish)

(setq site-nav "<nav><ol>
<li><a href=\"/index.html\">Home</a></li>
<li><a href=\"/posts/archive.html\">Archive</a></li>
<li><a href=\"/gallery.html\">Gallery</a></li>
<li><a href=\"/resume.html\">Resume</a></li>
</ol></nav>")
(setq site-style "<link rel=\"stylesheet\" href=\"/css/style.css\" type=\"text/css\"/>")
(setq site-footer "<footer>
<div class=\"contact\">
<p>Find me elsewhere:</p>
<div>
<a href=\"https://github.com/jarizleifr\"><img src=\"/img/github.svg\" alt=\"GitHub\"/></a>
<a href=\"https://www.linkedin.com/in/anttijoutsi\"><img src=\"/img/linkedin.svg\" alt=\"Linkedin\"/></a>
</div> 
<p>Send me an email:<br/><a href=\"mailto:antti.joutsi@gmail.com\">antti.joutsi@gmail.com</a></p>
</div>
<div class=\"cc-by\">
<a href=\"https://creativecommons.org/licenses/by/4.0/\"><img src=\"/img/by.svg\" alt=\"CC-BY\" /></a>
<p>Text content on this website is licensed under the Creative Commons Attribution 4.0 International License. All images, except where otherwise noted, are all rights reserved © 2021 Antti Joutsi, and you must request a permission to use this material.</p></div></footer>")

(setq org-export-global-macros '(("timestamp" . "@@html:<span class=\"timestamp\">[$1]</span>@@") 
                                 ("keywords" . "@@html:<span class=\"keywords\">$1</span>@@")))
(setq org-confirm-babel-evaluate nil)

(defun format-sitemap-entry-keywords (keywords)
  "Format sitemap KEYWORDS into links to tag pages."
  (cond ((stringp keywords) (format "%s" (mapcar (lambda (arg) (format "<a href=\"/posts/tag-%s.html\">:%s</a>" arg arg)) (split-string keywords ","))))
	(t "(<a href=\"/posts/tag-untagged.html\">:untagged</a>)")))

(defun format-sitemap-entry (entry style project) 
  "Format ENTRY in org-publish PROJECT Sitemap format ENTRY ENTRY STYLE format that includes date."
  (let ((filename (org-publish-find-title entry project))) 
    (if (= (length filename) 0) 
        (format "*%s*" entry) 
      (format "{{{timestamp(%s)}}} [[file:%s][%s]] {{{keywords(%s)}}}"
	       (format-time-string "%Y-%m-%d" (org-publish-find-date entry project))
               entry
	       filename
	       (format-sitemap-entry-keywords (org-publish-find-property entry :keywords project 'html))))))

(defun create-tag-page (keyword)
  "Create a tag page for KEYWORD"
  (write-region (format "
#+TITLE: Posts tagged with '%s'\n
%s
" keyword (get-tagged-entry-lines keyword)) nil (expand-file-name (format "org/tags/tag-%s.org" keyword))))

(defun get-tagged-entry-lines (tag)
  "Filter appropriate tags from the archive file"
  (defun slurp (f)
    (with-temp-buffer
      (insert-file-contents f)
      (buffer-substring-no-properties
        (point-min)
        (point-max))))

  (mapconcat (lambda (line) (if (eq (string-match-p (regexp-quote tag) line) nil) "" (format "%s\n" line))) (split-string
    (slurp "./org/posts/archive.org") "\n" t) ""))

(defun create-tag-pages (project)
  "Create a collection of tag pages for the blog"
  (create-tag-page "untagged")
  (create-tag-page "life")
  (create-tag-page "philosophy")
  (create-tag-page "tech")
  (create-tag-page "gamedev"))

(setq org-publish-project-alist `(("pages" :base-directory "org/" 
                                   :base-extension "org" 
                                   :publishing-directory "docs/" 
                                   :publishing-function org-html-publish-to-html 
                                   :headline-levels 4 
                                   :recursive nil 
                                   :with-toc nil 
                                   :title nil 
                                   :section-numbers nil 
                                   :html-doctype "html5" 
                                   :html-html5-fancy t 
                                   :html-preamble ,site-nav 
                                   :html-postamble ,site-footer 
                                   :html-head ,site-style 
                                   :html-head-include-default-style nil 
                                   :html-head-include-scripts nil) 
                                  ("posts" :base-directory "org/posts/" 
                                   :base-extension "org" 
                                   :publishing-directory "docs/posts/" 
                                   :publishing-function org-html-publish-to-html 
				   :headline-levels 4 
                                   :recursive nil 
                                   :with-toc nil 
                                   :section-numbers nil 
                                   :html-doctype "html5" 
                                   :html-html5-fancy t 
                                   :html-preamble ,site-nav 
                                   :html-postamble ,site-footer 
                                   :html-head ,site-style 
                                   :html-head-include-default-style nil 
                                   :html-head-include-scripts nil 
                                   :auto-sitemap t 
                                   :sitemap-title "Archive" 
                                   :sitemap-filename "archive.org" 
                                   :sitemap-format-entry format-sitemap-entry 
                                   :sitemap-sort-files anti-chronologically
				   :completion-function create-tag-pages)
                                  ("tags" :base-directory "org/tags/" 
                                   :base-extension "org"
                                   :publishing-directory "docs/posts/" 
                                   :publishing-function org-html-publish-to-html 
				   :headline-levels 4 
                                   :recursive nil 
                                   :with-toc nil 
                                   :section-numbers nil 
                                   :html-doctype "html5" 
                                   :html-html5-fancy t 
                                   :html-preamble ,site-nav 
                                   :html-postamble ,site-footer 
                                   :html-head ,site-style 
                                   :html-head-include-default-style nil 
                                   :html-head-include-scripts nil)
                                  ("static" :base-directory "org/" 
                                   :base-extension "css\\|js\\|png\\|jpg\\|svg" 
                                   :publishing-directory "docs/"
				   :exclude "drafts/.*"
                                   :recursive t 
                                   :publishing-function org-publish-attachment) 
                                  ("org" :components ("posts" "tags" "pages" "static"))))
