namespace :allrecipe do
  task :init, [:start_frequency] => :environment do |task, args|
    get_ar_url(args.start_frequency.to_i)
  end

  task :category_tags => :enviornment do 
    get_category_tags()
  end

  def get_category_tags()
    require 'open-uri'
    require 'nokogiri'

    @tries
    begin
      url = "http://allrecipes.com/recipes/main.aspx?"
      browser = open(url).read
      html_doc = Nokogiri::HTML(browser)

      category_urls = html_doc.css('a#hlSubNavItem')
      category_urls.each do |category_url|
        puts category_url
      end
    rescue
      case rescue_me(e)
      when 1
        retry
      when 2
        next
      end
    end
  end

  def get_ar_url(start_frequency)
    require 'open-uri'
    require 'nokogiri'
    end_frequency = start_frequency + 9

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
          #create a new recipe entry
          new_recipe = author_existence.recipes.new

          #extract information and putting it in new_recipe
          url = url_code_elements[index].attr('href')
          url_array = url.split('/')

          new_recipe.outside_profile_id = author_existence.id
          new_recipe.domain_name_id = 1.to_i
          new_recipe.url_code = url_array[4]
          new_recipe.name = url_code_elements[index].text
          new_recipe.description = descriptions[index].text

          #go to part two of scrapping process to scrape recipe in depth information
          get_recipe_indepth_info(url, new_recipe)
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