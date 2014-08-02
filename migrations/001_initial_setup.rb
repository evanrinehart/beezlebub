Sequel.migration do

  change do
    create_table :events do
      primary_key :id
      String :name, :null => false, :size => 255
      text :payload, :null => false
      integer :app_id, :null => false
      integer :version, :null => false
      timestamp :created_at, :null => false, :default => :now.sql_function
    end

    create_table :subscriptions do
      primary_key :id
      integer :app_id, :null => false
      String :event_name, :null => false, :size => 255
      text :push_uri, :null => false
      text :note, :null => false
      timestamp :created_at, :null => false, :default => :now.sql_function

      index [:app_id, :event_name], :unique => true
    end

    create_table :messages do
      primary_key :id
      integer :event_id, :null => false
      integer :subscription_id, :null => false
      text :failure
      String :status, :null => false, :size => 255
      timestamp :created_at, :null => false, :default => :now.sql_function
      timestamp :delivered_at
      timestamp :retry_at
    end

    create_table :apps do
      primary_key :id
      String :name, :null => false, :size => 255
      String :secret, :null => false, :size => 255
      timestamp :created_at, :null => false, :default => :now.sql_function

      index :name, :unique => true
    end

    
  end

end
