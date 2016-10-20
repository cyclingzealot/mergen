class Stat

    BY_MONTH    = 'monthly'
    BY_DAY      = 'daily'
    BY_DAYOFWEEK= 'weekday'
    BY_HOUROFWEEK= 'weekdayHour';

    attr_reader :type
    attr_reader :dateTime
    attr_reader :value

    class << self
        attr_accessor :data
    end

    def data
        self.class.data
    end

    def self.calculateStartToNextPeriod(start, periodType)
        case periodType
            when self::BY_HOUROFWEEK
                return DateTime.new(start.year, start.month, start.day, start.hour+1) - start
            else
                debugger
                puts "Uninplmented periodtype"
            end
    end

    def self.calculateTailEndOfPeriod(finish, periodType)
        case periodType
            when self::BY_HOUROFWEEK
                return finish - DateTime.new(finish.year, finish.month, finish.day, finish.hour)
            else
                debugger
                puts "Uninplmented periodtype"
            end
    end

    def self.getPeriod(periodType)
        case periodType
            when self::BY_HOUROFWEEK
                n = DateTime.now
                return DateTime.new(n.year, n.month, n.day, 13) -
                    DateTime.new(n.year, n.month, n.day, 12)
            else
                debugger
                puts "Uninplmented periodtype"
        end
    end
end
