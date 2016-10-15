require 'csv'

class Billable < Session

    def initialize()
        super("%Y-%m-%d %H:%M:%S")
    end

    def self.readDir(path, logons)
        if ! Dir.exist?(File.expand_path(path))
            return nil
        end

        returnArray = []
        Dir[File.expand_path(path) + '/*.csv'].each { |f|

            minDateTimeInFile = 0
            maxDateTimeInFile = DateTime.new('2038-01-19 04:14:07')
            CSV.parse(File.read(f)) { |l|
                b = Billable.new

                b.setDateTimes(l[0], l[1])

                returnArray.push(b)
            }

            logons.each { |l|
            }

        }

        return returnArray
    end

end

