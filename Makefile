# Makefile for Jarizleifr blog

SOURCES = $(wildcard **/*.org)

.PHONY: all publish publish_no_init create-thumbnails clean serve watch

all: publish

publish: publish.el
	@echo "Publishing... with current Emacs configurations."
	emacs --batch --load publish.el --funcall org-publish-all
	make create-thumbnails

publish_no_init: publish.el
	@echo "Publishing... with --no-init."
	emacs --batch --no-init --load publish.el --funcall org-publish-all
	make create-thumbnails

create-thumbnails:
	@echo "Creating gallery thumbnails..."
	mkdir -p docs/img/gallery/thumbnails
	mogrify -format png -path docs/img/gallery/thumbnails \
		-thumbnail 30%% -auto-orient org/img/gallery/*.jpg

clean:
	@echo "Cleaning up.."
	@rm -rvf .watch-file
	@rm -rvf *.elc
	@rm -rvf docs
	@rm -rvf ~/.org-timestamps/*

serve:
	mkdir -p docs
	cmd /c start /d docs python3 -m http.server

watch: serve
	while true; do make .watch-file -q || make .watch-file; sleep 3.0; done

# Create a dummy sentinel file for sources to check their timestamps against.
.watch-file: $(SOURCES)
	make publish
	@touch $@
