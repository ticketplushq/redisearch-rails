require 'spec_helper'

describe RediSearch do
  context ".redisearch" do
    context "with defaults" do
      before do
        rebuild_model 'User' do
          redisearch schema: {
            first_name: :text
          }
        end
        User.create(first_name: 'Jon')
        User.create(first_name: 'Jane')
        User.reindex
      end

      it "query '*' brings all the records" do
        expect(User.redisearch('*')).to eq User.all
      end

      it 'query by field bring the element' do
        expect(User.redisearch('@first_name:"Jon"')).to eq User.where(first_name: "Jon")
      end

      it "query with load false brings the ids" do
        expect(User.redisearch('*', load: false)).to eq User.all.order("id DESC").ids.map(&:to_s)
      end
    end

    context "with custom attribute" do
      before do
        rebuild_model 'User' do
          redisearch schema: {
            full_name: :text
          }

          def full_name
            "#{first_name} #{last_name}"
          end
        end
        User.create(first_name: 'Jon', last_name: 'Doe')
        User.create(first_name: 'Jane', last_name: 'Doe')
        User.reindex
      end

      it 'query by custom field bring the element' do
        expect(User.redisearch('@full_name:"Jon Doe"')).to eq User.where(first_name: 'Jon', last_name: 'Doe')
      end
    end

    context "when field value is Array" do
      before do
        rebuild_model 'User' do
          redisearch schema: {
            values: :tag,
            first_name: :text
          }

          def values
            [first_name, last_name, age]
          end
        end

        User.create(first_name: 'Jane', last_name: 'Doe', age: 23)
        User.create(first_name: 'Jon El', last_name: 'Doe', age: 21)
        User.reindex
      end

      it "query by tag brings the element" do
        expect(User.redisearch('@values:{21}')).to eq User.where(first_name: 'Jon El', last_name: 'Doe')
        expect(User.redisearch('@values:{Jon El}')).to eq User.where(first_name: 'Jon El', last_name: 'Doe')
        expect(User.redisearch('@values:{23}')).to eq User.where(first_name: 'Jane', last_name: 'Doe')
        expect(User.redisearch('@values:{ Jon El | 23 }')).to eq User.all
      end
    end
  end
end
