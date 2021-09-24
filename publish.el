(require 'ox-publish)
(setq org-publish-project-alist '(("org-notes" :base-directory "org/" 
                                   :base-extension "org" 
                                   :publishing-directory "public/" 
                                   :recursive t 
                                   :publishing-function org-html-publish-to-html 
                                   :headline-levels 4 
                                   :auto-preamble t 
                                   :with-toc nil 
                                   :section-numbers nil
                                   :html-doctype "html5"
                                   :html-html5-fancy t
                                   :html-preamble "<nav><a href=\"./index.html\">Home</a><a href=\"./resume.html\">Resume</a></nav>"
                                   :html-postamble "<footer>Copyright © 2021 Antti Joutsi</footer>"
                                   :html-head-include-default-style nil
                                   :html-head-include-scripts nil) 
                                  ("org-static" :base-directory "org/" 
                                   :base-extension "css\\|js\\|png\\|jpg" 
                                   :publishing-directory "public/" 
                                   :recursive t 
                                   :publishing-function org-publish-attachment) 
                                  ("org" :components ("org-notes" "org-static"))))
