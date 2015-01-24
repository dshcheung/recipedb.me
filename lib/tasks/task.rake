namespace :allrecipe do
  task :image_collections => :environment do 
    require 'open-uri'
    require 'nokogiri'

    recipes = Recipe.all
    recipes.each do |recipe|
      @tries = 0
      begin
        # 0 = have not started, 1 = started but not finished, 2 = completed
        if recipe.scrape_collection_completed == 0 || recipe.scrape_collection_completed == 1
          recipe.update(scrape_collection_completed: 1)
          url = recipe.domain_name.name + recipe.url_code + "/photo-gallery.aspx"
          puts url
          browser = open(url).read
          html_doc = Nokogiri::HTML(browser)

          image_array = []
          image_urls = html_doc.css('tr > td.phototd > a > img')
          image_urls.each do |image|
            image_array.push(image.attr("src"))
          end
          recipe.update(img_urls: image_array)
          recipe.update(scrape_collection_completed: 2)
        else
          next
        end
      rescue OpenURI::HTTPError => e
        case rescue_me(e)
        when 1
          retry
        when 2
          next
        end
      end
    end
  end

  task :recipe_category_relations => :environment do
    require 'open-uri'
    require 'nokogiri'
    categories = Category.all
    categories.each do |category|
      @tries = 0
      begin
        # 0 = have not started, 1 = started but not finished, 2 = completed
        if category.scrape_category_status == 0 || category.scrape_category_status == 1
          category.update(scrape_category_status: 1)
          url = category.sub_category_url
          puts url
          browser = open(url).read
          html_doc = Nokogiri::HTML(browser)

          recipe_amounts = html_doc.css('div > div.hubs-wrapper.fl-left > div.search-tools > p:nth-child(2).searchResultsCount.results > span:nth-child(1).emphasized').text.gsub(',', '').to_i

          pages_to_loop = (recipe_amounts / 20.0).ceil
          for i in 1..pages_to_loop do
            puts "page " + i.to_s
            get_recipe_basic_info(category.sub_category_url + "&page=" + i.to_s, category.id)
          end
        else
          next
        end
      rescue OpenURI::HTTPError => e
        case rescue_me(e)
        when 1
          retry
        when 2
          next
        end
      end
    end
  end

  def get_recipe_basic_info(url, category_id)
    require 'open-uri'
    require 'nokogiri'

    @tries = 0
    begin
      puts url
      browser = open(url).read
      html_doc = Nokogiri::HTML(browser)
      
      url_code_elements = html_doc.css('div > div > div > h3 > a')
      authors = html_doc.css('div.searchResult.hub-list-view > div.search_mostPop > div.searchRtSd > div.search_mostPop_Review > span:nth-child(2)')
      authors.each_with_index do |author, index|
        if author.css('a').any?
          author_name = author.css('a').text.squish
        else
          author_name = author.text.squish
        end
        url_code = url_code_elements[index].attr('href').split('/')[4]
        author_existence = OutsideProfile.find_by(username: author_name)
        if author_existence != nil
          recipe_existence = author_existence.recipes.find_by(url_code: url_code)
          if recipe_existence != nil
            RecipeCategoryList.create(recipe_id: recipe_existence.id, category_id: category_id)
          end
        end
      end
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        return
      end
    end
  end
 
  task :category_tags => :environment do 
    get_category_info("Initial Level", "http://allrecipes.com/recipes/main.aspx?vm=l")
  end

  #run infinitly as long as there is a sub_category
  def get_category_info(main_category_name, main_category_url)
    require 'open-uri'
    require 'nokogiri'

    @tries = 0
    begin
      puts main_category_name
      puts main_category_url
      browser = open(main_category_url).read
      html_doc = Nokogiri::HTML(browser)

      sub_category_elements = html_doc.css('a#hlSubNavItem')
      if sub_category_elements.any?
        sub_category_elements.each do |sub_category_element|
          #prevent inconsistent href links
          sub_category_url = sub_category_element.attr("href") + "&vm=l"
          if sub_category_url[/(http:\/\/allrecipes.com)/] == nil
            sub_category_url = "http://allrecipes.com" + sub_category_url
          end
          if sub_category_url == main_category_url
            next
          end
          create_category(main_category_name, sub_category_element.text, sub_category_url)
          get_category_info(sub_category_element.text, sub_category_url)
        end
      end
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        return
      end
    end
  end

  def create_category(main_category_name, sub_category_name, sub_category_url)
    Category.create(main_category: main_category_name, sub_category: sub_category_name, sub_category_url: sub_category_url, scrape_category_status: 0)
  end

  task :init, [:start_frequency] => :environment do |task, args|
    start_time = Time.now
    require 'open-uri'
    require 'nokogiri'
    start_frequency = args.start_frequency.to_i
    end_frequency = start_frequency + 2

    for i in start_frequency..end_frequency
      puts "page " + i.to_s
      @tries = 0
      begin
        url = "http://allrecipes.com/recipes/main.aspx?vm=l&Page="+i.to_s
        browser = open(url).read
        html_doc = Nokogiri::HTML(browser)

        #gather all information into arrays
        descriptions = html_doc.css('div > div > div > div > span.popReview')
        url_code_elements = html_doc.css('div > div > div > h3 > a')
        authors = html_doc.css('div.searchResult.hub-list-view > div.search_mostPop > div.searchRtSd > div.search_mostPop_Review > span:nth-child(2)')

        #loop each author and check if OutsideProfile exists, if not, create one and create new_recipe
        authors.each_with_index do |author, index|
          #check if OutsideProfile Exists, if not, create one and continue
          if author.css('a').any?
            author_name = author.css('a').text.squish
            author_href_array = author.css('a').attr('href').to_s.split('/')
            outside_profile_url = "http://allrecipes.com/cook/" + author_href_array[4]
          else
            author_name = author.text.squish
            outside_profile_url = "http://allrecipes.com/"
          end
          author_existence = OutsideProfile.find_by(username: author_name, outside_profile_url: outside_profile_url)
          if author_existence == nil
            author_existence = OutsideProfile.create(display_format: 1, username: author_name, outside_profile_url: outside_profile_url)
          end

          #extract information and putting it in new_recipe
          url = url_code_elements[index].attr('href')
          url_array = url.split('/')

          if Recipe.find_by(url_code: url_array[4], domain_name_id: 1) == nil
            #create a new recipe entry
            new_recipe = author_existence.recipes.new

            new_recipe.outside_profile_id = author_existence.id
            new_recipe.domain_name_id = 1.to_i
            new_recipe.url_code = url_array[4]
            new_recipe.name = url_code_elements[index].text
            new_recipe.description = descriptions[index].text

            #go to part two of scrapping process to scrape recipe in depth information
            get_recipe_indepth_info(url, new_recipe)
          end
        end
      rescue OpenURI::HTTPError => e
        case rescue_me(e)
        when 1
          retry
        when 2
          next
        end
      end
    end
    end_time = Time.now
    puts end_time - start_time
  end

  def get_recipe_indepth_info(url, new_recipe)
    require 'open-uri'
    require 'nokogiri'
    require 'unitwise'
    require 'unitwise/ext'

    @tries = 0
    begin
      puts url
      browser = open(url).read
      html_doc = Nokogiri::HTML(browser)

      #extract img info
      new_recipe.img_collection_url = html_doc.css('#lnkOpenCarousel').attr("href").to_s
      new_recipe.scrape_collection_completed = 0

      #extract time info
      prepTimeMin = return_total_minutes(html_doc.css('#prepTimeHour em').text.to_i, html_doc.css('#prepMinsSpan em').text.to_i)
      cookTimeMin = return_total_minutes(html_doc.css('#cookHoursSpan em').text.to_i, html_doc.css('#cookMinsSpan em').text.to_i)
      readyTimeMin = return_total_minutes(html_doc.css('#totalHoursSpan em').text.to_i, html_doc.css('#totalMinsSpan em').text.to_i)
      restTimeMin = readyTimeMin - prepTimeMin - cookTimeMin
      new_recipe.prep_time = prepTimeMin
      new_recipe.cook_time = cookTimeMin
      new_recipe.ready_time = readyTimeMin
      new_recipe.rest_time = restTimeMin

      #extract servings info
      new_recipe.original_servings_amount = html_doc.css('#lblYield').text[/\d+/]
      new_recipe.original_servings_type = html_doc.css('#lblYield').text[/\s(.*)/].gsub('- ', '').squish

      #extract instructions info
      instructions_elements = html_doc.css('div > div > ol > li > span')
      instructions_array = []
      instructions_elements.each do |elements|
        instructions_array.push(elements.text)
      end
      new_recipe.instructions = instructions_array

      #save new_recipe
      new_recipe.save

      #extract ingredients info
      ingredients = []
      ingredients_elements = html_doc.css('#liIngredient')
      ingredients_elements.each do |element|
        #extract allrecipe_ingredient_code
        #find or create ar_ingredient_code entry and create ingredient_sub_name
        ar_ingredient_code = element.attr('data-ingredientid').to_i
        ar_ingredient_code_existence = find_create_ingredient(ar_ingredient_code)

        #extract ingredient_sub_name and create entry
        ingredient_sub_name = element.css('#lblIngName').text
        ar_ingredient_code_existence.ingredient_names.create(ingredient_sub_name: ingredient_sub_name)

        #extract amount_metric
        amount_metric = element.attr("data-grams")

        #extract amount_us & unit_us
        #check if there is brackets, if true, then get information from bracket instead
        elements_has_brackets = element.css('#lblIngAmount').text[/(\((.*)\))/]
        if elements_has_brackets == nil
          amount_us = element.css('#lblIngAmount').text[/(\d+)/].to_i
          unit_us = get_clean_unit_us(element.css('#lblIngAmount').text[/(?!\d+)\w+/])
        else
          amount_us = elements_has_brackets[/(\d+)/].to_i
          unit_us = get_clean_unit_us(elements_has_brackets[/(?!\d+)\w+/])
        end
        #check if there are fractions, if true, replace units_us
        elements_has_slash = element.css('#lblIngAmount').text[/(\d+\/\d+)/]
        if elements_has_slash != nil
          amount_us = element.css('#lblIngAmount').text[/(\d+)/].to_d + eval(element.css('#lblIngAmount').text[/(\d+\/\d+)/]+".0")
        end

        #create recipe_ingredient_list entry
        new_recipe.recipe_ingredient_lists.create(ingredient_id: ar_ingredient_code_existence.id, amount_us: amount_us, unit_us: unit_us, amount_metric: amount_metric, unit_metric: "gram")
      end
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        return
      end
    end
  end

  def find_create_ingredient(ar_ingredient_code)
    ar_ingredient_code_existence = Ingredient.find_by(ar_ingredient_code: ar_ingredient_code)
    if ar_ingredient_code_existence == nil
      ar_ingredient_code_existence = Ingredient.create(ar_ingredient_code: ar_ingredient_code)
    end
    return ar_ingredient_code_existence
  end

  def return_total_minutes(hours, minutes)
    return hours * 60 + minutes
  end

  def get_clean_unit_us(dirty_str)
    if dirty_str != nil && dirty_str[/s$/] != nil 
      return dirty_str[0..-2]
    else
      return dirty_str
    end
  end

  def rescue_me(e)
    puts e
    case e.io.status[0]
    when "403"
      puts "Error...Forbidden...Skipped"
      return 2
    when "404"
      return attempt_retry()
    else #500
      return attempt_retry()
    end
  end

  def attempt_retry()
    @tries += 1
    if @tries < 3
      puts "Attempting to Retry..." + @tries.to_s + "...In 5 Seconds"
      sleep 5
      return 1
    else
      puts "Skipped the page"
      return 2
    end
  end
end