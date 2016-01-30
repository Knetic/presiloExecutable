default: build
all: package

export GOPATH=$(CURDIR)/
export GOBIN=$(CURDIR)/.temp/

init: clean
	go get ./...

build: init
	go build -o ./.output/presilo .

test:
	go test
	go test -bench=.

clean:
	@rm -rf ./.output/

fmt:
	@go fmt .
	@go fmt ./src/presilo

dist: build test

	export GOOS=linux; \
	export GOARCH=amd64; \
	go build -o ./.output/presilo64 .

	export GOOS=linux; \
	export GOARCH=386; \
	go build -o ./.output/presilo32 .

	export GOOS=darwin; \
	export GOARCH=amd64; \
	go build -o ./.output/presilo_osx .

	export GOOS=windows; \
	export GOARCH=amd64; \
	go build -o ./.output/presilo.exe .

package: versionTest fpmTest dist

	fpm \
		--log error \
		-s dir \
		-t deb \
		-v $(PRESILO_VERSION) \
		-n presilo \
		./.output/presilo64=/usr/local/bin/presilo \
		./docs/presilo.7=/usr/share/man/man7/presilo.7 \
		./autocomplete/presilo=/etc/bash_completion.d/presilo

	fpm \
		--log error \
		-s dir \
		-t deb \
		-v $(PRESILO_VERSION) \
		-n presilo \
		-a i686 \
		./.output/presilo32=/usr/local/bin/presilo \
		./docs/presilo.7=/usr/share/man/man7/presilo.7 \
		./autocomplete/presilo=/etc/bash_completion.d/presilo

	@mv ./*.deb ./.output/

	fpm \
		--log error \
		-s dir \
		-t rpm \
		-v $(PRESILO_VERSION) \
		-n presilo \
		./.output/presilo64=/usr/local/bin/presilo \
		./docs/presilo.7=/usr/share/man/man7/presilo.7 \
		./autocomplete/presilo=/etc/bash_completion.d/presilo
	fpm \
		--log error \
		-s dir \
		-t rpm \
		-v $(PRESILO_VERSION) \
		-n presilo \
		-a i686 \
		./.output/presilo32=/usr/local/bin/presilo \
		./docs/presilo.7=/usr/share/man/man7/presilo.7 \
		./autocomplete/presilo=/etc/bash_completion.d/presilo

	@mv ./*.rpm ./.output/

fpmTest:
ifeq ($(shell which fpm), )
	@echo "FPM is not installed, no packages will be made."
	@echo "https://github.com/jordansissel/fpm"
	@exit 1
endif

versionTest:
ifeq ($(PRESILO_VERSION), )

	@echo "No 'PRESILO_VERSION' was specified."
	@echo "Export a 'PRESILO_VERSION' environment variable to perform a package"
	@exit 1
endif
