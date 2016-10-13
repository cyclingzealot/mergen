class Session

    attr_reader :login
    attr_reader :logout

    def initialize()

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
                s = Session.new
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

    def setDateTimes(loginStr, logoutStr)
        if loginStr.nil? or logoutStr.nil?
            return false
        end

        begin
            format = "%m/%d/%Y %l:%M %p"
            @login =  DateTime.strptime(loginStr, format)
            @logout = DateTime.strptime(logoutStr, format)
        rescue ArgumentError
            return false
        end

        return getInterval()
    end

    def getInterval
        return @logout - @login
    end

    def getMonth()
        @login.month
    end

end

