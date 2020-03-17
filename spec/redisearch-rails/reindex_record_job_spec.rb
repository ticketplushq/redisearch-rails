require 'spec_helper'

describe RediSearch::ReindexRecordJob, type: :job do
  before do
    rebuild_model 'User' do
      redisearch schema: {
        first_name: :text
      }
    end

    User.reindex(recreate: true)

    (0..12).each do |name|
      RediSearch.callbacks(false) do
        User.create(first_name: "#{name} Jon")
      end
    end
  end

  subject { described_class }

  context "perform_later" do
    let(:job) { subject.perform_later("User", 3) }

    it 'queues the job' do
      expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it 'is in default queue' do
      expect(subject.new.queue_name).to eq('redisearch')
    end

    it 'executes perform' do
      expect(User.redisearch_count).to eq 0
      perform_enqueued_jobs { job }
      expect(User.redisearch_count).to eq 1
    end
  end
end
