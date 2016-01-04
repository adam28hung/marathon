# == Schema Information
#
# Table name: contests
#
#  id                    :integer          not null, primary key
#  objectid              :string
#  name                  :string
#  place                 :string
#  date_created_on_parse :date
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  slug                  :string
#  photo_count           :integer
#  event_date            :date
#

require "rails_helper"
RSpec.describe Contest, type: :model do
  let!(:contest) { Contest.create(objectid: 'Lo8r3KwMw3' \
                                  , name: '2015-海山馬拉松', place: 'Taipei' \
                                  , event_date: '2015-05-03', photo_count: 1 \
                                  , date_created_on_parse: '2015-05-10' ) }
  let!(:new_contest) { Contest.create(objectid: 'newerobjid' \
                                      , name: '2015-海山馬拉松', place: 'Kaohsiung' \
                                      , event_date: '2015-05-10', photo_count: 1 \
                                      , date_created_on_parse: '2015-05-10' ) }
  let!(:dup_contest, ) { Contest.create(objectid: 'newerobjid' \
                                        , name: '2015-海山馬拉松', place: 'Kaohsiung' \
                                        , event_date: '2015-05-15', photo_count: 1 \
                                        , date_created_on_parse: '2015-05-10' ) }

  context "validation" do
    it 'requires :objectid' do
      expect(contest).to validate_presence_of :objectid
    end
    it 'requires :photo_count' do
      expect(contest).to validate_presence_of :photo_count
    end
    it 'requires :name' do
      expect(contest).to validate_presence_of :name
    end
    it 'requires :place' do
      expect(contest).to validate_presence_of :place
    end
    it 'requires :date_created_on_parse' do
      expect(contest).to validate_presence_of :date_created_on_parse
    end
  end

  context "attributes" do
    it "is valid" do
      expect(contest).to be_valid
    end
    it "doesn't pass validation :objectid = nil" do
      contest.objectid = nil
      expect(contest).not_to be_valid
    end
    it "does pass validation when :objectid = 'Lo8r3KwMw3'" do
      expect(contest).to be_valid
    end
    it "doesn't pass validation when :objectid = 'Lo8r3KwMw$'" do
      contest.objectid = 'Lo8r3KwMw$'
      expect(contest).not_to be_valid
    end
    it "doesn't pass validation when :name = nil" do
      contest.name = nil
      expect(contest).not_to be_valid
    end
    it "doesn't pass validation when :place = nil" do
      contest.place = nil
      expect(contest).not_to be_valid
    end
    it "doesn't pass validation when:photo_count = nil " do
      contest.photo_count = nil
      expect(contest).not_to be_valid
    end
  end

  context 'scope' do
    it " scope #by_eventdate orders by event_date desc" do
      expect(Contest.by_eventdate).to eq([dup_contest, new_contest, contest])
    end
  end

  context 'slug' do

    it "creates default slug using [name] " do
      expect(contest.slug).to eq('2015-海山馬拉松')
    end

    it "creates slug using [name + objectid] while name collision " do
      expect(new_contest.slug).to eq('2015-海山馬拉松-newerobjid')
    end

    it "creates slug using [name + objectid + place] while name and objectid collision " do
      expect(dup_contest.slug).to eq('2015-海山馬拉松-newerobjid-kaohsiung')
    end

  end

  describe ContestQuery do
    let!(:contest_query) { ContestQuery.new(objectid: 'Lo8r3KwMw3' \
                                            , number: 1 ) }

    context "validation" do
      it 'requires :objectid' do
        expect(contest_query).to validate_presence_of :objectid
      end
      it 'requires :objectid' do
        expect(contest_query.objectid).to match(/\A[0-9a-zA-Z]{10}\z/i)
      end
      it 'requires :objectid' do
        expect(contest_query.objectid.length).to eq(10)
      end
      it 'requires :number' do
        expect(contest_query).to validate_presence_of :number
      end
      it 'requires :number' do
        expect(contest_query).to validate_numericality_of(:number).
          only_integer.is_greater_than(0)
      end
      it '#objectid_is_in_the_db' do
        expect(Contest.where(objectid: contest_query.objectid).limit(1).count)
        .to eq(1)
      end
    end

    context "attributes" do
      it "is valid" do
        expect(contest_query).to be_valid
      end
      it "doesn't pass validation when :objectid = nil " do
        contest_query.objectid = nil
        expect(contest_query).not_to be_valid
      end
      it "does pass validation" do
        expect(contest_query).to be_valid
      end
      it "doesn't pass validation when :objectid = 'Lo8r3KwMw$' " do
        contest_query.objectid = 'Lo8r3KwMw$' # invalid character $
        expect(contest_query).not_to be_valid
      end
      it "doesn't pass validation when :objectid = '3m6ieXOa7a' " do
        contest_query.objectid = '3m6ieXOa7a' # not in the db
        expect(contest_query).not_to be_valid
      end
      it "doesn't pass validation when :objectid = 'Lo8r3KwMw3z' " do
        contest_query.objectid = 'Lo8r3KwMw3z' # too long
        expect(contest_query).not_to be_valid
      end
      it "doesn't pass validation when :objectid = 'Lo8r3Kw' " do
        contest_query.objectid = 'Lo8r3Kw' # too short
        expect(contest_query).not_to be_valid
      end
      it "doesn't pass validation when :number = nil " do
        contest_query.number = nil
        expect(contest_query).not_to be_valid
      end
      it "doesn't pass validation when :number = -1" do
        contest_query.number = -1
        expect(contest_query).not_to be_valid
      end
    end

  end

end
