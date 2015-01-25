desc "scrape all the category names and their respective parent category"
task :category_tags => :environment do 
  get_category_info("Initial Level", "http://allrecipes.com/recipes/main.aspx?vm=l")
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
    times_to_loop = html_doc.css('a#hlSubNavItem').size

    if html_doc.css('ul#subNavGroupContainer.cat.related li') != nil
      times_to_loop = times_to_loop - (html_doc.css('ul#subNavGroupContainer.cat.related li').size - 1)
    end
    if sub_category_elements.any?
      loop_count = 0
      sub_category_elements.each do |sub_category_element|
        if loop_count < times_to_loop
          #prevent inconsistent href links
          sub_category_url = sub_category_element.attr("href") + "&vm=l"
          if sub_category_url[/(http:\/\/allrecipes.com)/] == nil
            sub_category_url = "http://allrecipes.com" + sub_category_url
          end
          if sub_category_url == main_category_url
            next
          end
          create_category(main_category_name, main_category_url, sub_category_element.text, sub_category_url)
          get_category_info(sub_category_element.text, sub_category_url)
          loop_count = loop_count + 1
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

def create_category(main_category_name, main_category_url, sub_category_name, sub_category_url)
  Category.create(main_category: main_category_name, main_category_url: main_category_url, sub_category: sub_category_name, sub_category_url: sub_category_url, scrape_category_status: 0)
end