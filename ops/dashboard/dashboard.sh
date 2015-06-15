#!/bin/sh
exec /sbin/setuser archivebot sh -c 'cd /home/archivebot/ArchiveBot/dashboard && ../plumbing/firehose-client | bundle exec ruby app.rb --url http://0.0.0.0:4567'
