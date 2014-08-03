Sequel.migration do

  change do
    add_column(
      :events,
      :content_type,
      String,
      :size => 255,
      :null => false,
      :default => 'application/x-www-form-urlencoded'
    )
  end

end
