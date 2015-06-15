# This Dockerfile creates three Docker images:
#
# 1. Redis/CouchDB, ArchiveBot's database backend
# 2. The ArchiveBot backend plumbing
# 3. The ArchiveBot dashboard
#
# You will typically build them as follows:
#
# 1. Add your keys via COPY:
#
#    COPY your_key.pub /tmp/your_key.pub
#    RUN cat /tmp/your_key.pub >> $USER/.ssh/authorized_keys && rm -f /tmp/your_key.pub
#    (repeat as necessary)
#
# 2. docker build .
#
# 3. a. docker run -d -p 0.0.0.0:16379:22 --name db $REDIS_IMAGE_ID
#    b. docker run -d --name plumbing --link db:db $PLUMBING_IMAGE_ID
#    c. docker run -d --name bot --link db:db $BOT_IMAGE_ID
#    c. docker run -d -p 0.0.0.0:80:4567 --name dashboard --link db:db \
#       --link plumbing:plumbing $DASHBOARD_IMAGE_ID

# ---------------------------------------------------------------------------
# DATABASE
# ---------------------------------------------------------------------------

FROM phusion/baseimage:0.9.16
MAINTAINER David Yip <yipdw@member.fsf.org>
CMD ["/sbin/my_init"]

# We use Chris Lea's Redis PPA because we have no secrets and I want reasonable
# system updates and oh god I don't want to write a build sequence in Dockerese
RUN add-apt-repository ppa:chris-lea/redis-server
RUN apt-get update

# Install Redis.                                                                              
RUN apt-get install -y redis-server                                                               

# Pipelines hook into Redis over SSH, so we need to turn SSH on.
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Add a user for SSH<->Redis tunneling.
RUN adduser --disabled-password tunnel --gecos 'Tunnel user,,,'

# There already exists a Redis user from the PPA's setup scripts, so we just
# need to start things up as the right user.  (There's also a Redis init
# script, but it's not directly compatible with runit, which is used in
# phusion/baseimage.)
RUN mkdir /etc/service/redis
COPY redis.sh /etc/service/redis/run

# Install CouchDB, which is on a really slow guillotine.
RUN apt-get install -y couchdb
RUN mkdir /var/run/couchdb
RUN chown couchdb:couchdb /var/run/couchdb
RUN mkdir /etc/service/couchdb
COPY couchdb.sh /etc/service/couchdb/run

# Make Redis and CouchDB listen on 0.0.0.0 for other ArchiveBot containers.
RUN apt-get install -y patch
COPY redis_conf.patch /tmp/redis_conf.patch
COPY couchdb_listen_all_interfaces.patch /tmp/couchdb_listen_all_interfaces.patch
RUN patch -p0 /etc/redis/redis.conf /tmp/redis_conf.patch
RUN patch -p0 /etc/couchdb/local.ini /tmp/couchdb_listen_all_interfaces.patch

EXPOSE 22
EXPOSE 6379
EXPOSE 5984

# Clean up apt-get.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD your_key.pub /tmp/your_key.pub
RUN cat /tmp/your_key.pub >> /root/.ssh/authorized_keys && rm -f /tmp/your_key.pub
