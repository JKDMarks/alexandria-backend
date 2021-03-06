class UsersController < ApplicationController
  def index
    @users = User.order(:id)
    render json: @users
  end

  def show
    user = User.find(params[:id])
    # favorite_card = user.favorite_card_id ? Card.find(user.favorite_card_id) : nil
    render json: {
      id: user.id,
      username: user.username,
      favorite_card: user.favorite_card,
      image: user.image,
      decks: user.decks
    }
  end

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

  def update
    @user = User.find(params[:id])
    @user.update(username: params[:username], image: params[:image])

    if params[:password] === params[:passwordConfirm]
      @user.update(password: params[:password])
    end

    if params[:favoriteCardName]
      favorite_card = Card.find_by("name ~* ?", params[:favoriteCardName])

      if favorite_card
        @user.update(favorite_card: JSON.parse(favorite_card.to_json))
      end
    end

    render json: @user
  end

  def profile
    token = request.headers[:Authorization]
    puts "TOKEN", token
    decoded_token = JWT.decode token, "power10", true, { algorithm: 'HS256' }
    user_id = decoded_token[0]["user_id"]
    @user = User.find(user_id)
    render json: @user
  end

  private

  def user_params
    params.permit(:username, :password, :image)
  end
end
