class RecipesController < ApplicationController
  
  def show
    @recipe = Recipe.find(params[:id])
    render 'show.json.jbuilder'
  end

  def index
    @recipes = Recipe.all
    render 'index.json.jbuilder'
  end
end
