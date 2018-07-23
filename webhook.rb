require 'json'
require 'octokit'
require 'pp'
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
  pp push.inspect
end
