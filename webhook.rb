require 'json'
require 'octokit'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?

GITHUB_PERSONAL_ACCESS_TOKEN = ENV.fetch('GITHUB_PERSONAL_ACCESS_TOKEN')


get '/heartbeat' do
  json labelling_webhook: 'ping'
end

post '/webhook' do
  push = JSON.parse(request.body.read)
  client = Octokit::Client.new(:access_token => GITHUB_PERSONAL_ACCESS_TOKEN)
  puts push
  #client.add_labels_to_an_issue('tatyree/can-only-draw-pigs', push['issue']['number'], ['bug'])
end
