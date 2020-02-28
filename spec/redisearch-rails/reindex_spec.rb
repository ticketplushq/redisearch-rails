require 'spec_helper'

describe RediSearch do
  context ".reindex" do
    before do
      rebuild_model 'User' do
        redisearch schema: {
          first_name: :text
        }
      end

      User.create!
      User.create!
      User.reindex
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

  end
end
