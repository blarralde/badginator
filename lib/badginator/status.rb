class Badginator
  class Status
    attr_reader :code, :badge

    def initialize(args = {})
      @code = args[:code]
      @badge = args[:badge]
    end
  end
end
