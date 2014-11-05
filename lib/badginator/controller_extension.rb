class Badginator
  # Sets up an app-wide after_filter, and checks rules if
  # there are defined rules (for badges or points) for current
  # 'controller_path#action_name'
  module ControllerExtension
    def self.included(base)
      base.after_filter do |controller|
        matching_triggers.each do |trigger|
          if trigger.action == :set_badge
            if trigger.background
              BadginatorQueue.perform_async 'try_award_badge', current_user.id, trigger.badge_code
            else
              status = current_user.try_award_badge trigger.badge_code
              if status.code == Badginator::WON
                session[:new_badge] = status.badge
              elsif status.code == Badginator::LOST
                session[:lost_badge] = status.badge
              end
            end
          end
        end
      end
    end

    private
      def controller_action
        "#{controller_path}##{action_name}"
      end

      def matching_triggers
        @matching_triggers ||= ::Badginator::Trigger.find_all controller_action
      end
  end
end