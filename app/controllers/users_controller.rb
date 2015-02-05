class UsersController < ApplicationController
  def any
    if user_signed_in?
      render json: {signedIn: user_signed_in?, username: current_user.username, user_id: current_user.id}
    else
      render json: {signedIn: user_signed_in?, username: nil, user_id: nil}
    end
  end

  def add_bookmark
    bookmark = current_user.user_bookmarks.new
    bookmark.recipe_id = params[:recipe_id]
    if bookmark.save
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def remove_bookmark
    bookmark = current_user.user_bookmarks.find_by(recipe_id: params[:recipe_id].to_i)
    bookmark.destroy
    render json: {success: true}
  end

end