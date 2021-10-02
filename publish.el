(require 'ox-publish)

(setq site-nav "<nav><ol>
<li><a href=\"/index.html\">Home</a></li>
<li><a href=\"/posts/archive.html\">Archive</a></li>
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
<img src=\"/img/by.svg\" alt=\"CC-BY\" />This work is licensed under a Creative Commons Attribution 4.0 International License</div></footer>")

(setq org-export-global-macros '(("timestamp" . "@@html:<span class=\"timestamp\">[$1]</span>@@") 
                                 ("excerpt" . "@@html:<p class=\"excerpt\">$1</p>@@")))

(defun format-sitemap-entry (entry style project) 
  "Format ENTRY in org-publish PROJECT Sitemap format ENTRY ENTRY STYLE format that includes date."
  (let ((filename (org-publish-find-title entry project))) 
    (if (= (length filename) 0) 
        (format "*%s*" entry) 
      (format "{{{timestamp(%s)}}} [[file:%s][%s]]" (format-time-string "%Y-%m-%d"
                                                                        (org-publish-find-date entry
                                                                                               project))
              entry filename))))

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
                                   :sitemap-sort-files anti-chronologically) 
                                  ("static" :base-directory "org/" 
                                   :base-extension "css\\|js\\|png\\|jpg\\|svg" 
                                   :publishing-directory "docs/" 
                                   :recursive t 
                                   :publishing-function org-publish-attachment) 
                                  ("org" :components ("posts" "pages" "static"))))
