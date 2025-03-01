(require 'package)
(package-initialize)

(unless (package-installed-p 'ox-rss)
  (package-refresh-contents)
  (package-install 'ox-rss))

(require 'org)
(require 'ox-rss)
(require 'ox-publish)

(defvar domain "https://jarizleifr.github.io/")
(defconst tags '("untagged" "life" "philosophy" "tech" "gamedev" "travel"))

(defconst default-description
  "A personal blog and the primary web presence of the public eccentric Antti Joutsi, aka Jarizleifr.")

(defun file-to-string (file) 
  "File to string function"
  (with-temp-buffer (insert-file-contents file) 
		    (buffer-string)))

(setq site-head-icons (file-to-string "html/head-icons.html"))
(setq site-nav (file-to-string "html/nav.html"))
(setq site-footer (file-to-string "html/footer.html"))

(setq org-export-global-macros
      '(("timestamp" . "@@html:<span class=\"timestamp\">$1</span>@@") 
	("keywords" . "@@html:<span class=\"tags\">$1</span>@@")))

(org-export-define-derived-backend
 'jzlfr-html 'html :translate-alist '((template . jzlfr-html-template)))

(defun jzlfr-get-url (path)
  "Transform absolute PATH into url"
  ;; Fix for tags
  (setq fixed-path (replace-regexp-in-string "/tags/" "/posts/" path))
  (string-match "org/\\(.*\\).org" fixed-path)
  (concat domain (match-string 1 fixed-path) ".html"))

(defun jzlfr-html-template (contents info)
  (setq page-title (org-export-data (or (plist-get info :title) "") info))
  (setq page-file (org-export-data (plist-get info :input-file) info))
  (setq page-date (org-export-data (or (plist-get info :date) nil) info))
  (setq page-excerpt (org-export-data (or (plist-get info :excerpt)
                                          default-description) info))
  
  (setq is-post (and
		 (string-match-p (regexp-quote "posts") page-file)
		 (not (string-match-p (regexp-quote "archive") page-file))))
  
  (concat
   "<!DOCTYPE html>\n"
   "<html lang=\"en\">\n"
   "<head>\n"
   "<meta charset=\"utf-8\">\n"
   "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
   "<link rel=\"stylesheet\" href=\"/css/style.css\" type=\"text/css\"/>"
   "<link rel=\"alternate\" href=\"/rss.xml\" type=\"application/rss+xml\" title=\"RSS Feed for Jarizleifr's Web of Weird\"/>"
   (format "<title>%s</title>\n" page-title)
   (format "<meta name=\"description\" content=\"%s\">\n" page-excerpt)
   (format "<meta property=\"og:title\" content=\"%s\">\n" page-title)
   "<meta property=\"og:type\" content=\"website\">\n"
   (format "<meta property\"og:image\" content=\"%s/img/jarizleifr.jpg\">\n" domain)
   (format "<meta property=\"og:url\" content=\"%s\">\n"
	   (jzlfr-get-url (plist-get info :input-file)))
   (format "<meta property=\"og:description\" content=\"%s\">\n" page-excerpt)
   site-head-icons
   "</head>\n"
   "<body>\n"
   site-nav
   "<div id=\"content\">\n"
   (if is-post
       (format "<div class=\"tags\">%s</div>\n"
	       (format-sitemap-entry-keywords (plist-get info :keywords))) "")
   (format "<header><h1>%s</h1>%s</header>" page-title
	   (if is-post (if page-date (format "<h4>%s</h4>" page-date) "") ""))
   contents
   "</div>\n"
   site-footer
   "</body>\n"
   "</html>\n"))

(defun jzlfr-html-publish-to-html (plist filename pub-dir)
  (org-publish-org-to 'jzlfr-html filename ".html" plist pub-dir))

(defun jzlfr-rss-publish (plist filename pub-dir)
  (if (equal "rss.org" (file-name-nondirectory filename))
      (org-rss-publish-to-rss plist filename pub-dir)))

(defun jzlfr-format-rss-feed-entry (entry style project)
  (cond ((not (directory-name-p entry))
         (let* ((file (org-publish--expand-file-name entry project))
                (title (org-publish-find-title entry project))
                (date (format-time-string "%Y-%m-%d"
                                          (org-publish-find-date entry project)))
                (link (concat "posts/" (file-name-sans-extension entry) ".html")))
           (with-temp-buffer
             (org-mode)
             (insert (format "* %s\n" title))
             (org-set-property "PUBDATE" date)
             (org-set-property "RSS_PERMALINK" link)
             (insert-file-contents file)
             ;; Remove leading "* " before returning
             (goto-char (point-min))
             (when (looking-at "^\\* ") (delete-char 2))
             (buffer-string))))
        ((eq style 'tree)
         ;; Return only last subdir.
         (file-name-nondirectory (directory-file-name entry)))
        (t entry)))

(defun format-sitemap-entry-keywords (keywords) 
  "Format sitemap KEYWORDS into links to tag pages."
  (cond ((stringp keywords) 
	 (format "%s" (mapconcat
                       (lambda (arg) 
			 (format "<a href=\"/posts/tag-%s.html\">:%s</a>" arg arg)) 
		       (cl-sort (split-string keywords ",") 'string-lessp) " ")))
	(t "<a href=\"/posts/tag-untagged.html\">:untagged</a>")))

(defun format-sitemap-entry (entry style project) 
  "Format ENTRY in org-publish PROJECT Sitemap format ENTRY ENTRY STYLE format that includes date."
  (let ((filename (org-publish-find-title entry project))) 
    (if (= (length filename) 0) 
	(format "*%s*" entry) 
      (format "{{{timestamp(%s)}}} [[file:%s][%s]] {{{keywords(%s)}}}"
              (format-time-string
	       "%Y-%m-%d" (org-publish-find-date entry project))
	      entry filename
              (format-sitemap-entry-keywords
               (org-publish-find-property entry :keywords project 'html))))))

(defun create-sitemap (title list)
  (concat "#+TITLE: " title "\n\n"
          "#+ATTR_HTML: :class posts-list\n"
          (format "%s" (org-list-to-org list))))

(defun create-rss-feed (title list)
  (concat "#+TITLE: " title "\n"
          "#+EMAIL: " "antti.joutsi@tutamail.com\n"
          "#+AUTHOR: " "jarizleifr\n"
          "#+DESCRIPTION: " "this is a test description" "\n"
          (org-list-to-subtree list)))
;; ))

(defun create-tag-page (keyword) 
  "Create a tag page for KEYWORD"
  (let* ((filename (format "org/tags/tag-%s.org" keyword))
         (posts (get-tagged-entry-lines keyword)))
    (write-region
     (format
      (concat "#+TITLE: Posts tagged with '%s'\n"
              "#+ATTR_HTML: :class posts-list\n%s")
      keyword posts)
     nil
     (expand-file-name filename))))

(defun get-tagged-entry-lines (tag) 
  "Filter appropriate tags from the archive file" 
  (defun slurp (f) 
    (with-temp-buffer (insert-file-contents f) 
		      (buffer-substring-no-properties 
		       (point-min) 
		       (point-max)))) 
  (mapconcat (lambda (line) 
	       (if (eq (string-match-p (regexp-quote tag) line) nil)
                   ""
                 (format "%s\n" line))) 
	     (split-string (slurp "./org/posts/archive.org") "\n" t) ""))

(defun create-tag-pages (project) 
  "Create RSS feed and collections of tag pages for the blog"
  (dolist (tag tags) (create-tag-page tag)))

(setq org-publish-project-alist
      `(("pages" :base-directory "org/" 
	 :base-extension "org" 
	 :publishing-directory "docs/" 
	 :publishing-function jzlfr-html-publish-to-html 
	 :headline-levels 4 
	 :recursive nil
	 :with-toc nil
	 :section-numbers nil
	 :html-doctype "html5"
	 :html-html5-fancy t) 
	("posts" :base-directory "org/posts/" 
	 :base-extension "org" 
         :exclude "rss.org\\|archive.org"
	 :publishing-directory "docs/posts/" 
	 :publishing-function jzlfr-html-publish-to-html 
	 :headline-levels 4 
	 :recursive nil
	 :with-toc nil
	 :section-numbers nil
	 :html-doctype "html5"
	 :html-html5-fancy t
	 :auto-sitemap t 
	 :sitemap-title "Archive" 
	 :sitemap-filename "archive.org"
	 :sitemap-function create-sitemap
	 :sitemap-format-entry format-sitemap-entry 
	 :sitemap-sort-files anti-chronologically 
	 :completion-function create-tag-pages)
        ("rss" :base-directory "org/posts"
         :base-extension "org"
         :exclude "rss.org\\|archive.org"
         :publishing-directory "docs/"
         :publishing-function jzlfr-rss-publish
         :html-link-home "https://jarizleifr.github.io/"
         :html-link-use-abs-url t
         :html-link-org-files-as-html t
         :auto-sitemap t
         :sitemap-title "RSS" 
         :sitemap-filename "rss.org"
         :sitemap-function create-rss-feed
         :sitemap-format-entry jzlfr-format-rss-feed-entry 
         :sitemap-sort-files anti-chronologically)
        ("tags" :base-directory "org/tags/" 
         :base-extension "org" 
         :publishing-directory "docs/posts/" 
         :publishing-function jzlfr-html-publish-to-html 
         :headline-levels 4
         :recursive nil
         :with-toc nil
         :section-numbers nil
         :html-doctype "html5"
         :html-html5-fancy t)
        ("static" :base-directory "org/" 
         :base-extension "png\\|gif\\|ico\\|jpg\\|svg" 
         :publishing-directory "docs/" 
         :exclude "drafts/.*" 
         :recursive t 
         :publishing-function org-publish-attachment) 
        ("org" :components ("posts" "tags" "pages" "static"))))
