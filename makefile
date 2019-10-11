IMAGE := ministryofjustice/cloud-platform-support-labelling-webhook
VERSION := 0.7

build:
				 docker build -t $(IMAGE):$(VERSION) .

push:
				 docker push $(IMAGE):$(VERSION)

pull:
				 docker pull $(IMAGE):$(VERSION)

