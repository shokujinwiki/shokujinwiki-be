require 'rails_helper'

RSpec.describe "/reviews", type: :request do
  let(:user) { create(:user) }
  let(:valid_headers) { {} }

  describe "GET /index" do
    context "without pagination params" do
      before { create_list(:review, 3, user:) }

      it "returns reviews" do
        get reviews_url, headers: valid_headers

        expect(response).to be_successful
        body = response.parsed_body
        review = body["data"].first

        expect(review).to include("id", "content", "user", "created_at", "updated_at")
        expect(review["user"]).to eq(
          "id" => user.id,
          "name" => user.name
        )
      end

      it "returns pagination meta" do
        get reviews_url, headers: valid_headers

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

    context "with 25 reviews" do
      before { create_list(:review, 25, user:) }

      context "with default pagination params" do
        it "returns first page with 20 items" do
          get reviews_url, headers: valid_headers

          expect(response).to be_successful
          body = response.parsed_body

          expect(body["data"].size).to eq(20)
          expect(body["meta"]).to include(
            "page" => 1,
            "limit" => 20,
            "total_count" => 25,
            "total_pages" => 2
          )
        end
      end

      context "with page param" do
        it "returns the specified page" do
          get reviews_url, params: { page: 2 }, headers: valid_headers

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
        it "respects limit parameter" do
          get reviews_url, params: { page: 2, limit: 10 }, headers: valid_headers

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

      context "with limit exceeding maximum" do
        it "caps limit at 100" do
          get reviews_url, params: { limit: 999 }, headers: valid_headers

          expect(response).to be_successful
          body = response.parsed_body

          expect(body["data"].size).to eq(25)
          expect(body["meta"]).to include(
            "page" => 1,
            "limit" => 100,
            "total_count" => 25,
            "total_pages" => 1
          )
        end
      end

      context "when on the first page" do
        it "sets prev_page to nil" do
          get reviews_url, params: { page: 1, limit: 10 }, headers: valid_headers

          expect(response).to be_successful
          body = response.parsed_body

          expect(body["meta"]["prev_page"]).to be_nil
          expect(body["meta"]["next_page"]).to eq(2)
        end
      end

      context "when on a middle page" do
        it "includes next_page and prev_page" do
          get reviews_url, params: { page: 2, limit: 10 }, headers: valid_headers

          expect(response).to be_successful
          body = response.parsed_body

          expect(body["meta"]).to include(
            "page" => 2,
            "limit" => 10,
            "total_count" => 25,
            "total_pages" => 3,
            "next_page" => 3,
            "prev_page" => 1
          )
        end
      end

      context "when on the last page" do
        it "sets next_page to nil" do
          get reviews_url, params: { page: 3, limit: 10 }, headers: valid_headers

          expect(response).to be_successful
          body = response.parsed_body

          expect(body["meta"]["prev_page"]).to eq(2)
          expect(body["meta"]["next_page"]).to be_nil
        end
      end
    end
  end

  describe "GET /show" do
    context "when review exists" do
      it "returns the review" do
        review = create(:review, user:)
        get review_url(review), headers: valid_headers

        expect(response).to be_successful
        body = response.parsed_body

        expect(body).to include("id", "content", "user", "created_at", "updated_at")
        expect(body["user"]).to eq(
          "id" => user.id,
          "name" => user.name
        )
      end
    end

    context "when review does not exist" do
      it "returns not found" do
        get review_url(999), headers: valid_headers

        expect(response).to have_http_status(:not_found)
        body = response.parsed_body
        expect(body).to eq(
          "message" => "Review not found"
        )
      end
    end
  end

  describe "POST /create" do
    context "with valid params" do
      it "creates a review" do
        post reviews_url, params: { review: { content: "hello", user_id: user.id } }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:created)
        expect(Review.count).to eq(1)
      end
    end

    context "with invalid params" do
      it "returns unprocessable content" do
        post reviews_url, params: { review: { content: nil, user_id: user.id } }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "without review params" do
      it "returns bad request" do
        post reviews_url, params: {}, headers: valid_headers, as: :json

        expect(response).to have_http_status(:bad_request)
        body = response.parsed_body
        expect(body).to eq(
          "message" => "param is missing or the value is empty or invalid: review"
        )
      end
    end

    context "with malformed JSON" do
      it "returns bad request" do
        post reviews_url,
              params: '{"review": {"content": "hello"', headers: valid_headers.merge({ "CONTENT_TYPE" => "application/json" })

        expect(response).to have_http_status(:bad_request)
        body = response.parsed_body
        expect(body).to eq(
          "message" => "Error occurred while parsing request parameters"
        )
      end
    end
  end

  describe "PATCH /update" do
    context "with valid params" do
      it "updates the review" do
        review = create(:review, user:)
        patch review_url(review), params: { review: { content: "updated" } }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(review.reload).to have_attributes(content: "updated")
      end
    end

    context "with invalid params" do
      it "returns unprocessable content" do
        review = create(:review, user:)
        patch review_url(review), params: { review: { content: nil } }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when review does not exist" do
      it "returns not found" do
        patch review_url(999), params: { review: { content: "hello" } }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /destroy" do
    context "when review exists" do
      it "destroys the review" do
        review = create(:review, user:)
        delete review_url(review), headers: valid_headers, as: :json

        expect(Review).not_to exist(review.id)
      end
    end

    context "when review does not exist" do
      it "returns not found" do
        delete review_url(999), headers: valid_headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
