require 'date'

class Session

    attr_reader :start
    attr_reader :end
    attr_reader :format

    def initialize(dateTimeFormat)
    @format = dateTimeFormat
    # Logon: "%m/%d/%Y %l:%M %p"
end


def setDateTimes(startStr, endStr)
    if startStr.nil? or endStr.nil?
        return false
    end

    begin
        @start =  DateTime.strptime(startStr, @format)
        @end = DateTime.strptime(endStr, @format)
    rescue ArgumentError
        return false
    end

    return getInterval()
end

def getInterval
    return @end - @start
end

def getDate()
    @start.to_date
end

def getMonth()
    @start.month
    end

    def getPeriodBegin(periodType)
        d = self.getDate()
        case periodType
        when Stat::BY_DAY
            return d
        when Stat::BY_MONTH
            return Date.new(d.year, d.month, 1)
        when Stat::BY_DAYOFWEEK
            return d.wday
        when Stat::BY_HOUROFWEEK
        else
            debugger
        end
    end

    def self.byPeriodTotals(sessions, periodType)

        byPeriod = {}

        sessions.each { |s|
	        p = s.getPeriodBegin(periodType)

		    total = 0
		    total = byPeriod[p] if ! byPeriod[p].nil?

		    total += s.getInterval

		    byPeriod[p] = total
        }

        byPeriod = Hash[ byPeriod.sort_by { |key, val| key } ]

        return byPeriod
    end

end

