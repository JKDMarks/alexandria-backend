class FavoritesController < ApplicationController
  def create
    Favorite.create(favorite_params)
    @user = User.find(params[:user_id])
    render json: @user
  end

  def destroy
    Favorite.find_by(favorite_params).destroy
    @user = User.find(params[:user_id])
    render json: @user
  end


  private

  def favorite_params
    params.permit(:user_id, :deck_id)
  end
end
