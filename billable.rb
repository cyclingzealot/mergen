require 'csv'


class Billable < Session
    attr_reader :logon

    def initialize()
        super("%Y-%m-%d %H:%M:%S")
        @logon = nil
    end

    def setLogon(l)
        @logon = l
    end

    def self.readDir(path, logons)
        if ! Dir.exist?(File.expand_path(path))
            return nil
        end

        returnArray = []
        Dir[File.expand_path(path) + '/*.csv'].each { |f|

            minDateTimeInFile = DateTime.new(2099,01,19,04,14,07)
            maxDateTimeInFile = DateTime.new(1970,01,19,04,14,07)
            CSV.parse(File.read(f)) { |l|
                b = Billable.new

                b.setDateTimes(l[0], l[1])

                minDateTimeInFile  = b.start if b.start < minDateTimeInFile
                maxDateTimeInFile = b.end   if b.end   > maxDateTimeInFile

                returnArray.push(b)
            }

            ### For busy rate completion, we need to make sure logons are "complete", that is, they are
            ### associated with its billables *if there were any*
            ### Every logon that is within the minDateTimeInFile and maxDateTimeInFile is assumed to be complete
            ### A billable must have a logon to be valid, but a logon may not have a billable
            ### and still be complete
            logons.each { |l|
                #if l.start > minDateTimeInFile and l.start < maxDateTimeInFile
                if l.start.year == minDateTimeInFile.year and l.start.month == minDateTimeInFile.month
                    l.setComplete()
                    # else debugger if l.start.month == 7
                end

                returnArray.each { |b|
                    if b.start > l.start and b.end < l.end
                        b.setComplete()
                        b.setLogon(l)
                    end
                }

            }

        }

        return returnArray
    end



end

