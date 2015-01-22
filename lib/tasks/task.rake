namespace :ar do
  task :ar_init, [:sFrequency] => :environment do |task, args|
    get_ar_url(args.sFrequency.to_i)
  end

  def get_ar_url(sFrequency)
    require 'open-uri'
    require 'nokogiri'
    eFrequency = sFrequency
    @skipped_page = []

    for i in sFrequency..eFrequency
      puts "page " + i.to_s
      @tries = 0
      begin
        url = "http://allrecipes.com/recipes/main.aspx?vm=l&Page="+i.to_s
        browser = open(url).read
        html_doc = Nokogiri::HTML(browser)

        #gather all information into arrays
        recipe_descriptions = html_doc.css('div > div > div > div > span.popReview')
        recipe_url_code_elements = html_doc.css('div > div > div > h3 > a')
        recipe_authors = html_doc.css('div.searchResult.hub-list-view > div.search_mostPop > div.searchRtSd > div.search_mostPop_Review > span:nth-child(2)')

        #loop each author and check if OutsideProfile exists, if not, create one and create recipe_entry
        recipe_authors.each_with_index do |author, index|
          #check if OutsideProfile Exists, if not, create one and continue
          if author.css('a').any?
            author_name = author.css('a').text().squish
            author_href_array = author.css('a').attr('href').to_s.split('/')
            outside_profile_url = "http://allrecipes.com/cook/" + author_href_array[4]
          else
            author_name = author.text().squish
            outside_profile_url = "http://allrecipes.com/"
          end
          author_existence = OutsideProfile.find_by(username: author_name, outside_profile_url: outside_profile_url)
          if author_existence == nil
            author_existence = OutsideProfile.create(display_format: 1, username: author_name, outside_profile_url: outside_profile_url)
          end
          #create a new recipe entry
          recipe_entry = author_existence.recipes.new

          #extract information and putting it in recipe_entry
          recipe_url = recipe_url_code_elements[index].attr('href')
          recipe_url_array = recipe_url.split('/')
          #check if domain exist, if not, create one and continue

          recipe_entry.outside_profile_id = author_existence.id
          recipe_entry.domain_name_id = 1 #change variable after testing
          recipe_entry.recipe_url_code = recipe_url_array[4]
          recipe_entry.recipe_name = recipe_url_code_elements[index].text()
          recipe_entry.recipe_description = recipe_descriptions[index].text()

          #go to part two of scrapping process to scrape recipe in depth information
          get_recipe_indepth_info(recipe_url, recipe_entry)
          recipe_entry.save
        end
      rescue OpenURI::HTTPError => e
        case rescue_me(e, i)
        when 1
          retry
        when 2
          next
        end
      end
    end
  end

  def get_recipe_indepth_info(recipe_url, recipe_entry)
    require 'open-uri'
    require 'nokogiri'

    @tries = 0
    begin
      puts recipe_url
      browser = open(recipe_url).read
      html_doc = Nokogiri::HTML(browser)

      #extract information and putting it in recipe_entry
      recipe_entry.recipe_img_collection_url = html_doc.css('#lnkOpenCarousel').attr("href").to_s
      recipe_entry.scrape_collection_completed = 0
      # recipe_entry.recipe_original_servings_amount = html_doc.css('#lblYield').text().split(' ')[0].to_i

      prepTimeHour = html_doc.css('#prepTimeHour em').text().to_i
      prepTimeMin = html_doc.css('#prepMinsSpan em').text().to_i
      prepTimeMin = prepTimeHour * 60 + prepTimeMin
      cookTimeHour = html_doc.css('#cookHoursSpan em').text().to_i
      cookTimeMin = html_doc.css('#cookMinsSpan em').text().to_i
      cookTimeMin = cookTimeHour * 60 + cookTimeMin
      readyTimeHour = html_doc.css('#totalHoursSpan em').text.to_i
      readyTimeMin = html_doc.css('#totalMinsSpan em').text.to_i
      readyTimeMin = readyTimeHour * 60 + readyTimeMin
      restTimeMin = readyTimeMin - prepTimeMin - cookTimeMin

      recipe_entry.recipe_prep_time = prepTimeMin
      recipe_entry.recipe_cook_time = cookTimeMin
      recipe_entry.recipe_ready_time = readyTimeMin
      recipe_entry.recipe_rest_time = restTimeMin

      recipe_entry.recipe_original_servings_amount = html_doc.css('#lblYield').text()[/\d+/]
      recipe_entry.recipe_original_servings_type = html_doc.css('#lblYield').text()[/\s(.*)/].gsub('- ', '').squish

      recipe_instructions_elements = html_doc.css('div > div > ol > li > span')
      recipe_instructions_array = []
      recipe_instructions_elements.each_with_index do |elements, index|
        recipe_instructions_array.push(elements.text())
      end
      recipe_entry.recipe_instructions = recipe_instructions_array

      
    rescue OpenURI::HTTPError => e
      case rescue_me(e, i)
      when 1
        retry
      when 2
        return
      end
    end
  end

  def rescue_me(e, i)
    puts e
    case e.io.status[0]
    when "403"
      puts "Error...Forbidden...Skipped"
      return 2
    when "404"
      return attempt_retry(i)
    else #500
      return attempt_retry(i)
    end
  end

  def attempt_retry(i)
    @tries += 1
    if @tries < 3
      puts "Attempting to Retry..." + @tries.to_s + "...In 5 Seconds"
      sleep 5
      return 1
    else
      @skipped_page.push(i)
      puts "Skipped the following page " + i.to_s
      return 2
    end
  end
end