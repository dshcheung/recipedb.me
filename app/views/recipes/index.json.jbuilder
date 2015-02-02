json.recipes @recipes do |recipe|
  json.id recipe.id
  json.title recipe.name
  json.author do
    json.display_format recipe.outside_profile.display_format
    json.username recipe.outside_profile.username
    json.full_name recipe.outside_profile.full_name
    json.site_name recipe.outside_profile.site_name
    json.profile_url recipe.outside_profile.outside_profile_url
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