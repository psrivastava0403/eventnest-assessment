module Api
  module V1
    class BookmarksController < ApplicationController

      def create
        return head :forbidden unless current_user.attendee?
        event = Event.find(params[:event_id])

        bookmark = current_user.bookmarks.create!(event: event)

        render json: { message: "Bookmarked" }, status: :created
      rescue ActiveRecord::RecordNotUnique
        render json: { error: "Already bookmarked" }, status: :unprocessable_entity
      end

      def destroy
        bookmark = current_user.bookmarks.find_by!(event_id: params[:event_id])
        bookmark.destroy

        head :no_content
      end

      def index
        bookmarks = current_user.bookmarks.includes(:event)

        render json: bookmarks.map { |b|
          {
            id: b.event.id,
            title: b.event.title,
            city: b.event.city
          }
        }
      end
    end
  end
end