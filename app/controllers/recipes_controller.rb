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
    keyword_default = "SELECT DISTINCT recipes.id AS recipes_id FROM recipes INNER JOIN recipe_ingredient_lists ON recipes.id=recipe_ingredient_lists.recipe_id"
    keyword_where = "WHERE recipe_ingredient_lists.display_name like"

    category_default = "SELECT DISTINCT recipes.id AS recipes_id FROM recipes INNER JOIN recipe_category_lists ON recipe_category_lists.recipe_id = recipes.id INNER JOIN categories ON categories.id = recipe_category_lists.category_id"
    category_where = "WHERE recipe_category_lists.category_id="


    search_params = params[:search_parameters]
    search_count = 1

    query = "SELECT COUNT(recipes_id) as count_all, new.recipes_id as recipes_id FROM ("

    if search_params["keywords"] != nil
      search_params["keywords"].each do |keyword|
        search_count += 1
        query += "#{keyword_default} #{keyword_where} '%#{keyword}%' UNION ALL "
      end
    end

    if search_params["categories"] != nil
      search_params["categories"].each do |category|
        search_count += 1
        query += "#{category_default} #{category_where}#{category.to_s} UNION ALL "
      end
    end

    time1 = search_params["timeframe"][0]
    time2 = search_params["timeframe"][1]
    timeframe_default = "SELECT DISTINCT recipes.id AS recipes_id FROM recipes"
    timeframe_where = "WHERE recipes.ready_time >= #{time1.to_i} AND recipes.ready_time <= #{time2.to_i}"
    if search_count == 1
      query = query[0..-12]
    end
    query += "#{timeframe_default} #{timeframe_where}) AS new GROUP BY recipes_id HAVING COUNT(*) = #{search_count} LIMIT 20;"
    puts query

    array = []
    ActiveRecord::Base.connection.execute(query).each do |row|
      array << row['recipes_id'].to_i
    end
    puts array

    @recipes = Recipe.where(id: array)
    puts @recipes

    render 'index.json.jbuilder'
  end
end
