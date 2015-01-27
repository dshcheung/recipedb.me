desc "scrape all the category names and their respective parent category"
task :category_tags => :environment do
  get_category_info("Initial Level", "http://allrecipes.com/recipes/main.aspx?vm=l")
end

task :category_test => :environment do
  get_category_info("Main Dish", "http://allrecipes.com/Recipes/Main-Dish/Main.aspx?prop24=hn_browsedeeper&evt19=1")
end

#run infinitly as long as there is a sub_category
def get_category_info(main_category_name, main_category_url)
  require 'open-uri'
  require 'nokogiri'

  @tries = 0
  begin
    puts main_category_url
    browser = open(main_category_url).read
    html_doc = Nokogiri::HTML(browser)
    
    sub_category_elements = html_doc.css('a#hlSubNavItem')
    elements_to_loop = sub_category_elements.length

    related_category_elements = html_doc.css('ul#subNavGroupContainer.cat.related li a#hlSubNavItem')
    elements_to_remove = related_category_elements.length

    if related_category_elements != nil
      if elements_to_remove == elements_to_loop
        puts "skipped"
        return
      else
        index = elements_to_loop - elements_to_remove - 1
        sub_category_elements = sub_category_elements[0..index]
      end
    end

    if sub_category_elements.any?
      sub_category_elements.each do |sub_category_element|
        #prevent inconsistent href links
        sub_category_url = sub_category_element.attr("href") + "&vm=l&st=t"
        if sub_category_url[/(http:\/\/allrecipes.com)/] == nil
          sub_category_url = "http://allrecipes.com" + sub_category_url
        end
        if sub_category_url == main_category_url
          next
        end
        create_category(main_category_name, main_category_url, sub_category_element.text, sub_category_url)
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

def create_category(main_category_name, main_category_url, sub_category_name, sub_category_url)
  Category.create(main_category: main_category_name, main_category_url: main_category_url, sub_category: sub_category_name, sub_category_url: sub_category_url, scrape_category_status: 0)
end