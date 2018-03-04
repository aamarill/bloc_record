module BlocRecord
  class Collection < Array

    def initialize
      super
      @condition = ""
    end

    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def where(args)
      key = args.keys.first
      value = args.values.first
      @condition = "#{key} = '#{value}'"
      self
    end

    def destroy_all
      if @condition.empty?
        self.first.class.destroy_all
      else
        self.first.class.destroy_all(@condition)
        @condition = ''
      end

      true
    end
  end
end
