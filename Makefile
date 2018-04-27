RPM_RELEASE=0
GIT_REV=`git rev-parse --short HEAD`

all: clean build

clean:
	rm -rf ./RPMS/*rpm
	mkdir -p ./RPMS

build:
	docker build . -t 'collectd-builder-rhel7:latest' --build-arg RPM_RELEASE=$(RPM_RELEASE) --build-arg RPM_EXTRAVER=$(GIT_REV)
	docker run -it --rm -v ${PWD}/RPMS:/RPMS collectd-builder-rhel7:latest
	ls ./RPMS

shell:
	docker run -it --rm collectd-builder-rhel7:latest /bin/bash

