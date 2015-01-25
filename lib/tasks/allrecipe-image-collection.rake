desc "scrape the image collection pages for recipe images"
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
        puts "scraping ----> " + url
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