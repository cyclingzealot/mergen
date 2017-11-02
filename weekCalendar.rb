require 'builder'

class WeekCalendar

attr_reader :periodsTargetValues
attr_reader :lowTarget
attr_reader :medTarget
attr_reader :highTarget
attr_reader :periodType
attr_reader :calendarData
attr_reader :pctBusySessions

# To identify what hours billed target the period is part of
LOW = 'low'
MED = 'med'
HIGH = 'high'
EXTRA = 'extra'

# Colours to identify the targets
# Low is red, because that's the most important time to work
COLOURS = {
    self::LOW => '#FF0000',
    self::MED    => '#FFFF00',
    self::HIGH    => '#00FF00',
    self::EXTRA    => '#FFFFFF',
}



# Initialize the weekley calendar with low, med and high hours billed targets
def initialize(low, med, high, periodType)
    @lowTarget = low
    @medTarget = med
    @highTarget = high
    @periodType = periodType
    @periodsTargetValues = {}
    @calendarData = {}
    @pctBusySessions = {}
end

def setTargetValuesForPeriods(pctBusySessions)
    periodLengthMins = case @periodType
        when Stat::BY_HOUROFWEEK
            60
        when Stat::BY_DAYOFWEEK
            60*24
        else
            debugger
        end

    # Althouygh I do this in mergen.rb, do it twice just to be on safe side
    pctBusySessions = pctBusySessions.sort_by {|k,v| v}.reverse

    totalHoursLogged = 0.to_f
    pctBusySessions.each { |k,v|
        (weekday, weekdayHour) = k.split(' ')[1,2]
        weekdayHour = weekdayHour.to_i
        @pctBusySessions[weekdayHour] = Hash.new if @pctBusySessions[weekdayHour].nil?
        @pctBusySessions[weekdayHour][weekday] = v

        @periodsTargetValues[k] = case
            when  totalHoursLogged < @lowTarget
                WeekCalendar::LOW
            when  totalHoursLogged < @medTarget
                WeekCalendar::MED
            when  totalHoursLogged < @highTarget
                WeekCalendar::HIGH
            else
                WeekCalendar::EXTRA
            end

        #debugger
        totalHoursLogged += (v/100*periodLengthMins/60).to_f
    }

    return totalHoursLogged
end

def generateData()
    case @periodType
    when Stat::BY_HOUROFWEEK
        generateHourOfWeekData
    end
end

def generateHourOfWeekData()
    @periodsTargetValues.each{ |k,v|
        (weekday, weekdayHour) = k.split(' ')[1,2]
        weekdayHour = weekdayHour.to_i
        if @calendarData[weekdayHour].nil?
            @calendarData[weekdayHour] = {}
        end
        @calendarData[weekdayHour][weekday] = v
    }
end

def generateSummaryHTML(lowTargetIncome, medTargetIncome, highTargetIncome, maxIncome)
    htmlStr = ''
    table = {
        WeekCalendar::COLOURS[WeekCalendar::LOW] => lowTargetIncome,
        WeekCalendar::COLOURS[WeekCalendar::MED]    => medTargetIncome,
        WeekCalendar::COLOURS[WeekCalendar::HIGH]    => highTargetIncome,
        WeekCalendar::COLOURS[WeekCalendar::EXTRA]    => maxIncome,
    }
    htmlStr = "Work these periods to generate:"
    htmlStr += '<table><tr>'
    table.each {|bgcolour, target|
        htmlStr += %Q[<td bgcolor=#{bgcolour}>#{target.to_f.round(2)} CAD$</td>]
    }
    htmlStr += '</tr></table>'

    return htmlStr


end

def generateHTML()
    returnHTML = case @periodType
    when Stat::BY_HOUROFWEEK
        generateHourOfWeekHTML
    end

    returnHTML.to_s
end

def generateHourOfWeekHTML
    columns = ['Hours', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    #Fancier way to use another time perhaps?
    #How do we insert that extra column for the hours?
    xm = Builder::XmlMarkup.new(:indent => 4)
    xm.table(:border => 1) {

        xm.tr {
            columns.each { |header|
                xm.th(header)
            }
        }
        [*0..23].each { |hour|
            xm.tr {
                text = ''

                if not @calendarData[hour].nil?
                    #debugger
                    columns.each {|dayOfWeek|
                        text = ''
                        if not @calendarData[hour][dayOfWeek].nil?
                            colour = @calendarData[hour][dayOfWeek]
                            text = @pctBusySessions[hour][dayOfWeek].to_f.round.to_s + " %" if (not @pctBusySessions[hour].nil?) and (not @pctBusySessions[hour][dayOfWeek].nil?)
                        elsif dayOfWeek == 'Hours'
                            text = hour
                        end
                        #debugger
                        xm.td(text, :bgcolor => (WeekCalendar::COLOURS[colour]))
                     }

                 end
              }
         }
     }

    return xm


#    htmlStr = '<table>'
#
#    [-1..23].each {|hour|
#        htmlStr += '<tr>'
#        if(hour) =
#        [-1..6].each {|dayOfWeek|
#
#        }
#        htmlStr += '</tr>'
#    }
#
#    htmlStr += '</table>'

end

end
