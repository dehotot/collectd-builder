FROM centos:7 AS builder

# collectd-builder-rhel7
#
# build collectd and all possible plugins for RHEL7

MAINTAINER Alex White (alex.white@diamond.ac.uk)


# set build variables
ENV COLLECTD_VERSION=5.8.0
ENV PMU_TOOLS_COMMIT=1113be9646dc8936f0646c4450b4b216f5975d3b
ENV INTEL_CMT_CAT_COMMIT=66388919c9cd7c1289842186823c954168b2cf59

# get 'RPM_RELEASE' and 'RPM_EXTRAVER' from docker --build-args
ARG RPM_RELEASE=0
ARG RPM_EXTRAVER=


###############################################################################
#
# Docker Build phase: install requirements from centos and epel
#
###############################################################################
RUN yum -y update && yum install -y epel-release

RUN yum -y update && yum install -y \
	gcc        \
	gcc-c++    \
	bzip2      \
	git        \
	make       \
	which      \
	rpm-build  \
	dpdk-devel                \
	ganglia-devel             \
	gpsd-devel                \
	hiredis-devel             \
	iproute-devel             \
	iptables-devel            \
	java-1.8.0-openjdk-devel  \
	libatasmart-devel         \
	libcap-devel              \
	libcurl-devel             \
	libdbi-devel              \
	libesmtp-devel            \
	libgcrypt-devel           \
	libmemcached-devel        \
	libmicrohttpd-devel       \
	libmnl-devel              \
	libmodbus-devel           \
	liboping-devel            \
	libpcap-devel             \
	librabbitmq-devel         \
	librdkafka-devel          \
	libvirt-devel             \
	libxml2-devel             \
	lm_sensors-devel          \
	lua-devel                 \
	lvm2-devel                \
	mariadb-devel             \
	mongo-c-driver-devel      \
	mosquitto-devel           \
	net-snmp-devel            \
	nut-devel                 \
	OpenIPMI-devel            \
	openldap-devel            \
	perl-ExtUtils-Embed       \
	postgresql-devel          \
	python-devel              \
	riemann-c-client-devel    \
	rrdtool-devel             \
	systemd-devel             \
	varnish-libs-devel        \
	xfsprogs-devel            \
	yajl-devel





###############################################################################
#
# build and install jevents from pmu-tools for intel_pmu plugin
#
###############################################################################

WORKDIR /
RUN git clone https://github.com/andikleen/pmu-tools.git && \
	cd /pmu-tools/jevents && \
	git checkout ${PMU_TOOLS_COMMIT} && \
	make && \
	make install && \
	rm -rf /pmu-tools


###############################################################################
#
# build and install libpqos from Intel CMT CAT for intel_rdt plugin
#
###############################################################################

WORKDIR /
RUN git clone https://github.com/intel/intel-cmt-cat.git && \
	cd /intel-cmt-cat/lib && \
	git checkout ${INTEL_CMT_CAT_COMMIT} && \
	make && \
	make install && \
	rm -rf /intel-cmt-cat


###############################################################################
#
# Docker Run phase: build collectd RPM
#
###############################################################################

VOLUME /RPMS
WORKDIR /
RUN mkdir /root/rpmbuild /root/rpmbuild/SOURCES /root/rpmbuild/SPECS

COPY collectd-${COLLECTD_VERSION}.tar.bz2 /root/rpmbuild/SOURCES/
COPY collectd-${COLLECTD_VERSION}.spec    /root/rpmbuild/SPECS/

ENV RPM_RELEASE=${RPM_RELEASE}
ENV RPM_EXTRAVER=${RPM_EXTRAVER}
CMD rpmbuild -bb \
	--define "rel ${RPM_RELEASE}" \
	--define "extraver ${RPM_EXTRAVER}" \
	--with='debug' \
	--with='aggregation' \
	--with='amqp' \
	--with='apache' \
	--with='apcups' \
	--with='ascent' \
	--with='battery' \
	--with='bind' \
	--with='ceph' \
	--with='cgroups' \
	--with='chrony' \
	--with='conntrack' \
	--with='contextswitch' \
	--with='cpu' \
	--with='cpufreq' \
	--with='cpusleep' \
	--with='csv' \
	--with='curl' \
	--with='curl_json' \
	--with='curl_xml' \
	--with='dbi' \
	--with='df' \
	--with='disk' \
	--with='dns' \
	--with='dpdkevents' \
	--with='dpdkstat' \
	--with='drbd' \
	--with='email' \
	--with='entropy' \
	--with='ethstat' \
	--with='exec' \
	--with='fhcount' \
	--with='filecount' \
	--with='fscache' \
	--with='gmond' \
	--with='gps' \
	--with='hddtemp' \
	--with='hugepages' \
	--with='intel_pmu' \
	--with='intel_rdt' \
	--with='interface' \
	--with='ipc' \
	--with='ipmi' \
	--with='iptables' \
	--with='ipvs' \
	--with='irq' \
	--with='java' \
	--with='load' \
	--with='logfile' \
	--with='log_logstash' \
	--with='lua' \
	--with='lvm' \
	--with='madwifi' \
	--with='match_empty_counter' \
	--with='match_hashed' \
	--with='match_regex' \
	--with='match_timediff' \
	--with='match_value' \
	--with='mbmon' \
	--with='mcelog' \
	--with='md' \
	--with='memcachec' \
	--with='memcached' \
	--with='memory' \
	--with='modbus' \
	--with='mqtt' \
	--with='multimeter' \
	--with='mysql' \
	--with='netlink' \
	--with='network' \
	--with='nfs' \
	--with='nginx' \
	--with='notify_email' \
	--with='notify_nagios' \
	--with='ntpd' \
	--with='numa' \
	--with='nut' \
	--with='olsrd' \
	--with='openldap' \
	--with='openvpn' \
	--with='ovs_events' \
	--with='ovs_stats' \
	--with='perl' \
	--with='pinba' \
	--with='ping' \
	--with='postgresql' \
	--with='powerdns' \
	--with='processes' \
	--with='protocols' \
	--with='python' \
	--with='redis' \
	--with='rrdcached' \
	--with='rrdtool' \
	--with='sensors' \
	--with='serial' \
	--with='smart' \
	--with='snmp' \
	--with='snmp_agent' \
	--with='statsd' \
	--with='swap' \
	--with='synproxy' \
	--with='syslog' \
	--with='table' \
	--with='tail' \
	--with='tail_csv' \
	--with='tcpconns' \
	--with='ted' \
	--with='thermal' \
	--with='threshold' \
	--with='turbostat' \
	--with='unixsock' \
	--with='uptime' \
	--with='users' \
	--with='uuid' \
	--with='varnish' \
	--with='virt' \
	--with='vmem' \
	--with='vserver' \
	--with='wireless' \
	--with='write_graphite' \
	--with='write_http' \
	--with='write_kafka' \
	--with='write_log' \
	--with='write_mongodb' \
	--with='write_prometheus' \
	--with='write_redis' \
	--with='write_riemann' \
	--with='write_sensu' \
	--with='write_tsdb' \
	--with='zfs_arc' \
	--with='zookeeper' \
	--without='apple_sensors' \
	--without='aquaero' \
	--without='barometer' \
	--without='grpc' \
	--without='lpar' \
	--without='mic' \
	--without='netapp' \
	--without='notify-desktop' \
	--without='onewire' \
	--without='oracle' \
	--without='pf' \
	--without='routeros' \
	--without='sigrok' \
	--without='tape' \
	--without='teamspeak2' \
	--without='tokyotyrant' \
	--without='xencpu' \
	--without='xmms' \
	--without='zone' \
	/root/rpmbuild/SPECS/collectd-${COLLECTD_VERSION}.spec && \
cp -r /root/rpmbuild/RPMS/x86_64/*rpm /RPMS/
