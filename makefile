ALL = $(shell echo "2.6.9 2.7.18 3.2.6 3.3.7 3.4.10 3.5.9 3.6.10 3.7.7 3.8.4")


build:

	@if [ "$(version)" = "all" ]; then                                    \
            for v in $(ALL); do                                               \
                make build version="$$v";                                     \
            done                                                              \
	else                                                                  \
            pyab=$(shell echo $(version) | cut -d. -f1,2);                    \
	    tag="ubuntu-pyenv:$$pyab";                                        \
	    echo "Building $$tag...";                                         \
            docker build -q --tag "$$tag" . --build-arg version="$(version)"; \
        fi
