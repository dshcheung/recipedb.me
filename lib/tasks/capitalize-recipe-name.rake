desc "capitalize recipe name after special characters"
task :capitalize_name => :environment do
  Recipe.where("name LIKE ? or name LIKE ? or name LIKE ?", '%-%', '%(%', '%"%').find_each(batch_size: 100) do |recipe|

    name = recipe.name

    special_characters = ['-', '\(', '"']
    special_characters.each do |character|
      name = capitalize_str(character, name)
    end
    puts name
    
    Recipe.find(recipe.id).update(name: name)
  end
end

def capitalize_str(character, name)
  start_index = 0
  while name.index(/#{character}/, start_index) != nil
    index = name.index(/#{character}/, start_index) + 1
    if name[index] != " " && name[index] != nil
      name[index] = name[index].upcase
    end
    start_index = index
  end
  return name
end
