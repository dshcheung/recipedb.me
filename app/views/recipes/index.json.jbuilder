json.recipes @recipes do |recipe|
  json.id recipe.id
  json.title recipe.name

  if @bookmarks.any?
    if @bookmarks.where(recipe_id: recipe.id).any?
      json.is_liked true
    else
      json.is_liked false
    end
  else
    json.is_liked false
  end
  
  if recipe.outside_profile_id.nil?
    json.author do 
      json.display_format 0
      json.username recipe.user.username
      json.profile_url recipe.user.id
    end
  else
    json.author do
      json.display_format recipe.outside_profile.display_format
      json.username recipe.outside_profile.username
      json.full_name recipe.outside_profile.full_name
      json.site_name recipe.outside_profile.site_name
      json.profile_url recipe.outside_profile.outside_profile_url
    end
  end

  json.description recipe.description
  json.images recipe.img_urls
  json.prep_time recipe.prep_time
  json.cook_time recipe.cook_time
  json.ready_time recipe.ready_time
  json.rest_time recipe.rest_time
  json.serving_size recipe.original_servings_amount
  json.serving_type recipe.original_servings_type
  json.instructions recipe.instructions
end