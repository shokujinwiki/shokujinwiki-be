require "swagger_helper"

RSpec.describe "/reviews", type: :request do
  let(:user) { create(:user) }
  let(:session) { user.sessions.create!(user_agent: "RSpec", ip_address: "127.0.0.1") }
  let(:Authorization) { "Bearer #{session.token}" }

  path "/reviews" do
    get "Retrieves a list of reviews" do
      operationId "listReviews"
      tags "Reviews"
      produces "application/json"
      security [ bearer_auth: [] ]
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :limit, in: :query, type: :integer, required: false

      response "200", "reviews retrieved successfully" do
        schema type: :object,
        properties: {
          data: {
            type: :array,
            items: { "$ref" => "#/components/schemas/review" }
          },
          meta: { "$ref" => "#/components/schemas/pagination_meta" }
        },
        required: [ "data", "meta" ]

        before { create_list(:review, 3, user:) }

        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:Authorization) { "" }

        run_test!
      end
    end

    post "Creates a new review" do
      operationId "createReview"
      tags "Reviews"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          review: {
            type: :object,
            properties: {
              content: { type: :string }
            },
            required: [ "content" ]
          }
        }
      }

      response "201", "review created successfully" do
        schema "$ref" => "#/components/schemas/review"

        let(:body) { { content: "Great" } }

        run_test!
      end

      response "422", "invalid request" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:body) {
          { content: nil }
        }

        run_test!
      end

      response "400", "bad request" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:body) { {} }

        run_test!
      end
    end
  end

  path "/reviews/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Retrieves a specific review" do
      operationId "getReview"
      tags "Reviews"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "review retrieved successfully" do
        schema "$ref" => "#/components/schemas/review"

        let(:id) { create(:review, user:).id }

        run_test!
      end

      response "404", "review not found" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:id) { 0 }

        run_test!
      end
    end

    patch "Updates a specific review" do
      operationId "updateReview"
      tags "Reviews"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          review: {
            type: :object,
            properties: {
              content: { type: :string }
            }
          }
        },
        required: [ 'review' ]
      }

      response "200", "review updated successfully" do
        schema "$ref" => "#/components/schemas/review"

        let(:id) { create(:review, user:).id }
        let(:body) { { review: { content: "Updated content" } } }

        run_test!
      end

      response "422", "invalid request" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:id) { create(:review, user:).id }
        let(:body) { { review: { content: nil } } }

        run_test!
      end

      response "403", "forbidden" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:id) { create(:review, user: create(:user)).id }
        let(:body) { { review: { content: "Updated content" } } }

        run_test!
      end

      response "404", "review not found" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:id) { 0 }
        let(:body) { { review: { content: "Updated content" } } }

        run_test!
      end
    end

    delete "Deletes a specific review" do
      operationId "deleteReview"
      tags "Reviews"
      security [ bearer_auth: [] ]

      response "204", "review deleted successfully" do
        let(:id) { create(:review, user:).id }

        run_test!
      end

      response "403", "forbidden" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:id) { create(:review, user: create(:user)).id }

        run_test!
      end

      response "404", "review not found" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:id) { 0 }

        run_test!
      end
    end
  end
end
