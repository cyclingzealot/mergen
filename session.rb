require 'date'

class Session

    attr_reader :login
    attr_reader :logout
    attr_reader :format

    def initialize(dateTimeFormat)
        @format = dateTimeFormat
        # Logon: "%m/%d/%Y %l:%M %p"
    end


    def setDateTimes(loginStr, logoutStr)
        if loginStr.nil? or logoutStr.nil?
            return false
        end

        begin
            @login =  DateTime.strptime(loginStr, @format)
            @logout = DateTime.strptime(logoutStr, @format)
        rescue ArgumentError
            return false
        end

        return getInterval()
    end

    def getInterval
        return @logout - @login
    end

    def getDate()
        @login.to_date
    end

    def getMonth()
        @login.month
    end

    def getPeriodBegin(periodType)
        case periodType
        when Stat::BY_DAY
            return self.getDate()
        when Stat::BY_MONTH
            return self.getMonth()
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

