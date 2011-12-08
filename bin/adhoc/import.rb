#!/usr/bin/env ruby
#
# usage: import.rb data_file

require 'csv'
require File.join(File.dirname(__FILE__) , '../../config/environment')
require 'code'
require 'work_entry'

env = ENV['RAILS_ENV'] || 'development'
if ARGV[0] == '-e'
  ARGV.shift
  env = ARGV.shift
end

curr_date = nil
CSV.foreach(ARGV[0]) do |row|
  date, code_str, dur, note = *row
  next if date == 'Date' || note == ''
  break if date == 'Project'

  date = curr_date if date == ''
  curr_date = date
  date =~ %r{(\d+)/(\d+)/(\d+)}
  m, d, y = $1.to_i, $2.to_i, $3.to_i
  y += 2000 unless y >= 2000
  date_string = "#{y}-#{'%02d' % m}-#{'%02d' % d}"

  minutes = WorkEntry.duration_as_minutes(dur)

  code = Code.find_by_code(code_str)
  unless code
    $stderr.puts("Code #{code_str} not found; assigning to first code.") if code_str != ''
    $stderr.puts "row = #{row.inspect}" # DEBUG
    code = Code.first
  end
  we = WorkEntry.new(:code => code, :worked_at => date_string, :minutes => minutes, :note => note)
  # we.save
end
