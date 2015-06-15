# ---------------------------------------------------------------------------
# BOT
# ---------------------------------------------------------------------------

FROM phusion/baseimage:0.9.16
MAINTAINER David Yip <yipdw@member.fsf.org>
CMD ["/sbin/my_init"]

# We use Brightbox's Ruby PPA because we have no secrets and I want reasonable
# system updates and oh god I don't want to write a build sequence in Dockerese
RUN add-apt-repository ppa:brightbox/ruby-ng

RUN apt-get update

# Install Ruby, Bundler, and other junk used by the bot.
RUN apt-get install -y ruby2.2 ruby2.2-dev ruby-bundler libzmq3-dev git

# Set up the ArchiveBot user.
RUN adduser --disabled-password archivebot --gecos 'ArchiveBot,,,' --ingroup docker_env

# Clone the ArchiveBot code.
RUN sudo -iu archivebot sh -c 'cd $HOME && git clone https://github.com/ArchiveTeam/ArchiveBot'

# Install dependencies.
#
# The current incarnation of the bot (and dashboard) rely on a few
# gems-in-git-repos.  These don't seem to work right when installed at system
# level, so we install them in $HOME.
RUN sudo -iu archivebot sh -c 'cd $HOME/ArchiveBot && bundle install --path=/home/archivebot/bundle'

# Configuration for services.
RUN echo 'tcp://db:6379/0' > /etc/container_environment/REDIS_URL
RUN echo 'http://db:5984/archivebot' > /etc/container_environment/COUCHDB_URL

# Allow SSH access to the container.
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

ADD your_key.pub /tmp/your_key.pub
RUN cat /tmp/your_key.pub >> /root/.ssh/authorized_keys && rm -f /tmp/your_key.pub
