require_relative 'session'

class Logon < Session
    #has_many :billables

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
                #debugger if r.children[0].text.strip == '7/12/2016 12:31 PM'
                interval = s.setDateTimes(r.children[0].text.strip, r.children[1].text.strip)

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

