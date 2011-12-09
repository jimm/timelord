#!/bin/bash

d=production.sqlite3

cp $(dirname $0)/../db/$d ~jimm/Documents/Dropbox/backups/timelord.$d
