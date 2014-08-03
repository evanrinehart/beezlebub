Sequel.migration do

  change do
    alter_table :apps do
      #add_index :secret, :unique => true
    end
  end

end
