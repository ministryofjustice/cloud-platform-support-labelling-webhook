require 'json'
require 'octokit'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?

GITHUB_PERSONAL_ACCESS_TOKEN = ENV.fetch('GITHUB_PERSONAL_ACCESS_TOKEN')

@client = Octokit::Client.new(:access_token => GITHUB_PERSONAL_ACCESS_TOKEN)

get '/heartbeat' do
  json labelling_webhook: 'ping'
end

post '/webhook' do
  push = JSON.parse(request.body.read)
  puts push['body']
  puts push.map{ |k, v| k }
end
