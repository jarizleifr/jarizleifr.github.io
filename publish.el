(require 'ox-publish)
(setq org-publish-project-alist '(("org-notes" :base-directory "org/" 
                                   :base-extension "org" 
                                   :publishing-directory "public/" 
                                   :recursive t 
                                   :publishing-function org-html-publish-to-html 
                                   :headline-levels 4 
                                   :auto-preamble t) 
                                  ("org-static" :base-directory "org/" 
                                   :base-extension "css\\|js\\|png\\|jpg" 
                                   :publishing-directory "public/" 
                                   :recursive t 
                                   :publishing-function org-publish-attachment) 
                                  ("org" :components ("org-notes" "org-static"))))
