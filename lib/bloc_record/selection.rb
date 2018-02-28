require 'sqlite3'

module Selection
  def find(*ids)
    unless ids.all? {|id| id.is_a? Integer}
      puts "One or more inputs was not an integer"
      return
    end


    if ids.length == 1
      find_one(ids.first)
    else
      begin
        rows = connection.execute <<-SQL
          SELECT #{columns.join ","} FROM #{table}
          WHERE id IN (#{ids.join(",")});
        SQL
      rescue
        puts "SQL query failed"
        return
      end

      rows_to_array(rows)
    end
  end

  def find_one(id)
    unless id.is_a? Integer
      puts "Input must be a single integer"
      return
    end

    begin
      row = connection.get_first_row <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id = #{id};
      SQL
    rescue
      puts "SQL query failed"
      return
    end

    init_object_from_row(row)
  end

  def find_by(attribute, value)

    unless columns.include? attribute
      puts "Column entered does not exist on table"
      return
    end

    begin
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
      SQL
    rescue
      puts "SQL query failed"
      return
    end

    rows_to_array(rows)
  end

  def take(num=1)
    if !num.is_a? Integer
      puts "Input must be an integer"
      return
    end

    if num > 1
      begin
        rows = connection.execute <<-SQL
          SELECT #{columns.join ","} FROM #{table}
          ORDER BY random()
          LIMIT #{num};
        SQL
      rescue
        puts "SQL query failed"
      end

      rows_to_array(rows)
    else
      take_one
    end
  end

  def take_one
    begin
      row = connection.get_first_row <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY random()
        LIMIT 1;
      SQL
    rescue
      "SQL query failed"
      return
    end

    init_object_from_row(row)
  end

  def first
    begin
      row = connection.get_first_row <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY id ASC LIMIT 1;
      SQL
    rescue
      puts "SQL query failed"
      return
    end

    init_object_from_row(row)
  end

  def last
    begin
      row = connection.get_first_row <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY id DESC LIMIT 1;
      SQL
    rescue
      puts "SQL query failed"
      return
    end

    init_object_from_row(row)
  end

  def all
    begin
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table};
      SQL
    rescue
      puts "SQL query failed"
      return
    end

    rows_to_array(rows)
  end

  def method_missing(method_name, *arguments, &block)
    if /^find_by/.match(method_name)
      attribute = method_name.tr('find_by_','')
      value = arguments[0]
      find_by(attribute, value)
    else
      raise NoMethodError
    end
  end

  def find_each(start=1, batch_size=nil)

    if batch_size == nil
      records = connection.execute(<<-SQL)
        SELECT #{columns.join ","} FROM #{table}
        OFFSET start;
      SQL
    else
      records = connection.execute(<<-SQL)
        SELECT #{columns.join ","} FROM #{table}
        LIMIT batch_size
        OFFSET start;
      SQL
    end

    for records.each do |record|
      yield(record)
    end
  end

  def find_in_batches(start=1, batch_size=nil)
    if batch_size == nil
      records = connection.execute(<<-SQL)
        SELECT #{columns.join ","} FROM #{table}
        OFFSET start;
      SQL
    else
      records = connection.execute(<<-SQL)
        SELECT #{columns.join ","} FROM #{table}
        LIMIT batch_size
        OFFSET start;
      SQL
    end

    yield(records)
  end

  private
  def init_object_from_row(row)
    if row
      data = Hash[columns.zip(row)]
      new(data)
    end
  end

  def rows_to_array(rows)
    rows.map { |row| new(Hash[columns.zip(row)]) }
  end
end
