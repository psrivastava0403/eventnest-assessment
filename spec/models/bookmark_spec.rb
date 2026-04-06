require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  it "prevents duplicate bookmarks" do
    user = create(:user)
    event = create(:event)

    create(:bookmark, user: user, event: event)

    duplicate = Bookmark.new(user: user, event: event)

    expect(duplicate).not_to be_valid
  end
end