require "rails_helper"

RSpec.describe Paginatable, type: :controller do
  controller(ApplicationController) do
    include Paginatable # rubocop:disable RSpec/DescribedClass
    allow_unauthenticated_access

    def index
      scope = Review.order(created_at: :desc)
      reviews, meta = paginate(scope)
      render json: { data: reviews, meta: }
    end
  end

  let (:user) { create(:user) }

  before do
    routes.draw { get "index" => "anonymous#index" }
  end

  describe "GET #index with default pagination" do
    before { create_list(:review, 25, user:) }

    it "returns the first page of reviews with default limit" do
      get :index

      meta = response.parsed_body["meta"]
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].size).to eq(20)
      expect(meta).to include(
        "page" => 1,
        "limit" => 20,
        "total_count" => 25,
        "total_pages" => 2,
        "next_page" => 2,
        "prev_page" => nil
      )
    end
  end

  describe "GET #index with custom pagination parameters" do
    before { create_list(:review, 25, user:) }

    it "returns the second page of reviews with custom limit" do
      get :index, params: { page: 2 }

      expect(response.parsed_body["data"].size).to eq(5)
      expect(response.parsed_body["meta"]).to include(
        "page" => 2,
        "total_pages" => 2,
        "next_page" => nil,
        "prev_page" => 1
      )
    end
  end

  describe "GET #index with custom limit parameter" do
    before { create_list(:review, 25, user:) }

    it "returns the first page of reviews with custom limit" do
      get :index, params: { page: 2, limit: 10 }

      expect(response.parsed_body["data"].size).to eq(10)
      expect(response.parsed_body["meta"]).to include(
        "page" => 2,
        "limit" => 10,
        "total_count" => 25,
        "total_pages" => 3,
      )
    end
  end

  describe "GET #index with limit parameter exceeding maximum" do
    before { create_list(:review, 25, user:) }

    it "returns the first page of reviews with maximum limit" do
      get :index, params: { page: 1, limit: 999 }

      meta = response.parsed_body["meta"]
      expect(meta["limit"]).to eq(100)
      expect(meta["total_pages"]).to eq(1)
    end
  end

  describe "GET #index with invalid pagination parameters" do
    before { create_list(:review, 3, user:) }

    it "returns the first page of reviews with default page when page is negative" do
      get :index, params: { page: -1 }

      expect(response.parsed_body["meta"]["page"]).to eq(1)
    end

    it "returns the first page of reviews with default limit when limit is negative" do
      get :index, params: { limit: 0 }

      expect(response.parsed_body["meta"]["limit"]).to eq(1)
    end
  end

  describe "GET #index with valid pagination parameters" do
    before { create_list(:review, 25, user:) }

    it "prev_page と next_page の両方がある" do
      get :index, params: { page: 2, limit: 10 }

      meta = response.parsed_body["meta"]
      expect(meta["prev_page"]).to eq(1)
      expect(meta["next_page"]).to eq(3)
    end
  end

  describe "GET #index with no reviews" do
  it "空配列とメタ情報を返す" do
    get :index

    expect(response.parsed_body["data"]).to eq([])
    expect(response.parsed_body["meta"]).to include(
      "total_count" => 0,
      "total_pages" => 0,
      "next_page" => nil,
      "prev_page" => nil
    )
  end
end
end
