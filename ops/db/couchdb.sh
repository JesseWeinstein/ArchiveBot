#!/bin/sh
exec /sbin/setuser couchdb couchdb >> /var/log/couchdb/couchdb.out.log 2>&1
