require 'date'

class Session

    attr_reader :start
    attr_reader :end
    attr_reader :format
    attr_reader :complete

    def initialize(dateTimeFormat)
        @format = dateTimeFormat
        @complete = nil
        # Logon: "%m/%d/%Y %l:%M %p"
    end

    def ==(s)
        @start == s.start and @end == e.end and self.class.name == s.class.name
    end

def setComplete()
    @complete = true
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

    def is_part_of?(periodKey, periodType)
        pb = self.getPeriodBegin(periodType)

        return pb.include?(periodKey)

    end


    def getPeriodBegin(periodType)
        d = self.getDate()
        p = case periodType
        when Stat::BY_DAY
            d
        when Stat::BY_MONTH
            Date.new(d.year, d.month, 1)
        when Stat::BY_DAYOFWEEK
            "#{d.wday} #{d.strftime("%A")}"
        when Stat::BY_HOUROFWEEK
            ### In case session spans multiple hours, we need to return an array
            (@start.hour..@end.hour).map{ |wh| "#{d.wday} #{d.strftime("%A")} #{wh} hrs"}
        else
            debugger
        end

        p = [p] if ! p.is_a?([].class)

        return p
    end

    def self.byPeriodTotals(sessions, periodType, onlyComplete = FALSE)

        byPeriod = {}

        sessions.each { |s|
            next if onlyComplete and ! s.complete

	        p = s.getPeriodBegin(periodType)

            p = [p] if ! p.is_a?([].class)

            p.each_with_index {|pi, i|
    		    total = 0
    		    total = byPeriod[pi] if ! byPeriod[pi].nil?

                increment = case true
                when p.count == 1
                    s.getInterval
                when i == 0
                    Stat::calculateStartToNextPeriod(s.start, periodType)
                when i == p.count - 1
                    Stat::calculateTailEndOfPeriod(s.end, periodType)
                else
                    Stat::getPeriod(periodType)
                end

       		    total += increment

    		    byPeriod[pi] = total
            }
        }

        byPeriod = Hash[ byPeriod.sort_by { |key, val| key } ]

        return byPeriod
    end

end

