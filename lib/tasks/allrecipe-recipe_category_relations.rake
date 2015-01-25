desc "scrape the relationship between recipes and a category"
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
          match_recipe_basic_info(category.sub_category_url + "&page=" + i.to_s, category.id)
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

def match_recipe_basic_info(url, category_id)
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