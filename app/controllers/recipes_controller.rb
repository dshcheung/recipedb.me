class RecipesController < ApplicationController
  
  def show
    @recipe = Recipe.find(params[:id])
    if user_signed_in?
      @bookmarks = current_user.user_bookmarks
    else
      @bookmarks = []
    end
    render 'show.json.jbuilder'
  end

  def search
    query = getQueryStr(params, true)

    array = []
    ActiveRecord::Base.connection.execute(query).each do |row|
      array << row['recipes_id'].to_i
    end
    @recipes = Recipe.where(id: array)
    if user_signed_in?
      @bookmarks = current_user.user_bookmarks
    else
      @bookmarks = []
    end

    render 'index.json.jbuilder'
  end

  def search_count
    query = getQueryStr(params, false)

    count = ActiveRecord::Base.connection.execute(query).count

    render json: {count: count}
  end

  private
  def getQueryStr(params, orderQuery)
    search_count = 1

    if params["page"] != nil  
      offset = 8 * (params["page"].to_i - 1)
    else
      offset = 0
    end

    query = starting_query

    if params["user"]
      search_count += 1
      query += "#{user_default} #{user_condition}#{current_user.id} UNION ALL "
    end

    if params["keywords"] != nil
      params["keywords"].each do |keyword|
        search_count += 1
        query += "#{keyword_default} #{keyword_condition} '%#{keyword.downcase}%' UNION ALL "
      end
    end

    if params["ingredients"] != nil
      params["ingredients"].each do |ingredient|
        search_count += 1
        query += "#{ingredient_default} #{ingredient_condition} '%#{ingredient.downcase}%' UNION ALL "
      end
    end

    if params["categories"] != nil
      query += "#{category_default} "
      search_count += 1
      params["categories"].each do |category|
        query += "#{category_condition}#{category.to_s} OR "
      end
      query = query[0..-4] + "UNION ALL "
    end

    time1 = params["timeframe"][0]
    time2 = params["timeframe"][1]
    query += "#{timeframe_default} #{timeframe_condition(time1,time2)})"

    if orderQuery == true
      query += ending_query(search_count, offset)
    else
      query += ending_query2(search_count)
    end

    return query
  end

  def user_default
    return "SELECT DISTINCT recipes.id AS recipes_id FROM recipes INNER JOIN user_bookmarks on recipes.id = user_bookmarks.recipe_id"
  end

  def user_condition
    "WHERE user_bookmarks.user_id="
  end

  def keyword_default
    return "SELECT DISTINCT recipes.id AS recipes_id FROM recipes INNER JOIN recipe_ingredient_lists ON recipes.id=recipe_ingredient_lists.recipe_id"
  end

  def keyword_condition
    return "WHERE lower(recipes.name) like"
  end

  def ingredient_default
    return "SELECT DISTINCT recipes.id AS recipes_id FROM recipes INNER JOIN recipe_ingredient_lists ON recipes.id=recipe_ingredient_lists.recipe_id"
  end

  def ingredient_condition
    return "WHERE recipe_ingredient_lists.display_name like"
  end

  def category_default
    return "SELECT DISTINCT recipes.id AS recipes_id FROM recipes INNER JOIN recipe_category_lists ON recipe_category_lists.recipe_id = recipes.id INNER JOIN categories ON categories.id = recipe_category_lists.category_id WHERE "
  end

  def category_condition
    return "recipe_category_lists.category_id="
  end

  def timeframe_default
    return "SELECT DISTINCT recipes.id AS recipes_id FROM recipes"
  end

  def timeframe_condition(time1, time2)
    return "WHERE recipes.ready_time >= #{time1.to_i} AND recipes.ready_time <= #{time2.to_i}"
  end

  def starting_query
    return "SELECT COUNT(recipes_id) as count_all, new.recipes_id as recipes_id FROM ("
  end

  def ending_query(search_count, offset)
    return " AS new GROUP BY recipes_id HAVING COUNT(*) = #{search_count} ORDER BY recipes_id ASC LIMIT 8 OFFSET #{offset};"
  end
  def ending_query2(search_count)
    return " AS new GROUP BY recipes_id HAVING COUNT(*) = #{search_count};"
  end
end
