class UsersController < ApplicationController
  def any
    render json: {signedIn: user_signed_in?, username: get_username, user_id: current_user.id}
  end

  def bookmarks
    render json: {success: true}
  end

  def get_username
    if user_signed_in?
      return current_user.username
    else
      return nil
    end
  end
end