class Badginator
  class Badge < ActiveModel

    def self.find code
      ::Badginator.get_badge code
    end

    setters :code, :name, :description, :condition, :disabled, :level, :image,
      :revokable

    def build(&block)
      super &block
      @code = @code.to_sym if @code
    end
  end
end
