require 'singleton'
require "badginator/version"
require 'badginator/active_model'
require "badginator/badge"
require 'badginator/trigger'
require "badginator/status"
require "badginator/nominee"
require 'badginator/controller_extension'

class Badginator
  include Singleton

  DID_NOT_WIN = 1
  WON         = 2
  ALREADY_WON = 3
  ERROR       = 4
  LOST        = 5

  def initialize
    @badges = {}
    @triggers = {}
  end

  def get_badge(badge_code)
    @badges.fetch(badge_code)
  end

  def badges
    @badges.values.select { |badge| ! badge.disabled }
   end

  def self.badges
    self.instance.badges
  end

  def define_badge(*args, &block)
    badge = Badge.new
    badge.build &block
    badge.freeze

    if @badges.key?(badge.code)
      raise "badge code '#{badge.code}' already defined."
    end

    @badges[badge.code] = badge
  end

  def self.define_badge(*args, &block)
    self.instance.define_badge(*args, &block)
  end

  def self.get_badge(badge_code)
    self.instance.get_badge(badge_code)
  end

  def triggers
    @triggers
  end

  def self.triggers
    self.instance.triggers
  end

  def define_trigger(*args, &block)
    trigger = Trigger.new
    trigger.build &block
    trigger.freeze

    if @triggers.key? trigger.trigger
      raise "trigger '#{trigger.trigger}' already defined."
    end

    @triggers[trigger.trigger] = trigger
  end

  def self.status(status_code, badge = nil)
    case status_code
      when DID_NOT_WIN, WON, ALREADY_WON, LOST, ERROR
        Badginator::Status.new code: status_code, badge: badge
      else
        rails TypeError, "Cannot convert #{status_code} to Status"
    end
  end

  class Engine < Rails::Engine
    initializer 'badginator.controller' do |app|
      ActiveSupport.on_load(:action_controller) do
        begin
          # Load app rules on boot up
          # Merit::AppBadgeRules = Merit::BadgeRules.new.defined_rules
          # Merit::AppPointRules = Merit::PointRules.new.defined_rules
          include Badginator::ControllerExtensions
        rescue NameError => e
          # Trap NameError if installing/generating files
          raise e
        end
      end
    end
end
