#!/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'pathname'
require 'byebug'
require_relative 'logon'
require_relative 'billable'
require_relative 'session'
require_relative 'stat'
require_relative 'weekCalendar'

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

[Stat::BY_DAYOFWEEK, Stat::BY_HOUROFWEEK].each {|periodType|
    pctBusySessions = {}

	billedByPeriod = Session.byPeriodTotals(billableSessions, periodType, TRUE)
	logonByPeriod = Session.byPeriodTotals(logonSessions, periodType, TRUE)

	billedByPeriod.each { |k,v|
	    logonTotal = logonByPeriod[k]

	    debugger if logonTotal.nil?

	    pctBusy = v / logonTotal * 100

        pctBusySessions[k] = pctBusy

	    puts k.to_s + ': ' + '%.2f %% (%.2f / %.2f) ' % [pctBusy, v, logonTotal]
	}

    pctBusySessions = pctBusySessions.sort_by {|k,v| v}.reverse

    pctBusySessions.each { |k, pctBusy|
        puts k.to_s + ': ' + '%.2f' % pctBusy
    }

    if periodType == Stat::BY_HOUROFWEEK
        require 'money'
        require 'money/bank/google_currency'
        Money::Bank::GoogleCurrency.ttl_in_seconds = 86400
        Money.default_bank = Money::Bank::GoogleCurrency.new
        dollarsPerMin = (Money.new(55, "USD").exchange_to(:CAD).cents.to_f/100)
        lowTarget = 500/dollarsPerMin/60
        midTarget = 1000/dollarsPerMin/60
        highTarget = 1200/dollarsPerMin/60
        wc = WeekCalendar.new(lowTarget, midTarget, highTarget, periodType)
        wc.setTargetValuesForPeriods(pctBusySessions)
        wc.generateData

        filePath = '/tmp/mergen.' + periodType + '.html'
        IO.write(filePath, wc.generateHourOfWeekHTML.to_s)
        $stderr.puts "See #{filePath}.  May want to use firefox #{filePath} & ."
    end
}


