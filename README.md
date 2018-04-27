# collectd-builder
A ephermeral build environment for producing collectd RPMs for CentOS/RHEL 7, set up to build 5.8.0 with almost every collectd plugin possible

# what it does
It uses Docker to build a temporary CentOS 7 environment with all the requirements for collectd, then a Docker Run does an rpmbuild and copies the new RPMs to your host.

# building
`make` should do all the steps necessecary

# troubleshooting
* if the *Docker Build* stage fails you will to debug the build from the console log
* if the *Docker Run* stage fails to rpmbuild then you can jump into the build environment to debug with `make shell`
