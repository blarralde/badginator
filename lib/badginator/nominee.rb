class Badginator
  module Nominee

    def self.included(base)
      base.class_eval {
        has_many :badges, class_name: "AwardedBadge", as: :awardee
      }
    end

    def try_award_badge(badge_code, context = {})
      badge = Badginator.get_badge(badge_code)

      success =  if badge.respond_to?(:condition)
        condition.call(self, context)
      else
        true
      end

      revokable = badge.respond_to?(:revokable) and badge.revokable

      if success
        if has_badge? badge_code
          status = Badginator.status(Badginator::ALREADY_WON)
        else
          awarded_badge = AwardedBadge.create! awardee: self, badge_code: badge.code
          status = Badginator.status(Badginator::WON, awarded_badge)
        end
      else
        if revokable and lost_badge = has_badge?(badge_code)
          lost_badge.destroy
          status = Badginator.status(Badginator::LOST, lost_badge)
        else
          status = Badginator.status(Badginator::DID_NOT_WIN)
        end
      end

      status
    end

    def has_badge?(badge_code)
      AwardedBadge.where(badge_code: badge_code, awardee: self).first
    end
  end
end
