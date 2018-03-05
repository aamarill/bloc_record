require 'sqlite3'

module Connection
  def connection
    if BlocRecord.platform == 'sqlite'
      @connection ||= SQLite3::Database.new(BlocRecord.database_filename)
    elsif BlocRecord.platform == 'pq'
      # Look up what the sytnax is for this
      @connection ||= #POSTGRES???.new(BlocRecord.database_filename)
    end
  end
end
