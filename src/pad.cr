require "kemal"
require "ecr"
require "json"

require "sqlite3"

DATA_DIR  = "./data"
DATA_FILE = "#{DATA_DIR}/pad.db"

unless Dir.exists?(DATA_DIR)
  Dir.mkdir_p(DATA_DIR)
end

db = DB.open("sqlite3://#{DATA_FILE}")

def should_return_html(env)
  headers = env.request.headers
  if headers.has_key?("Accept")
    return headers["Accept"].split(',').includes?("text/html")
  end
  false
end

get "/" do |env|
  if should_return_html(env)
    env.response.content_type = "text/html"
    ECR.render("./src/site.ecr")
  else
    # check for secret header, 400 otherwise

    # lookup secret header in database, create if not existing yet

    # return data if all gucci

    env.response.content_type = "text/plain"
  end
end

put "/" do |env|
  # check for nil body and handle better
  text = env.request.body.not_nil!.gets_to_end

  # check for secret header, 400 otherwise

  # lookup secret header in database, if not exist return empty string

  # return data

  env.response.status_code = 204

  ""
end

Kemal.run
