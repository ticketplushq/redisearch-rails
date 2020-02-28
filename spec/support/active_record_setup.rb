puts "Testing against version #{ActiveRecord::VERSION::STRING}"

ActiveRecord::Base.configurations = YAML.load_file(File.dirname(__FILE__) + '/database.yml')
ActiveRecord::Base.establish_connection(:sqlite)

def init_db
  ActiveRecord::Base.establish_connection(:sqlite)

  ActiveRecord::Schema.verbose = false
  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.string  :first_name
      t.string  :last_name
      t.string  :email
      t.integer :age

      t.integer :company_id
    end

    create_table :companies do |t|
      t.string :name
    end
  end
end
#
# def clean_db
#   connection = ActiveRecord::Base.connection
#   db_name = connection.current_database
#   ActiveRecord::Base.connection.drop_database(db_name)
# end

RSpec.configure do |config|
  config.before(:each) do
    init_db
  end
end
