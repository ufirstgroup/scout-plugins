class MongoDatabaseStats < Scout::Plugin
  OPTIONS=<<-EOS
    username:
      notes: Leave blank unless you have authentication enabled.
    password:
      notes: Leave blank unless you have authentication enabled.
      attributes: password
    database:
      name: Mongo Database
      notes: Name of the MongoDB database to profile.
    host:
      name: Mongo Server
      notes: Where mongodb is running.
      default: localhost
      attributes: advanced
    port:
      name: Port
      default: 27017
      notes: MongoDB standard port is 27017.
      attributes: advanced
    path_to_db_yml:
      name: Path to database.yml
      notes: "If a database.yml file exists with MongoDB connection information, provide the full path here. This will override other settings if provided."
      attributes: advanced
    rails_env:
      name: Rails Environment
      default: production
      attributes: advanced
      notes: "If a database.yml exists, specify the Rails environment that should be used."
  EOS

  needs 'mongo', 'yaml'

  def build_report 
    # check if database.yml path provided
    if option('path_to_db_yml').nil?
      @db_yml = false
      # check if options provided
      @database = option('database')
      @host     = option('host') 
      @port     = option('port')
      if [@database,@host,@port].compact.size < 3
        return error("Connection settings not provided.", "Either the full path to the MongoDB database file (ie - /var/www/apps/APP_NAME/current/config/database.yml) or the database name, host, and port must be provided in the advanced settings.")
      end
      @username = option('username')
      @password = option('password')
    else
      @db_yml = true
    end
    
    # check if database.yml loads
    if @db_yml
      begin
        yaml = YAML::load_file(option('path_to_db_yml'))
      rescue Errno::ENOENT
        return error("Unable to find the database.yml file", "Could not find a MongoDB config file at: #{option(:path_to_db_yml)}. Please ensure the path is correct.")
      end
      config = yaml[option('rails_env')]
      @host     = config['host']
      @port     = config['port']
      @database = config['database']
      @username = config['username']
      @password = config['password'] 
    end

    begin
      connection = Mongo::Connection.new(@host,@port,:slave_ok=>true)
    rescue Mongo::ConnectionFailure
      return error("Unable to connect to the MongoDB Daemon.","Please ensure it is running on #{@host}:#{@port}\n\nException Message: #{$!.message}")
    end
    
    # Try to connect to the database
    @db = connection.db(@database)
    begin 
      @db.authenticate(@username,@password) unless @username.nil?
    rescue Mongo::AuthenticationError
      return error("Unable to authenticate to MongoDB Database.",$!.message)
    end
    
    get_stats
  end
  
  def get_stats
    stats = @db.stats

    report(:objects      => stats['objects'])
    report(:indexes      => stats['indexes'])
    report(:data_size    => as_mb(stats['dataSize']))
    report(:storage_size => as_mb(stats['storageSize']))
    report(:index_size   => as_mb(stats['indexSize']))
  end
  
  def as_mb(metric)
    metric/(1024*1024).to_f
  end

end