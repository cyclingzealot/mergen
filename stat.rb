class Stat

    BY_MONTH    = 'monthly'
    BY_DAY      = 'daily'

    attr_reader :type
    attr_reader :dateTime
    attr_reader :value

    class << self
        attr_accessor :data
    end

    def data
        self.class.data
    end
end
