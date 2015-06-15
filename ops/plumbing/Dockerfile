# ---------------------------------------------------------------------------
# PLUMBING
# ---------------------------------------------------------------------------

FROM phusion/baseimage:0.9.16
MAINTAINER David Yip <yipdw@member.fsf.org>
CMD ["/sbin/my_init"]

# We use Brightbox's Ruby PPA because we have no secrets and I want reasonable
# system updates and oh god I don't want to write a build sequence in Dockerese
RUN add-apt-repository ppa:brightbox/ruby-ng

# Ditto for ZeroMQ.
RUN add-apt-repository ppa:chris-lea/zeromq
RUN apt-get update

# Install Ruby, Bundler, and other junk used by ArchiveBot's plumbing.
RUN apt-get install -y ruby2.2 ruby2.2-dev ruby-bundler libzmq3-dev git

# Set up the ArchiveBot user.
RUN adduser --disabled-password archivebot --gecos 'ArchiveBot,,,' --ingroup docker_env

# Clone the ArchiveBot code.
RUN cd /home/archivebot && git clone https://github.com/ArchiveTeam/ArchiveBot

# Install dependencies.
RUN cd /home/archivebot/ArchiveBot/plumbing && bundle install

# Configuration for services.
RUN echo 'tcp://db:6379/0' > /etc/container_environment/REDIS_URL
RUN echo 'tcp://0.0.0.0:13337' > /etc/container_environment/FIREHOSE_SOCKET_URL
RUN echo 'updates' > /etc/container_environment/UPDATES_CHANNEL

# Start services.
COPY log-firehose.sh /etc/service/log-firehose/run
COPY trimmer.sh /etc/service/trimmer/run
COPY analyzer.sh /etc/service/analyzer/run
COPY watermarker.sh /etc/service/watermarker/run

# Allow SSH access to the container.
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# The firehose ZeroMQ socket.  Used by the dashboard.
EXPOSE 13337

ADD your_key.pub /tmp/your_key.pub
RUN cat /tmp/your_key.pub >> /root/.ssh/authorized_keys && rm -f /tmp/your_key.pub
