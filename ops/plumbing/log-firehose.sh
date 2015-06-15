#!/bin/sh
setuser archivebot sh -c 'cd /home/archivebot/ArchiveBot/plumbing && ./updates-listener | ./log-firehose'
