Sequel.migration do

  change do
    alter_table :users do
      add_column :twitter_handle, String, text: true
    end
  end

end
