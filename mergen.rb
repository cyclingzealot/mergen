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
billableSessions = Billable.readDir(sessionDataPath, logonSessions)
pctBusySessions = {}

[Stat::BY_DAYOFWEEK, Stat::BY_HOUROFWEEK].each {|period|
	billedByPeriod = Session.byPeriodTotals(billableSessions, period, TRUE)
	logonByPeriod = Session.byPeriodTotals(logonSessions, period, TRUE)

	billedByPeriod.each { |k,v|
	    logonTotal = logonByPeriod[k]

	    debugger if logonTotal.nil?

	    pctBusy = v / logonTotal * 100

        pctBusySessions[k] = pctBusy

	    puts k.to_s + ': ' + '%.2f %% (%.2f / %.2f) ' % [pctBusy, v, logonTotal]
	}

    puts
}

pctBusySessions.sort_by {|k,v| v}.reverse.each { |k, pctBusy|
    puts k.to_s + ': ' + '%.2f' % pctBusy
}
