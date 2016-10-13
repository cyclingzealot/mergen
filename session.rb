class Session

    attr_reader :login
    attr_reader :logout

    def initialize()

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

