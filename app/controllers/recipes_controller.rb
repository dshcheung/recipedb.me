class RecipesController < ApplicationController
  
  def show
    @recipe = Recipe.find(params[:id])
    render 'show.json.jbuilder'
  end

  def index
    @recipes = Recipe.first(20)
    render 'index.json.jbuilder'
  end

  def search
    search_params = params[:search_parameters]
    search_str = ""

    if search_params["keywords"] != nil
      search_params["keywords"].each do |keyword|
        search_str = search_str + "sub_name like '%" + keyword + "%' and "
      end
    end

    if search_params["categories"] != nil
      search_params["categories"].each do |category|
        search_str = search_str + "category_id = " + category.to_s + " and "
      end
    end

    time1 = search_params["timeframe"][0]
    time2 = search_params["timeframe"][1]

    search_str = search_str + "ready_time >= " + time1.to_s + " and ready_time <= " + time2.to_s

    puts "search string here -------"
    puts search_str

    @recipes = Recipe.joins({ingredients: :ingredient_names}, :categories).where(search_str).group("recipes.id").first(20)

    render 'index.json.jbuilder'
  end
end
