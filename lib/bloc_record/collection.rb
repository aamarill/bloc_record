module BlocRecord
  class Collection < Array

    def initialize
      super
      @attributes = {}
    end

    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def where(args = nil)
      if args
        key = args.keys.to_s
        value = args.values
        @attributes[key] = value
      end

      self
    end

    def take(attributes = @attributes)
      output = []

      if attributes.length > 0
        self.each do |element|
          output << element.class.where(attributes)
        end
      else
        self.each do |element|
          output << element.class.take
        end
      end

      @attributes = {}
      output
    end

    def not(attributes = @attributes)
      output = []

      if attributes.length > 0
        self.each do |element|
          output << element.class.not(attributes)
        end
      else
        self.each do |element|
          output << element.class.take
        end
      end

      @attributes = {}
      output
    end
  end
end
