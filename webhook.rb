require 'json'
require 'octokit'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?

set :bind => '0.0.0.0', :server => :puma

GITHUB_PERSONAL_ACCESS_TOKEN = ENV.fetch('GITHUB_PERSONAL_ACCESS_TOKEN')
#REPO = 'ministryofjustice/cloud-platform'
#BUG_REPORT_REGEX = %r{Service name}
REPO = 'tatyree/can-only-draw-pigs'
BUG_REPORT_REGEX = %r(impact on the service)i


get '/heartbeat' do
  json labelling_webhook: 'ping'
end

post '/webhook' do
  push = JSON.parse(request.body.read)
  action = push['action']
  issue = push.fetch('issue', {})

  if action == 'opened' && !issue['number'].nil? && issue['body']&.match(BUG_REPORT_REGEX)
    client = Octokit::Client.new(:access_token => GITHUB_PERSONAL_ACCESS_TOKEN)
    client.add_labels_to_an_issue(REPO, Integer(issue['number']), ['bug'])
  end

  status :ok
end
