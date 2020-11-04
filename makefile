ALL = $(shell echo "2.6.9 2.7.18 3.2.6 3.3.7 3.4.10                           \
                    3.5.10 3.6.12 3.7.9 3.8.6 3.9.0")


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


publish:

	@if [ "$(version)" = "all" ]; then                                    \
            for v in $(ALL); do                                               \
                make publish version="$$v";                                   \
            done;                                                             \
	    make publish version=latest;                                      \
	else                                                                  \
	    user=$$(docker info 2>/dev/null | sed -n '/[ ]*Username:/p'       \
	            | rev | cut -d' ' -f1 | rev);                             \
	    if [ "$(version)" = "latest" ]; then                              \
                pyab=$$(echo $(ALL) | rev | cut -d' ' -f1 | rev               \
		        | cut -d. -f1,2);                                     \
	        tag="ubuntu-pyenv:$$pyab";                                    \
	        repotag=$$user/ubuntu-pyenv:latest;                           \
	    else                                                              \
                pyab=$$(echo $(version) | cut -d. -f1,2);                     \
	        tag="ubuntu-pyenv:$$pyab";                                    \
	        repotag=$$user/$$tag;                                         \
	    fi;                                                               \
	    id=$$(docker images -q $$tag);                                    \
	    echo "Publishing $$repotag... $$id";                              \
	    docker tag "$$id" "$$repotag";                                    \
	    docker push "$$repotag";                                          \
        fi
