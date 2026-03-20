# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Sessions API", type: :request do
  path "/session" do
    post "ログイン" do
      operationId "createSession"
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      security []

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          email_address: { type: :string },
          password: { type: :string }
        },
        required: [ 'email_address', 'password' ]
      }

      response "201", "ログイン成功" do
        schema type: :object,
          properties: {
            token: { type: :string }
          },
          required: [ 'token' ]

        let(:user) { create(:user, password: "password123") }
        let(:params) { { email_address: user.email_address, password: "password123" } }

        run_test!
      end

      response "401", "認証失敗" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:params) { { email_address: "wrong@example.com", password: "wrong" } }

        run_test!
      end
    end
  end
end
