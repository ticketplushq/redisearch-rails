require 'spec_helper'

describe RediSearch do
  context "When a index_serializer given" do
    before do
      rebuild_model 'User' do
        belongs_to :company
      end
      rebuild_model 'Company' do
        class RedisearchSerializer
          attr_reader :company

          def initialize(company)
            @company = company
          end

          def users_ids
            company.users.ids #array
          end

          def users_full_names
            company.users.map do |user|
              "#{user.first_name} #{user.last_name}"
            end
          end
        end

        redisearch schema: {
          users_ids: :tag,
          users_full_names: :tag
        }, index_serializer: RedisearchSerializer

        has_many :users

        scope :redisearch_import, -> { includes(:users) }
      end
      company = Company.create(name: 'The Company')
      company.users.create(first_name: 'Jon', last_name: 'Doe')
      company.users.create(first_name: 'Jane', last_name: 'Doe')
      Company.create(name: 'Other company').users.create(first_name: 'Other', last_name: 'User')

      Company.reindex
    end

    it "Index using the Serializer" do
      expect(Company.redisearch('@users_full_names:{Jon Doe}')).to eq Company.includes(:users).where(users: {first_name: 'Jon', last_name: 'Doe'})
      expect(Company.redisearch('@users_ids:{2}')).to eq Company.includes(:users).where(users: {first_name: 'Jon', last_name: 'Doe'})
      expect(Company.redisearch('@users_full_names:{Other User}')).to eq Company.includes(:users).where(users: {first_name: 'Other', last_name: 'User'})
    end
  end
end
