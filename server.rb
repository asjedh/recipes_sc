require 'sinatra'
require 'pry'
require 'pg'

### PATHS
def db_connect
  begin
    connection = PG.connect(dbname: 'recipes')
    yield(connection)
  ensure
    connection.close
  end
end

def import_all_recipes
  query = 'SELECT id, name FROM recipes
  ORDER BY name'
  db_connect do |conn|
    conn.exec_params(query)
  end.to_a
end

def import_recipe_information(recipe_id)
  query = "SELECT recipes.name AS recipe, recipes.description AS description,
          recipes.instructions AS instructions, ingredients.name AS ingredient
          FROM recipes
          LEFT OUTER JOIN ingredients ON recipes.id = ingredients.recipe_id
          WHERE recipes.id = $1"
  db_connect do |conn|
    conn.exec_params(query,[recipe_id])
  end.to_a
end

def get_description(recipe_info)
  recipe_info[0]['description']
end

def get_title(recipe_info)
  recipe_info[0]['recipe']
end

def get_ingredients(recipe_info)
  ingredients = []
  recipe_info.each do |ingredient|
    ingredients << ingredient['ingredient']
  end
  ingredients
end

def get_instructions(recipe_info)
  recipe_info[0]['instructions']
end

#### PATHS
get '/recipes' do
  @recipes = import_all_recipes
  @title = 'Recipes'
  erb :'index.html'
end

get '/recipes/:id' do
  recipe_id = params[:id]
  recipe_info = import_recipe_information(recipe_id)
  @title = get_title(recipe_info)
  @description = get_description(recipe_info)
  @ingredients = get_ingredients(recipe_info)
  @instructions = get_instructions(recipe_info)

  erb :'recipes/recipe.html'
end

get '/' do
  redirect 'recipes'
end
