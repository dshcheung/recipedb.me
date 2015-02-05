desc "Scrape all the recipes"
task :init, [:start_page] => :environment do |task, args|
  start_time = Time.now
  require 'open-uri'
  require 'nokogiri'
  start_page = args.start_page.to_i
  end_page = start_page + 41

  for i in start_page..end_page
    puts "page " + i.to_s
    @tries = 0
    begin
      url = "http://allrecipes.com/recipes/main.aspx?vm=l&st=t&Page="+i.to_s
      puts "scraping ----> " + url
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
        url_code = url_array[4]

        if Recipe.find_by(url_code: url_code, domain_name_id: 1) == nil
          #create a new recipe entry
          new_recipe = author_existence.recipes.new

          new_recipe.outside_profile_id = author_existence.id
          new_recipe.domain_name_id = 1
          new_recipe.url_code = url_code
          new_recipe.name = url_code_elements[index].text.split.map(&:capitalize).join(' ')
          new_recipe.description = descriptions[index].text
          new_recipe.save

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
    new_recipe.update(img_collection_url: html_doc.css('#lnkOpenCarousel').attr("href").to_s)
    new_recipe.update(scrape_collection_completed: 0)

    #extract time info
    prepTimeMin = return_total_minutes(html_doc.css('#prepTimeHour em').text.to_i, html_doc.css('#prepMinsSpan em').text.to_i)
    cookTimeMin = return_total_minutes(html_doc.css('#cookHoursSpan em').text.to_i, html_doc.css('#cookMinsSpan em').text.to_i)
    readyTimeMin = return_total_minutes(html_doc.css('#totalHoursSpan em').text.to_i, html_doc.css('#totalMinsSpan em').text.to_i)
    restTimeMin = readyTimeMin - prepTimeMin - cookTimeMin
    new_recipe.update(prep_time: prepTimeMin)
    new_recipe.update(cook_time: cookTimeMin)
    new_recipe.update(ready_time: readyTimeMin)
    new_recipe.update(rest_time: restTimeMin)

    servings_element = html_doc.css('#lblYield').text.gsub('-', ' ').gsub('  ', ' ').gsub('(','').gsub(')','').downcase
    #if str has d x d
    if servings_element[/(\d+ ?x ?\d+)/] != nil 
      #if servings_element has d before d x d
      if servings_element[/(\d+( ?[^x])\d+)/] != nil
        servings_amount = servings_element[/(\d+)/]
        servings_type = servings_element[/(\(?\d+ ?x ?\d+.*)/].gsub(' x ', 'x')
      else
        servings_amount = nil
        servings_type = servings_element
      end
    #if servings have d to d
    elsif servings_element[/(\d+ ?to ?\d+)/] != nil
      num1 = servings_element[/(\d+)/].to_i
      num2 = servings_element[/(?!\d+ ?to ?)(\d+)/].to_i
      servings_amount = (num1 + num2) / 2
      servings_type = get_clean_servings_type(servings_element, servings_element[/(\d+ ?to ?\d+)/])
    #if servings have d / d
    elsif servings_element[/(\d+ ?\/ ?\d+)/] != nil
      if servings_element[/(\d+ ?\d ?)([ ]\d+ ?\/ ?\d+)/] != nil
        servings_amount = servings_element[/(\d+)/]
        first_digit_char = servings_element[/(\d+)/].length
        total_char = servings_element.length
        servings_type = servings_element[first_digit_char..total_char]
      else
        num1 = servings_element[/(\d+)/].to_i
        num2 = eval(servings_element[/(\d+ ?\/ ?\d+)/] + ".0")
        servings_amount = num1 + num2
        servings_type = get_clean_servings_type(servings_element, servings_element[/(\d+ ?\/ ?\d+)/])
      end
    else
      servings_amount = servings_element[/\d+/]
      servings_type = servings_element[/\s(.*)/]
    end
    #extract servings info
    if servings_amount != nil
      new_recipe.update(original_servings_amount: servings_amount)
    else
      new_recipe.update(original_servings_amount: 1)
    end
    if servings_type != nil
      new_recipe.update(original_servings_type: servings_type.squish.split.map(&:capitalize).join(' '))
    else
      new_recipe.update(original_servings_type: servings_type)
    end

    #extract instructions info
    instructions_elements = html_doc.css('div > div > ol > li > span')
    instructions_array = []
    instructions_elements.each do |elements|
      instructions_array.push(elements.text)
    end
    new_recipe.update(instructions: instructions_array)

    #extract ingredients info
    ingredients = []
    ingredients_elements = html_doc.css('#liIngredient')
    ingredients_elements.each do |element|
      #extract allrecipe_ingredient_code
      #find or create ar_ingredient_code entry and create ingredient_name
      ar_ingredient_code = element.attr('data-ingredientid').to_i
      ar_ingredient_code_existence = find_create_ingredient(ar_ingredient_code)

      #extract ingredient_name and create entry
      ingredient_name = element.css('#lblIngName').text.gsub('  ', ' ').gsub('-', ' ').downcase
      if ingredient_name != nil
        ingredient_name = ingredient_name.squish
      end
      ar_ingredient_code_existence.ingredient_names.create(sub_name: ingredient_name)

      puts ingredient_name
      
      #extract amount_metric
      amount_metric = element.attr("data-grams")

      #extract amount_us & unit_us
      #check if there is brackets, if true, then get information from bracket instead
      semi_clean_element = element.css('#lblIngAmount').text.split(element.css('#lblIngName').text)[0]

      if not semi_clean_element.nil?
        semi_clean_element = semi_clean_element.gsub('  ', ' ').squish
      else
        semi_clean_element = ""
      end

      elements_has_brackets = semi_clean_element[/(\((.*)\))/]
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
      new_recipe.recipe_ingredient_lists.create(ingredient_id: ar_ingredient_code_existence.id, amount_us: amount_us, unit_us: unit_us, amount_metric: amount_metric, unit_metric: "gram", display_name: ingredient_name)
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

def get_clean_servings_type(dirty_str, target_split)
  dirty_splited = dirty_str.split(target_split)
  if dirty_splited.any?
    index = dirty_splited.length - 1
    clean_str = dirty_splited[index].squish
  else
    clean_str = nil
  end
  return clean_str
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