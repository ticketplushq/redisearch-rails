# Redisearch-rails

Adds support for easily indexing and search ActiveRecord models using RediSearch module http://redisearch.io/

# Getting started

First you need a Redisearch Service running, please follow [Quick Start](https://oss.redislabs.com/redisearch/Quick_Start.html) documentation.

Redisearch-rails is compatible with Rails `~> 4.2` on Ruby `2.3` and later.

In your Gemfile, for the last officially released gem:

```ruby
gem 'redisearch-rails'
```

And then execute:

```bash
$ bundle install
```

Once the gem installed you will need to add the configuration to cannect to redisearch.

Go to your initializers (`config/initializers`), add a new file and call it `redisearch.rb`

```ruby
RediSearch.configure do |config|
  config.redis_config = {
    host: '127.0.0.1',
    port: '6379',
    db: 0, # this has to be 0
#   password: 'some password' #(optional)
  }
end
```


## Usage

To integrate Redisearch for Rails only you need to call `redisearch` method defining the Redisearch `schema` inside of your ActiveRecord Model.

```ruby
class User < ActiveRecord::Base
  redisearch schema: {
    first_name: { text: { phonetic: "dm:es" } },
    last_name: { text: { phonetic: "dm:es" } },
    email: :text,
    age: :numeric
  }
end
```

This will add the `reindex` and `rediseach` class methods.

Now you can index all the recods, using `User.reindex` and search using `redisearch` method with [RediSearch Query Syntax](https://oss.redislabs.com/redisearch/Query_Syntax.html).

```ruby
irb(main):004:0> User.redisearch('@first_name:(Jon|Jane) @last_name:"Doe"')
  User Load (0.5ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` IN (2, 1)
=> [#<User id: 1, email: "jon@test.com", first_name: "Jon", last_name: "Doe", created_at: "2020-1-06 19:21:36", updated_at: "2020-1-06 19:24:43", age: 15>, #<User id: 2, email: "Jane@other.com", first_name: "Jane", last_name: "Doe", created_at: "2020-1-06 22:19:00", updated_at: "2020-1-06 22:19:00", age: 20>]
```


## Indexing
Each Model with defined `redisearch` is a **Redisearch Index** representation, and an instantiated Object its a **Redisearch Document** where the ID attribute of the instance is the ID of the Document.

By default, `reindex` will use `all` scope for find, you can change overwriting the scope

```ruby
class User < ActiveRecord::Base
  scope :redisearch_import, -> { where(email: 'some@email.com') }
end
```

If you need to recreate the Index, you can use `recreate: true` option on `reindex`

```ruby
irb(main):004:0> User.reindex(recreate: true)
=> nil
```

this will drop the **Index** with all the **Documents** and start to reindexing.

### Custom Attributes
You can use Custom attributes defining a method or attr_accessor.

```ruby
# == Schema Information
#
# Table name: users
#  first_name             :string(255)
#  last_name              :string(255)
#  email                  :string(255)      default(""), not null
#  company_id             :integer
#
class User < ActiveRecord::Base
  redisearch schema: {
    full_name: { text: { phonetic: "dm:es" } },
    company_name: :text
  }

  belongs_to :company

  scope :redisearch_import, -> { all.includes(:company) }

  after_commit :redisearch_add, on: [ :create, :update ]
  after_commit :redisearch_delete, on: :destroy

  def company_name
    company.name
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def redisearch_add
    redisearch_document.add(replace: true, partial: true)
  end

  def redisearch_delete
    redisearch_document.del(dd: true)
  end

end
```

You can add a Serializer to the indexer like this

```ruby
# == Schema Information
#
# Table name: company
#  name             :string(255)
#
class Company < ActiveRecord::Base
  redisearch schema: {
    name: { :text },
    users_ids: :tag # Array
  }, index_serializer: Company::RedisearchSerlializer
  has_many :users

  scope :redisearch_import, -> { includes(:users) }
end

class Company::RedisearchSerlializer
  attr_reader :company

  def initialize(company)
    @company = company
  end

  def users_ids
    company.users.ids #Array of ids
  end
end
```




## Search

Simply use the `redisearch` method with a [RediSearch Query Syntax](https://oss.redislabs.com/redisearch/Query_Syntax.html).

This ask to Redisearch the Documents ids and then use ActiveRecord find method to brings the elements.

## TODOs

* ActiveModel callbacks to index records on saving and remove from Redis on delete
* More Configurations like batch size when reindexing
* Support GEO filters
* Stopwords configuration
* Configurable doc_id reference, for now use ID and find method to search
* Test coverage and better documentation
* Multiple redisearch indexes for the same model

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Ticketplus/redisearch-rails. This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
