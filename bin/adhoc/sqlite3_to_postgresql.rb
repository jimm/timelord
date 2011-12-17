#!/usr/bin/env ruby

RAILS_ROOT = File.join(File.dirname(__FILE__), '../..')
SQLITE_DB = File.join(RAILS_ROOT, 'db/production.sqlite3')
TABLES = %w(work_entries codes locations)

TABLES.each { |table| puts "DELETE FROM #{table};" }
`echo '.dump' | sqlite3 #{SQLITE_DB}`.each_line do |line|
  next unless line =~ /^INSERT INTO "(\w+)"/ && TABLES.include?($1.downcase)

  line.sub!(/INSERT INTO "(\w+)" VALUES/, 'INSERT INTO \1 VALUES')
  line.sub!(/X'(.*?)'/) {|s| "'" + $1.gsub(/(..)/) {|r| r.to_i(16).chr}.gsub("'", "''") + "'" }
  puts line
end

