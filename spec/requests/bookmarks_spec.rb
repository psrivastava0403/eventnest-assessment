require "rails_helper"

RSpec.describe "Bookmarks", type: :request do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  def auth_headers(user)
    token = user.generate_jwt
    {
      "ACCEPT" => "application/json",
      "Authorization" => "Bearer #{token}"
    }
  end

  it "creates bookmark" do
    post "/api/v1/events/#{event.id}/bookmark",
         headers: auth_headers(user)

    expect(response).to have_http_status(:created)
  end

  it "rejects duplicate" do
    create(:bookmark, user: user, event: event)

    post "/api/v1/events/#{event.id}/bookmark",
         headers: auth_headers(user)

    expect(response).to have_http_status(:unprocessable_entity)
  end
end