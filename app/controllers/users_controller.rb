class UsersController < ApplicationController
  def create
    if params[:password] === params[:passwordConfirm]
      @user = User.create(user_params)
      if @user.valid?
        @user.update(image: Card.all.sample.image_uris["art_crop"])
        render json: { user: @user, token: encode_token(@user) }
      else
        render json: { error: @user.errors.full_messages }
      end
    else
      render json: { error: "Passwords don't match, bro. 👨‍🍳🔪" }
    end
  end

  def profile
    token = request.headers[:Authorization]
    decoded_token = JWT.decode token, "power10", true, { algorithm: 'HS256' }
    user_id = decoded_token[0]["user_id"]
    @user = User.find(user_id)
    render json: @user
  end

  private

  def user_params
    params.permit(:username, :password)
  end
end
