# ---------------------------------------------------------------------------
# BOT
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

# Install Ruby, Bundler, and other junk used by the dashboard.
RUN apt-get install -y ruby2.2 ruby2.2-dev ruby-bundler libzmq3-dev git

# Set up the ArchiveBot user.
RUN adduser --disabled-password archivebot --gecos 'ArchiveBot,,,' --ingroup docker_env

# Clone the ArchiveBot code.
RUN sudo -iu archivebot sh -c 'cd $HOME && git clone https://github.com/ArchiveTeam/ArchiveBot'

# Install dependencies.
#
# The current incarnation of the dashboard relies on a few gems-in-git-repos.
# These don't seem to work right when installed at system level, so we install
# them in $HOME.
RUN sudo -iu archivebot sh -c 'cd $HOME/ArchiveBot && bundle install --path=/home/archivebot/bundle'

# Configuration for services.
RUN echo 'tcp://db:6379/0' > /etc/container_environment/REDIS_URL
RUN echo 'tcp://plumbing:13337' > /etc/container_environment/FIREHOSE_SOCKET_URL

# Allow SSH access to the container.
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Start up the dashboard.
RUN mkdir /etc/service/dashboard
COPY dashboard.sh /etc/service/dashboard/run

# The current dashboard is broke-ass and needs to be killed every now and then.
# Here's a process that does that.
# RUN mkdir /etc/service/dashboard-killer
# COPY dashboard-killer.py /usr/local/bin
# COPY dashboard-killer.sh /etc/service/dashboard-killer/run

# The dashboard socket.
EXPOSE 4567

ADD your_key.pub /tmp/your_key.pub
RUN cat /tmp/your_key.pub >> /root/.ssh/authorized_keys && rm -f /tmp/your_key.pub
