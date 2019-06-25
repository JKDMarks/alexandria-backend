class AuthController < ApplicationController
  def login
    @user = User.find_by_username(params[:username])

    if @user && @user.authenticate(params[:password])
      render json: {
        token: encode_token(@user),
        user: @user
      }
    else
      render json: { error: "Incorrect username or password" }
    end
  end
end
