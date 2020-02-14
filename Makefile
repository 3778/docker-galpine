VERSION := latest
APK_URL := https://github.com/3778/docker-galpine/releases/download/$(VERSION)


.PHONY: all
all: dist build


.PHONY: dist
dist:
	mkdir -p dist
	docker build -f Dockerfile.dist -t galpine-dist .
	docker run --name galpine-builder -d --rm galpine-dist tail -f /dev/null
	docker cp galpine-builder:/opt/glibc.apk      dist/
	docker cp galpine-builder:/opt/glibc-bin.apk  dist/
	docker cp galpine-builder:/opt/glibc-i18n.apk dist/
	docker kill galpine-builder


.PHONY: build
build:
	docker build -t galpine:$(VERSION) --build-arg APK_URL=$(APK_URL) .
