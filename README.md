# cloud-platform-support-labelling-webhook

A webhook for github to ensure that new support issues are labelled correctly when added by non-WebOps team members.

A webhook for github to ensure that new support issues are labelled
correctly when added by non-Webops team members.


## What it does

When a ticket is created on github with a particular bit of text in it (at the moment "impact on service") this app will label that ticket with the label `support-team`. We need to do this as the person raising the ticket cannot add that label themselves as they don't usually have write access to the cloud platform repo.

## How it works

It works as a webhook. Every time a ticket is created on the `ministryofjustice/cloud-platform` repo github posts to the `/webhook` endpoint of this application and the app adds the label and sends that back. 

So to get it working you need to deploy this app and also set up a webhook on the github side that posts to this endpoint on app creation (some info on how to do this to follow).

## How to run it

The application is a very small ruby [Sinatra app](http://sinatrarb.com/). The file `webhook.rb` defines all of the application code including the incoming webhook endpoint (`post '/webhook' do`).

The first time you use the application you need to run the following:

```

$ bundle install
$ bundle exec ruby webhook.rb

```

This should start the [puma](https://github.com/puma/puma) webserver on port 4567. Navigate to localhost:4567 to see the app started.

### Environment variables

The app needs 3 environment variables to run successfully. These are:

* `REPO` - the github repo you are watching for new tickets. Needs to be in the form `<org-name>/<repo-name>`

## Deployment

At the moment:

1. Make your changes locally
2. Build a new docker container (adding the version)
   
    ```
    $ docker build -it support-ticket-labelling:v0.N .
    ```
3. Tag that image and push it to ECR

    ```
    $ docker tag support-labelling-webhook:v0.N 926803513772.dkr.ecr.eu-west-1.amazonaws.com/cloud-platform/support-labelling-webhook:v0.N

    $ docker push 926803513772.dkr.ecr.eu-west-1.amazonaws.com/cloud-platform/support-labelling-webhook:v0.N

    ```
4. Update the `deployment.yaml` file to match the version of the app you have pushed to ECR.
5. Manually (at the moment) deploy the app to kubernetes:
   
   ```
   $ kubectl apply -f kube_deploy/ -n support-labelling-webhook-dev
   ```

## TODO

* Move the `GITHUB_PERSONAL_ACCESS_TOKEN` out of `secrets.yaml` (it doesn't currently work as that is a fake token) and into a proper secret
* Make the app an OAUTH app rather than use a personal access token
* Set up and document the set up of the github webhook


