class UsersController < ApplicationController
  def any
    render json: {signedIn: user_signed_in?, username: get_username}
  end

  def get_username
    if user_signed_in?
      return current_user.username
    else
      return nil
    end
  end
end