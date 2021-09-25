(require 'ox-publish)

(setq site-nav "<nav><ol>
<li><a href=\"./index.html\">Blog</a></li>
<li><a href=\"./posts/archive.html\">Archive</a></li>
<li><a href=\"./work.html\">Work</a></li>
<li><a href=\"./about.html\">About</a></li>
<li><a href=\"./resume.html\">Resume</a></li>
</ol></nav>")
;; These should be replaced with "/index.html" style root paths once main layouts are finished
(setq site-nav-post "<nav><ol>
<li><a href=\"../index.html\">Blog</a></li>
<li><a href=\"./archive.html\">Archive</a></li>
<li><a href=\"../work.html\">Work</a></li>
<li><a href=\"../about.html\">About</a></li>
<li><a href=\"../resume.html\">Resume</a></li>
</ol></nav>")
(setq site-style "<link rel=\"stylesheet\" href=\"./css/style.css\" type=\"text/css\"/>")
(setq site-style-post "<link rel=\"stylesheet\" href=\"../css/style.css\" type=\"text/css\"/>")

(setq site-footer "<footer>Copyright © 2021 Antti Joutsi</footer>")

(setq org-export-global-macros '(("timestamp" . "@@html:<span class=\"timestamp\">[$1]</span>@@") 
                                 ("excerpt" . "@@html:<p class=\"excerpt\">$1</p>@@")))

(defun format-sitemap-entry (entry style project) 
  "Format ENTRY in org-publish PROJECT Sitemap format ENTRY ENTRY STYLE format that includes date."
  (let ((filename (org-publish-find-title entry project))) 
    (if (= (length filename) 0) 
        (format "*%s*" entry) 
      (format "[[file:%s][%s]] {{{timestamp(%s)}}} {{{excerpt(%s)}}}" entry
              filename (format-time-string "%Y-%m-%d" (org-publish-find-date entry project)) 
              (org-publish-find-property entry 
                                         :description project 
                                         'html)))))

(setq org-publish-project-alist `(("pages" :base-directory "org/" 
                                   :base-extension "org" 
                                   :publishing-directory "docs/" 
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
                                   :html-preamble ,site-nav-post 
                                   :html-postamble ,site-footer 
                                   :html-head ,site-style-post 
                                   :html-head-include-default-style nil 
                                   :html-head-include-scripts nil 
                                   :auto-sitemap t 
                                   :sitemap-title "Archive" 
                                   :sitemap-filename "archive.org" 
                                   :sitemap-format-entry format-sitemap-entry 
                                   :sitemap-sort-files anti-chronologically) 
                                  ("static" :base-directory "org/" 
                                   :base-extension "css\\|js\\|png\\|jpg" 
                                   :publishing-directory "docs/" 
                                   :recursive t 
                                   :publishing-function org-publish-attachment) 
                                  ("org" :components ("posts" "pages" "static"))))
