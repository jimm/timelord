#!/usr/bin/env ruby
#!/bin/bash

DUMPFILE = '/tmp/production.dump.sql'
DB = File.join(File.dirname(__FILE__), '../../db/production.sqlite3')

File.open(DUMPFILE, 'w') do |f|
  %w(work_entries codes locations).each { |table| f.puts "DELETE FROM #{table};" }
  `echo '.dump' | sqlite3 #{DB}`.each_line do |line|
    next unless line =~ /^INSERT INTO/
    next if line =~ /INSERT INTO "(schema_migrations|sqlite_sequence)"/

    line.sub!(/INSERT INTO "(\w+)" VALUES/, 'INSERT INTO \1 VALUES')
    line.sub!(/X'(.*?)'/) {|s| "'" + $1.gsub(/(..)/) {|r| r.to_i(16).chr}.gsub("'", "''") + "'" }
    f.puts line
  end
end

system("echo '\\\\i #{DUMPFILE}' | psql -Ujimm timelord_development")
