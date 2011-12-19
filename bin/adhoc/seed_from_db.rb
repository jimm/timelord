#!/usr/bin/env ruby
#
# Reads production.sqlite3 and outputs a seed file.

require File.dirname(__FILE__) + '/../../config/environment'

class String
  def q
    "'" + self.gsub(/'/, "''") + "'"
    end
end

Location.all.each do |loc|
  puts "user = User.find_by_login('admin')"

  puts "loc = Location.create(name: #{loc.name.q})"
  loc.codes.each do |code|
    puts "  code = Code.create(location: loc, code: #{code.code.q}, name: #{code.name.q})"
    code.work_entries.each do |w|
      puts "    WorkEntry.create(user: user, code: code, worked_at: '#{w.worked_at.to_s(:db)}', minutes: #{w.minutes || 0}, rate_cents: #{w.rate_cents || 'nil'}, fee_cents: #{w.fee_cents || 'nil'}, note: #{w.note.q || 'nil'})"
    end
  end
end
