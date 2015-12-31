require "rails_helper"
RSpec.describe ContestsController do

  let!(:contest) {  Contest.create!(objectid: 'Lo8r3KwMw3' \
                                    , name: '2015-海山馬拉松', place: 'Taipei' \
                                    , event_date: '2015-05-03', photo_count: 1 \
                                    , date_created_on_parse: '2015-05-10' ) }

  describe "index action" do
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "show action" do
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
