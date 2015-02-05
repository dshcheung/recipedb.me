class UsersController < ApplicationController
  def any
    if user_signed_in?
      render json: {signedIn: user_signed_in?, username: current_user.username, user_id: current_user.id}
    else
      render json: {signedIn: user_signed_in?, username: nil, user_id: nil}
    end
  end

  def bookmarks
    render json: {success: true}
  end

end