require 'spec_helper'

describe RediSearch do
  context ".reindex" do
    before do
      rebuild_model 'User' do
        redisearch schema: {
          first_name: :text
        }
        belongs_to :company
      end

      rebuild_model 'Company' do
        redisearch schema: {
          name: :text
        }
        has_many :users
      end
      RediSearch.callbacks(false) do
        company = Company.create(name: 'The Company')
        company.users.create(first_name: 'Jon', last_name: 'Doe')
        company.users.create(first_name: 'Jane', last_name: 'Doe')

        User.reindex
        Company.reindex
      end
    end

    it "index all elements to rediseach service" do
      expect(User.redisearch_count).to eq 2
    end

    context "with recreate" do
      before do
        User.last.delete
        User.reindex(recreate: true)
      end

      it "drop and reindex elements in rediseach service" do
        expect(User.redisearch_count).to eq 1
      end
    end

    context "delete records not persisted" do
      before do
        RediSearch.callbacks(true) do
          User.last.destroy
        end
      end

      it "drop deleted elements in rediseach service" do
        expect(User.redisearch_count).to eq 1
      end
    end

  end
end
