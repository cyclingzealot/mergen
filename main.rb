#!/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'pathname'
require 'byebug'
require_relative 'logon'
require_relative 'billable'
require_relative 'session'
require_relative 'stat'

loginHoursPerMonth = []

sessionDataPath = ARGV[0]

debug = ! ARGV[1].nil?

if sessionDataPath.nil?
    puts "You must specify a data path"
    exit 1
end

if ! Dir.exist?(File.expand_path(sessionDataPath))
        puts "#{ARGV[0]} does not seem to be a path to a directory"
        exit 1
end


logonSessions = Logon.readDir(sessionDataPath)

logonSessions.each { |s|
    puts s.getInterval
}

billableSessions = Billable.readDir(sessionDataPath)

period = Stat::BY_MONTH
billedByPeriod = Session.byPeriodTotals(billableSessions, period)
logonByPeriod = Session.byPeriodTotals(logonSessions, period)

debugger if period == Stat::BY_MONTH and debug

billedByPeriod.each { |k,v|
    logonTotal = logonByPeriod[k]

    pctBusy = v / logonTotal * 100

    puts k.to_s + ': ' + '%.1f %% (%.1f / %.1f) ' % [pctBusy, v, logonByPeriod[k]]
}
