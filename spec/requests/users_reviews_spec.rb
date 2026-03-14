require 'rails_helper'

RSpec.describe "/users/:user_id/reviews", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:valid_headers) { auth_headers_for(user) }

  describe "GET /index" do
    context "when user exists" do
      context "without pagination params" do
        before do
          create_list(:review, 3, user:)
          create_list(:review, 2, user: other_user)
        end

        it "returns only the user's reviews" do
          get user_reviews_url(user), headers: valid_headers

          expect(response).to be_successful
          body = response.parsed_body
          review = body["data"].first

          expect(body["data"].size).to eq(3)
          expect(review).to include("id", "content", "user", "created_at", "updated_at")
          expect(body["data"]).to all(include("user" => {
            "id" => user.id,
            "name" => user.name
          }))
        end

        it "returns pagination meta" do
          get user_reviews_url(user), headers: valid_headers

          expect(response).to be_successful
          body = response.parsed_body

          expect(body["meta"]).to eq(
            "page" => 1,
            "limit" => 20,
            "total_count" => 3,
            "total_pages" => 1,
            "next_page" => nil,
            "prev_page" => nil
          )
        end
      end

      context "with page param" do
        before do
          create_list(:review, 25, user:)
          create_list(:review, 5, user: other_user)
        end

        it "returns the specified page of the user's reviews" do
          get user_reviews_url(user), params: { page: 2 }, headers: valid_headers

          expect(response).to be_successful
          body = response.parsed_body

          expect(body["data"].size).to eq(5)
          expect(body["meta"]).to include(
            "page" => 2,
            "limit" => 20,
            "total_count" => 25,
            "total_pages" => 2
          )
        end
      end

      context "with limit param" do
        before do
          create_list(:review, 25, user:)
        end

        it "respects limit parameter" do
          get user_reviews_url(user), params: { page: 2, limit: 10 }, headers: valid_headers

          expect(response).to be_successful
          body = response.parsed_body

          expect(body["data"].size).to eq(10)
          expect(body["meta"]).to include(
            "page" => 2,
            "limit" => 10,
            "total_count" => 25,
            "total_pages" => 3
          )
        end
      end

      context "when on the last page" do
        before do
          create_list(:review, 25, user:)
        end

        it "sets next_page to nil" do
          get user_reviews_url(user), params: { page: 3, limit: 10 }, headers: valid_headers

          expect(response).to be_successful
          body = response.parsed_body

          expect(body["meta"]["prev_page"]).to eq(2)
          expect(body["meta"]["next_page"]).to be_nil
        end
      end
    end

    context "when user does not exist" do
      it "returns not found" do
        get user_reviews_url(999), headers: valid_headers

        expect(response).to have_http_status(:not_found)
        body = response.parsed_body
        expect(body).to eq(
          "message" => "User not found"
        )
      end
    end
  end
end
