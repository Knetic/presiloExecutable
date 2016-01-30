default: build
all: package

export GOPATH=$(CURDIR)/
export GOBIN=$(CURDIR)/.temp/

init: clean
	go get ./...

build: init
	go build -o ./.output/presiloExecutable .

test:
	go test
	go test -bench=.

clean:
	@rm -rf ./.output/

fmt:
	@go fmt .
	@go fmt ./src/presiloExecutable

dist: build test

	export GOOS=linux; \
	export GOARCH=amd64; \
	go build -o ./.output/presiloExecutable64 .

	export GOOS=linux; \
	export GOARCH=386; \
	go build -o ./.output/presiloExecutable32 .

	export GOOS=darwin; \
	export GOARCH=amd64; \
	go build -o ./.output/presiloExecutable_osx .

	export GOOS=windows; \
	export GOARCH=amd64; \
	go build -o ./.output/presiloExecutable.exe .

package: versionTest fpmTest dist

	fpm \
		--log error \
		-s dir \
		-t deb \
		-v $(PRESILO_VERSION) \
		-n presiloExecutable \
		./.output/presiloExecutable64=/usr/local/bin/presiloExecutable \
		./docs/presiloExecutable.7=/usr/share/man/man7/presiloExecutable.7 \
		./autocomplete/presiloExecutable=/etc/bash_completion.d/presiloExecutable

	fpm \
		--log error \
		-s dir \
		-t deb \
		-v $(PRESILO_VERSION) \
		-n presiloExecutable \
		-a i686 \
		./.output/presiloExecutable32=/usr/local/bin/presiloExecutable \
		./docs/presiloExecutable.7=/usr/share/man/man7/presiloExecutable.7 \
		./autocomplete/presiloExecutable=/etc/bash_completion.d/presiloExecutable

	@mv ./*.deb ./.output/

	fpm \
		--log error \
		-s dir \
		-t rpm \
		-v $(PRESILO_VERSION) \
		-n presiloExecutable \
		./.output/presiloExecutable64=/usr/local/bin/presiloExecutable \
		./docs/presiloExecutable.7=/usr/share/man/man7/presiloExecutable.7 \
		./autocomplete/presiloExecutable=/etc/bash_completion.d/presiloExecutable
	fpm \
		--log error \
		-s dir \
		-t rpm \
		-v $(PRESILO_VERSION) \
		-n presiloExecutable \
		-a i686 \
		./.output/presiloExecutable32=/usr/local/bin/presiloExecutable \
		./docs/presiloExecutable.7=/usr/share/man/man7/presiloExecutable.7 \
		./autocomplete/presiloExecutable=/etc/bash_completion.d/presiloExecutable

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
