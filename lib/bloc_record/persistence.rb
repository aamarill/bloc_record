require 'sqlite3'
require 'bloc_record/schema'

module Persistence
  def self.included(base)
    base.extend(ClassMethods)
  end

  def save
    self.save! rescue false
  end

  def save!
    unless self.id
      self.id = self.class.create(BlocRecord::Utility.instance_variables_to_hash(self)).id
      BlocRecord::Utility.reload_obj(self)
      return true
    end


    fields = self.class.attributes.map { |col| "#{col}=#{BlocRecord::Utility.sql_strings(self.instance_variable_get("@#{col}"))}" }.join(",")

     self.class.connection.execute <<-SQL
       UPDATE #{self.class.table}
       SET #{fields}
       WHERE id = #{self.id};
     SQL

     true
   end

   def update_attribute(attribute, value)
     self.class.update(self.id, { attribute => value })
   end

   def update_attributes(updates)
     self.class.update(self.id, updates)
   end

  module ClassMethods
    def update_all
      update(nil, updates)
    end

    def create(attrs)
      attrs = BlocRecord::Utility.convert_keys(attrs)
      attrs.delete "id"
      vals = attributes.map { |key| BlocRecord::Utility.sql_strings(attrs[key]) }

      connection.execute <<-SQL
        INSERT INTO #{table} (#{attributes.join ","})
        VALUES (#{vals.join ","});
      SQL

      data = Hash[attributes.zip attrs.values]
      data["id"] = connection.execute("SELECT last_insert_rowid();")[0][0]
      new(data)
    end

    def update(ids, updates)
      updates = BlocRecord::Utility.convert_keys(updates.first)
      updates.delete "id"
      updates_array = updates.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }

      where_clauses = []

      if ids.class == Fixnum
        where_clauses = ["WHERE id = #{ids};"]
      elsif ids.class == Array
        if ids.empty?
          where_clauses = [";"]
        else
          where_clauses = ids.map {|id| "WHERE id = #{id};"}
        end
      else
        where_clauses = [";"]
      end

      where_clauses.each_with_index do |where_clause, i|
        connection.execute <<-SQL
          UPDATE #{table}
          SET #{updates_array[i]} #{where_clause}
        SQL
      end

      true
    end

    def method_missing(method_name, *args, &block)
      attribute = method_name.sub('update_', '')
      args = args.first

      case args
      when String
        value = args
      when Hash
        atribute = args.keys.first
        value = args.values.first
      end

      updates = [{attribute, value}]
      update(self.id, updates)
    end
  end
end
