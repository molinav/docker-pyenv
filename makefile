ALL = $(shell echo "2.6 2.7 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9")


build:

	@if [ "$(python)" = "all" ]; then                                     \
	    for v in $(ALL); do                                               \
	        make build python="$$v";                                      \
	    done                                                              \
	else                                                                  \
	    distro="$(shell echo $(base)                                      \
	              | sed 's|\(opensuse\)/leap|\1|'                         \
	              | sed 's|:|-|')";                                       \
	    tag="pyenv:$(python)-$$distro";                                   \
	    echo "Building $$tag...";                                         \
	    docker build --tag "$$tag" .                                      \
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
	    distro="$(shell echo $(base)                                      \
	              | sed 's|\(opensuse\)/leap|\1|'                         \
	              | sed 's|:|-|')";                                       \
	    if [ "$(python)" = "latest" ]; then                               \
	        latest="$(shell echo $(ALL) | rev | cut -d' ' -f1 | rev)";    \
	        tag="pyenv:$$latest-$$distro";                                \
	        repotag=$$user/pyenv:latest-$$distro;                         \
	    else                                                              \
	        tag="pyenv:$(python)-$$distro";                               \
	        repotag=$$user/$$tag;                                         \
	    fi;                                                               \
	    id=$$(docker images -q $$tag);                                    \
	    echo "Publishing $$repotag... $$id";                              \
	    docker tag "$$id" "$$repotag";                                    \
	    docker push "$$repotag";                                          \
	fi
