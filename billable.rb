require 'csv'

class Billable < Session

    def initialize()
        super("%Y-%m-%d %H:%M:%S")
    end

    def self.readDir(path)
        if ! Dir.exist?(File.expand_path(path))
            return nil
        end

        returnArray = []
        Dir[File.expand_path(path) + '/*.csv'].each { |f|

            CSV.parse(File.read(f)) { |l|
                b = Billable.new

                b.setDateTimes(l[0], l[1])

                returnArray.push(b)
            }

        }

        return returnArray
    end

end

