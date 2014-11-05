class Badginator
  class ActiveModel

    def self.setters(*method_names)
      method_names.each do |name|
        send :define_method, name do |*data|
          if data.length > 0
            instance_variable_set "@#{name}", data.first
          else
            instance_variable_get "@#{name}"
          end

        end
      end
    end

    def build(&block)
      instance_eval &block
    end
  end
end
