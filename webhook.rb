require 'json'
require 'octokit'
require 'pp'
require 'sinatra'
require 'sinatra/reloader' if development?

GITHUB_PERSONAL_ACCESS_TOKEN = ENV.fetch('GITHUB_PERSONAL_ACCESS_TOKEN')

@client = Octokit::Client.new(:access_token => GITHUB_PERSONAL_ACCESS_TOKEN)

get '/heartbeat' do
  { labelling_webhook: 'ping' }.to_json
end

post '/webhook' do
  pp JSON.parse(params)
end
