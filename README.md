# cloud-platform-support-labelling-webhook

A webhook for github to ensure that new support issues are labelled correctly when added by non Cloud Platform team members.


## What it does

When a ticket is created on github with a particular bit of text in it (at the moment "impact on service") this app will label that ticket with the label `support-team`. We need to do this as the person raising the ticket cannot add that label themselves as they don't usually have write access to the cloud platform repo.

## How it works

It works as a webhook. Every time a ticket is created on the `ministryofjustice/cloud-platform` repo github posts to the `/webhook` endpoint of this application and the app adds the label and sends that back. 

So to get it working you need to deploy this app and also set up a webhook on the github side that posts to this endpoint on app creation (some info on how to do this to follow).

## How to run it

The application is a very small ruby [Sinatra app](http://sinatrarb.com/). The file `webhook.rb` defines all of the application code including the incoming webhook endpoint (`post '/webhook' do`).

The first time you use the application you need to:

1. Set an environment variable for `GITHUB_PERSONAL_ACCESS_TOKEN`, it won't start up without this, you can use a fake one if you just want to try running the app but not using it. See [access token](#access-token) below for more info on how to set this properly. 

2. Run the following:

```
$ bundle install
$ bundle exec ruby webhook.rb
```

This should start the [puma](https://github.com/puma/puma) webserver on port 4567. Navigate to localhost:4567 to see the app started.

### Access token

The app needs you to provide a personal access token for the GitHub API as an environment variable to run successfully. The access token should be set as `GITHUB_PERSONAL_ACCESS_TOKEN`. After much experimentation with the various OAUTH flows that github implements we felt this was the best approach. You can create a personal access token for your user in your GitHub security settings. 

We recommend that you create a token for the `cloud-platform-moj` user. This one can be accessed by all team members so when someone leaves the app won't stop working and if you need to roll the credentials anyone in the team can do it.

### Other variables

* `REPO` - the github repo you are watching for new tickets. Needs to be in the form `<org-name>/<repo-name>`. It is currently defined in the `webhook.rb`.
 
* `BUG_REPORT_REGEX` - the regular expression that you want to search for in a ticket. When the webhook finds a ticket that matches this regular expression it will label that ticket. It is currently defined in the `webhook.rb`.

## Deployment

At the moment:

1. Make your changes locally.
2. Build a new docker container (adding the version as a tag, that's just how I do it)
   
    ```
    $ docker build -it support-ticket-labelling:v0.n .
    ```
3. Tag that image and push it to ECR

    ```
    $ docker tag support-labelling-webhook:v0.n 926803513772.dkr.ecr.eu-west-1.amazonaws.com/cloud-platform/support-labelling-webhook:v0.n

    $ docker push 926803513772.dkr.ecr.eu-west-1.amazonaws.com/cloud-platform/support-labelling-webhook:v0.n
    ```
4. Update the `deployment.yaml` file to match the version of the app you have pushed to ECR

```
    spec:
      containers:
      - name: support-ticket-labelling
        image: 926803513772.dkr.ecr.eu-west-1.amazonaws.com/cloud-platform/support-labelling-webhook:v0.n
        ports:
```

5. Add the personal access token as a secret to kubernetes. If you name it right it will be picked up as an environment variable by the definition in `deployment.yaml`, the secret object name needs to be `github-access-token` and the key for this particular secret is `github_access_token`. No base64 needed as we are using `--from-literal`:

```
kubectl create secret generic github-access-token --from-literal=github_access_token=<a-personal-access-token> -n support-labelling-webhook-dev
```

6. Manually (at the moment) deploy the app to kubernetes:
   
   ```
   $ kubectl apply -f kube_deploy/ -n support-labelling-webhook-dev
   ```

7. Set up the webhook in GitHub. On the repo that you are setting the webhook up go to `Settings > Webhooks` and hit the "Add webhook" button. You need to set:

* `Payload URL` to the url of the webhook running on kubernetes (remember to add `/webhook`)
* For `Which events would you like to trigger this webhook?` select `Let me select individual events` and pick the `Issues` option, that should be all you need for the webhook to work. 

8. Create a test issue on the repo, with the right words to match the regex, and watch it get labelled!

## TODO

* Add some tests. 


