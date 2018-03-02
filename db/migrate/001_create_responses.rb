Sequel.migration do
  change do
    create_table(:responses) do
      primary_key :id, unique: true
      String :name, null: false
      String :response, null: false
      String :question
    end
  end
end