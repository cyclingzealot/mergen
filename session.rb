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
            #In the case of Stat::BY_DAYOFWEEK, we don't want a specific point in univerisal linear time
            #but a reoccuring point in the week.  So we need a string, not a date or date time.
            "#{d.wday} #{d.strftime("%A")}"
        when Stat::BY_HOUROFWEEK
            #In the case of Stat::BY_HOUROFWEEK, we don't want a specific point in univerisal linear time
            #but a reoccuring point in the week.  So we need a string, not a date or date time.
            ### In case session spans multiple hours, we need to return an array
            (@start.hour..@end.hour).map{ |wh| "#{d.wday} #{d.strftime("%A")} #{wh} hrs"}
        else
            debugger
        end

        p = [p] if ! p.is_a?([].class)

        return p
    end


    # Calculate totals for periods of the interval defined by periodType
    def self.byPeriodTotals(sessions, periodType, onlyComplete = FALSE)

        byPeriod = {}

        sessions.each { |s|
            # Skip if this session is deemed incomplete and not determined to be complete
            next if onlyComplete and ! s.complete

            # Determine when the periods beings
            # ie, if it's of type Stat::BY_DAYOFWEEK, 00:00 of the day
	        p = s.getPeriodBegin(periodType)

            # Wrap the period if it's not an array.
            # We use arrays in case the session overlaps two periods
            p = [p] if ! p.is_a?([].class)

            # For each of those periods.....
            p.each_with_index {|pi, i|
    		    total = 0
                # In case we already have non-zero from a previous session,
                # save what we've already stored
    		    total = byPeriod[pi] if ! byPeriod[pi].nil?

                # We will increase the total by ....
                increment = case true
                when p.count == 1
                    # The length of the session if the session only covers one period
                    s.getInterval
                when i == 0
                    # If the first period of many,
                    # the start of the session to the end of the period
                    Stat::calculateStartToNextPeriod(s.start, periodType)
                when i == p.count - 1
                    # If the last period of many,
                    # the start of the period to the end of the session
                    Stat::calculateTailEndOfPeriod(s.end, periodType)
                else
                    # If neither the first or last of many
                    # The entire length of that period
                    Stat::getPeriod(periodType)
                end

                # Increment that total
       		    total += increment

                # Store it again
    		    byPeriod[pi] = total
            }
        }

        byPeriod = Hash[ byPeriod.sort_by { |key, val| key } ]

        return byPeriod
    end

end

