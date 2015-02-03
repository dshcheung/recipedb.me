class RecipesController < ApplicationController
  
  def show
    @recipe = Recipe.find(params[:id])
    render 'show.json.jbuilder'
  end

  def index
    @recipes = Recipe.limit(8).offset(0)
    render 'index.json.jbuilder'
  end

  def index_count
    count = Recipe.count()
    render json: {count: count}
  end

  def search
    query = getQueryStr(params, 1)

    array = []
    ActiveRecord::Base.connection.execute(query).each do |row|
      array << row['recipes_id'].to_i
    end
    @recipes = Recipe.where(id: array)

    render 'index.json.jbuilder'
  end

  def search_count
    query = getQueryStr(params, 2)

    count = ActiveRecord::Base.connection.execute(query).count

    render json: {count: count}
  end

  private
  def getQueryStr(params, method)
    search_params = params[:search_parameters]
    search_count = 1

    if params["page"] != nil  
      offset = 8 * (params["page"].to_i - 1)
    else
      offset = 0
    end

    query = starting_query

    if search_params["keywords"] != nil
      search_params["keywords"].each do |keyword|
        search_count += 1
        query += "#{keyword_default} #{keyword_condition} '%#{keyword.downcase}%' UNION ALL "
      end
    end

    if search_params["categories"] != nil
      search_params["categories"].each do |category|
        search_count += 1
        query += "#{category_default} #{category_condition}#{category.to_s} UNION ALL "
      end
    end

    time1 = search_params["timeframe"][0]
    time2 = search_params["timeframe"][1]
    query += "#{timeframe_default} #{timeframe_condition(time1,time2)})"

    if method == 1
      query += ending_query(search_count, offset)
    else
      query += ending_query2(search_count)
    end

    return query
  end

  def keyword_default
    return "SELECT DISTINCT recipes.id AS recipes_id FROM recipes INNER JOIN recipe_ingredient_lists ON recipes.id=recipe_ingredient_lists.recipe_id"
  end

  def keyword_condition
    return "WHERE recipe_ingredient_lists.display_name like"
  end

  def category_default
    return "SELECT DISTINCT recipes.id AS recipes_id FROM recipes INNER JOIN recipe_category_lists ON recipe_category_lists.recipe_id = recipes.id INNER JOIN categories ON categories.id = recipe_category_lists.category_id"
  end

  def category_condition
    return "WHERE recipe_category_lists.category_id="
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
