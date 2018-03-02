module BlocRecord
   class Collection < Array
     def update_all(updates)
       ids = self.map(&:id)
       self.any? ? self.first.class.update(ids, updates) : false
     end
   end

    # Question #4
    # Create instance variables to allow for method chaining
    User.where(age: 20).destroy_all
 end
