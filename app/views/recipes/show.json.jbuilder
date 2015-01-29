json.title @recipe.name
json.author @recipe.outside_profile_id
json.description @recipe.description

json.recipe @recipe.recipe_ingredient_lists do |ingredient|
  json.amountUS ingredient.amount_us
  json.unitUS ingredient.unit_us
  json.amountMetric ingredient.amount_metric
  json.unitMetric ingredient.unit_metric
  json.name ingredient.ingredient.ingredient_names.first.sub_name
end
json.images @recipe.img_urls
json.prep_time @recipe.prep_time
json.cook_time @recipe.cook_time
json.ready_time @recipe.ready_time
json.rest_time @recipe.rest_time
json.serving_size @recipe.original_servings_amount
json.serving_type @recipe.original_servings_type
json.instructions @recipe.instructions
json.created_at @recipe.created_at