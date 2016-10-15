require_relative 'session'

class Logon < Session

    def initialize()
        super("%m/%d/%Y %l:%M %p")
    end

    def self.readDir(path)
        if ! Dir.exist?(File.expand_path(path))
            return nil
        end

        returnArray = []
        Dir[File.expand_path(path) + '/*.html'].each { |f|
            doc = Nokogiri::HTML(File.expand_path(File.read(f)))

            rows = doc.xpath('//tr')

            rows.each { |r|
                s = Logon.new
                interval = s.setDateTimes(r.children[0], r.children[1])

                if interval === FALSE
                    next
                else
                    returnArray.push(s)
                end
            }

        }

        return returnArray
    end

    # Deperecated
    def self.associateBillableToLogon(logons, billables)
        logons.each { |l|
            billables.each{ |b|
                if b.start > l.start and b.end < l.end
                end
            }
        }
    end

end

