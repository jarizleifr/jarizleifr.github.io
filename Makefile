# Makefile for Jarizleifr blog

ORG_SOURCES = $(wildcard **/*.org) $(wildcard html/*.html) publish.el
ORG_SENTINEL = docs/.org.sentinel

CSS_SOURCES = $(wildcard org/css/*.scss)
CSS_TARGETS = docs/css/style.css

GALLERY_SOURCES = $(wildcard org/img/gallery/*.jpg)
GALLERY_SENTINEL = docs/.gallery.sentinel

.PHONY: all publish publish_no_init build serve watch clean

all: build 

publish: publish.el
	@echo "Publishing... with current Emacs configurations."
	emacs --batch --load publish.el --funcall org-publish-all

publish_no_init: publish.el
	@echo "Publishing... with --no-init."
	emacs --batch --no-init --load publish.el --funcall org-publish-all

build: $(ORG_SENTINEL) $(CSS_TARGETS) $(GALLERY_SENTINEL)

serve:
	mkdir -p docs
	cmd /c start /d docs python3 -m http.server

watch: serve
	while true; do make build -q || make build; sleep 3.0; done

clean:
	@echo "Cleaning up.."
	@rm -rvf *.elc
	@rm -rvf docs
	@rm -rvf ~/.org-timestamps/*

$(ORG_SENTINEL): $(ORG_SOURCES)
	make publish
	cp html/googleb8481861e1b09337.html docs
	@touch $@

$(CSS_TARGETS): $(CSS_SOURCES) 
	@echo "Compiling Sass into CSS..."
	mkdir -p docs/css
	sass org/css/style.scss $@

$(GALLERY_SENTINEL): $(GALLERY_SOURCES)
	@echo "Creating gallery thumbnails..."
	mkdir -p docs/img/gallery/thumbnails
	mogrify -format png -path docs/img/gallery/thumbnails \
		-thumbnail 30%% -auto-orient org/img/gallery/*.jpg
	@touch $@

