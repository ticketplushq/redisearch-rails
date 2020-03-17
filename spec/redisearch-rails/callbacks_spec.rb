require 'spec_helper'

describe RediSearch do
  context "callbacks" do
    before do
      rebuild_model 'User' do
        redisearch schema: {
          first_name: :text
        }
      end
      rebuild_model 'Company' do
        redisearch schema: {
          name: :text
        }
      end
      User.reindex(recreate: true)
      Company.reindex(recreate: true)
    end

    context "if callbacks its true" do
      before do
        RediSearch.callbacks(true) do
          User.create
          User.create
          Company.create
          Company.last.destroy
        end
      end

      it "reindex elements after_commit" do
        expect(User.redisearch_count).to eq 2
      end

      it "delete elements if destroyed" do
        expect(Company.redisearch_count).to eq 0
      end
    end

    context "if callbacks its false" do
      before do
        RediSearch.callbacks(false) do
          User.create
          User.create
        end
      end

      it "do not reindex" do
        expect(User.redisearch_count).to eq 0
      end
    end

    context "if callbacks its inline" do
      before do
        RediSearch.callbacks(:inline) do
          User.create
          User.create
          Company.create
          Company.last.destroy
        end
      end

      it "reindex elements after_commit" do
        expect(User.redisearch_count).to eq 2
      end

      it "delete elements if destroyed" do
        expect(Company.redisearch_count).to eq 0
      end
    end

    context "if callbacks its async", type: :job do
      before do
        RediSearch.callbacks(:async) do
          User.create
        end
      end

      it "enqueue a job" do
        expect(enqueued_jobs.size).to eq 1
      end
    end
  end
end
