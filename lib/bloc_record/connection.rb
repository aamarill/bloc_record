require 'sqlite3'
require 'pg'

module Connection
  def connection
    if BlocRecord.platform == 'sqlite'
      @connection ||= SQLite3::Database.new(BlocRecord.database_filename)
    elsif BlocRecord.platform == 'pg'
      @connection ||= PG.connect(dbname: BlocRecord.database_filename )
    end
  end

  def execute(args)
    if BlocRecord.platform == 'sqlite'
      @connection.execute(args)
    elsif BlocRecord.platform == 'pg'
      @connection.exec(args)
    end
  end
end
