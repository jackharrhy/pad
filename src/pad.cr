require "kemal"
require "ecr"
require "json"

PAD_DIR = "./data"
PAD_FILE = "pad.txt"
PAD = "#{PAD_DIR}/#{PAD_FILE}"

unless Dir.exists?(PAD_DIR) && File.exists?(PAD)
  Dir.mkdir_p(PAD_DIR)
  File.write(PAD, "")
end

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
    env.response.content_type = "text/plain"
    File.read(PAD)
  end
end

put "/" do |env|
  text = env.request.body.not_nil!.gets_to_end

  env.response.status_code = 204
  File.write(PAD, text)
end

Kemal.run
