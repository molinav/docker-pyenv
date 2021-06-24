ALL = $(shell echo "2.6.9 2.7.18 3.2.6 3.3.7 3.4.10                           \
                    3.5.10 3.6.13 3.7.10 3.8.10 3.9.5")


build:

	@if [ "$(python)" = "all" ]; then                                     \
            for v in $(ALL); do                                               \
                make build python="$$v";                                      \
            done                                                              \
	else                                                                  \
            pyab=$(shell echo $(python) | cut -d. -f1,2);                     \
	    tag="$(shell echo $(base) | cut -d: -f1)-pyenv:$$pyab";           \
	    echo "Building $$tag...";                                         \
            docker build -q --tag "$$tag" .                                   \
	        --build-arg BASE_IMAGE="$(base)"                              \
	        --build-arg PYTHON_VERSION="$(python)";                       \
        fi


publish:

	@if [ "$(python)" = "all" ]; then                                     \
            for v in $(ALL); do                                               \
                make publish python="$$v";                                    \
            done;                                                             \
	    make publish python=latest;                                       \
	else                                                                  \
	    user=$$(docker info 2>/dev/null | sed -n '/[ ]*Username:/p'       \
	            | rev | cut -d' ' -f1 | rev);                             \
	    if [ "$(python)" = "latest" ]; then                               \
                pyab=$$(echo $(ALL) | rev | cut -d' ' -f1 | rev               \
		        | cut -d. -f1,2);                                     \
	        tag="ubuntu-pyenv:$$pyab";                                    \
	        repotag=$$user/ubuntu-pyenv:latest;                           \
	    else                                                              \
                pyab=$$(echo $(python) | cut -d. -f1,2);                      \
	        tag="ubuntu-pyenv:$$pyab";                                    \
	        repotag=$$user/$$tag;                                         \
	    fi;                                                               \
	    id=$$(docker images -q $$tag);                                    \
	    echo "Publishing $$repotag... $$id";                              \
	    docker tag "$$id" "$$repotag";                                    \
	    docker push "$$repotag";                                          \
        fi
