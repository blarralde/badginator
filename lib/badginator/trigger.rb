class Badginator
  class Trigger < ActiveModel

    def self.find_all trigger
      ::Badginator.triggers.map{|t| t.fetch trigger }.compact
    end

    setters :action, :trigger, :background, :badge_code, :points

    #
    # trigger: controller#action(bg task) / manual / cron
  end
end
