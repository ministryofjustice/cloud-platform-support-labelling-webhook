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
  action = push['action']
  issue = push.fetch('issue', {})

  if action == 'opened' && issue['number'].nil? && issue['body']&.match(/bug/)
    client = Octokit::Client.new(:access_token => GITHUB_PERSONAL_ACCESS_TOKEN)
    client.add_labels_to_an_issue('tatyree/can-only-draw-pigs', Integer(issue['number']), ['bug'])
  end
end
