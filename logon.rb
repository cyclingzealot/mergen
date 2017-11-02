require_relative 'session'

class Logon < Session
    #has_many :billables

    def initialize()
        super("%m/%d/%Y %l:%M %p")
    end

    def self.readDir(path)
        expandedPath = File.expand_path(path)
        if ! Dir.exist?(expandedPath)
            $stderr.puts "#{expandedPath} does not exist"
            exit 1
        end

        htmlFiles = Dir[expandedPath + '/*.html']

        if htmlFiles.count == 0
            $stderr.puts "No HTML files in #{expandedPath}"
            exit 1
        end

        returnArray = []
        htmlFiles.each { |f|
            doc = Nokogiri::HTML(File.expand_path(File.read(f)))

            rows = doc.xpath('//tr')

            rows.each { |r|
                s = Logon.new
                #debugger if r.children[0].text.strip == '7/12/2016 12:31 PM'
                startTS = r.children[0].text.strip
                endTS = r.children[1].text.strip

                if endTS.nil? or endTS.empty?
                    $stderr.puts "Skipping logon session starting at #{startTS} because endTS empty or nil"
                    next
                end

                interval = s.setDateTimes(startTS, endTS)

                if interval === false
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

