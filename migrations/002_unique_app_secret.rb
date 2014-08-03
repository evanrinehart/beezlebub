Sequel.migration do

  def change
    add_index :apps, :secret, :unique => true
  end

end
