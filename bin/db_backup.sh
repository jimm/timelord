#!/bin/bash

d=production.sqlite3
dest_dir=/Users/jimm/Documents/Dropbox/backups

# Keep two older backups
if [ -f $dest_dir/timelord.1.$d ] ; then
    mv $dest_dir/timelord.1.$d $dest_dir/timelord.2.$d
fi
if [ -f $dest_dir/timelord.$d ] ; then
    mv $dest_dir/timelord.$d $dest_dir/timelord.1.$d
fi

cp $(dirname $0)/../db/$d $dest_dir/timelord.$d
