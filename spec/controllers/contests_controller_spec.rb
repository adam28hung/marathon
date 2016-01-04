require "rails_helper"
RSpec.describe ContestsController do

  let!(:contest) {  Contest.create!(objectid: 'Lo8r3KwMw3' \
                                    , name: '2015-海山馬拉松', place: 'Taipei' \
                                    , event_date: '2015-05-03', photo_count: 1 \
                                    , date_created_on_parse: '2015-05-10' ) }
  let!(:new_contest) { Contest.create(objectid: '3m6ieXOa7p' \
                                      , name: '第一屆台灣馬拉松賽', place: 'Kaohsiung' \
                                      , event_date: '2015-05-10', photo_count: 1 \
                                      , date_created_on_parse: '2015-05-10' ) }

  describe "index action" do
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
    it "assign @contests" do
      params = { "q"=>{"name_cont"=>""} }
      get :index, params
      expect(assigns(:contests)).to eq([new_contest, contest])
    end

    it "assign @contests with sort params " do
      params = { "q"=>{"name_cont"=>"2015"} }
      get :index, params
      expect(assigns(:contests)).to eq([contest])
    end
  end

  describe "show action", focus: true do
    it "render the show template " do
      get :show, id: contest.slug
      expect(response).to render_template("show")
    end
    it "responds with 404 Not Found for unknown contest" do
      params = { id: contest.slug + "unknown" }
      expect do
        get :show, params
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "assign @contest" do
      params = { id: new_contest.slug }
      get :show, params
      expect(assigns(:contest)).to eq(new_contest)
    end

  end

  describe "sort action" do
    it "render the sort template" do
      params = { "q"=>{"name_cont"=>""} }
      get :sort, params
      expect(response).to render_template("sort")
    end

    it "assign @contests" do
      params = { "q"=>{"name_cont"=>""} }
      get :sort, params
      expect(assigns(:contests)).to eq([new_contest, contest])
    end

    it "assign @contests with sort params " do
      params = { "q"=>{"name_cont"=>"2015"} }
      get :sort, params
      expect(assigns(:contests)).to eq([contest])
    end

  end

  describe "share action" do
    it "render the share template" do
      params = { id: contest.slug, photo_id: 'g4h1tqmTpP' }
      get :share, params

      expect(response).to render_template("share")
    end

    it "redirects to contest show page when photo not found" do
      # valid format, invalid record
      params = { id: contest.slug, photo_id: 'g4h1tqmTpq' }
      get :share, params
      expect(response).to redirect_to(contest_path(contest))
    end
  end

end
