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
require_relative './config.rb'

lowTargetIncome = 800
medTargetIncome = 1000
highTargetIncome = 1500


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
if logonSessions.count == 0
    $stderr.puts "No logon sessions found in #{sessionDataPath}"
    exit 1
else
    puts "#{logonSessions.count} logon sesions found in #{sessionDataPath}"
end

billableSessions = Billable.readDir(sessionDataPath, logonSessions)
if billableSessions.count == 0
    $stderr.puts "No billable sessions found in #{sessionDataPath}"
    exit 1
else
    puts "#{billableSessions.count} billable sesions found in #{sessionDataPath}"
end

$stderr.puts "Calculating average length session"
avgBillableLengthMins =  Session.calcAverageLength(billableSessions)
stdDevBillableLengthMins = Session.calcStdDev(billableSessions)
length95thPercentileMins = Session.calc95LengthInMins(billableSessions)


{'billable' => billableSessions, 'logons'=>logonSessions}.each {|label, var|
    pctCompleteRatio = (( var.select {|s| s.complete == true}.count ) * 100) / var.count
    puts "#{pctCompleteRatio} % #{label} sessions complete"
}


[Stat::BY_DAYOFWEEK, Stat::BY_HOUROFWEEK].each {|periodType|
    pctBusySessions = {}

	billedByPeriod = Session.byPeriodTotals(billableSessions, periodType, true)
	logonByPeriod = Session.byPeriodTotals(logonSessions, periodType, true)

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
        dollarsPerMin = ($rate_UScentsPerMin.to_f/100 / $usdPerCad)
        begin
            dollarsPerMin = (Money.new($rate_UScentsPerMin, "USD").exchange_to(:CAD).cents.to_f/100)
        rescue SocketError
            $stderr.puts "No net connection, going wth #{dollarsPerMin.round(2)} CAD$/min value"
        end

        lowTargetHours = lowTargetIncome/dollarsPerMin/60
        medTargetHours = medTargetIncome/dollarsPerMin/60
        highTargetHours = highTargetIncome/dollarsPerMin/60
        wc = WeekCalendar.new(lowTargetHours, medTargetHours, highTargetHours, periodType)
        totalHours = wc.setTargetValuesForPeriods(pctBusySessions)
        maxIncome = totalHours * dollarsPerMin * 60
        wc.generateData

        filePath = '/tmp/mergen.' + periodType + '.html'
        IO.write(filePath, wc.generateHTML.to_s + wc.generateSummaryHTML(lowTargetIncome, medTargetIncome, highTargetIncome, maxIncome))
        $stderr.puts "See #{filePath}.  May want to use firefox #{filePath} & ."
    end
}


puts "Average billable length: #{avgBillableLengthMins.round(2)} mins, stdDev = #{stdDevBillableLengthMins}, 95th percentile = #{length95thPercentileMins}"
