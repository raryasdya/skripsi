# Services
build-account:
	go build -o ./bin/account ./account/main.go

build-membership:
	go build -o ./bin/membership ./membership/main.go

build-all:
	docker-compose build

up-all:
	docker-compose up -d

all: build-all up-all


# Artifact Registry
submit-account:
	gcloud builds submit \
	--tag asia-southeast1-docker.pkg.dev/skripsi-exploration/skripsi-repo/account ./account

submit-membership:
	gcloud builds submit \
  --tag asia-southeast1-docker.pkg.dev/skripsi-exploration/skripsi-repo/membership ./membership

submit-all: submit-account submit-membership

# Istio
deploy-membership:
	kubectl apply -f ./networking/membership.yaml
deploy-account:
	kubectl apply -f ./networking/account.yaml
deploy-gateway:
	kubectl apply -f ./networking/gateway.yaml
deploy-membership-vs:
	kubectl apply -f ./networking/membership-virtual-service.yaml
deploy-account-vs:
	kubectl apply -f ./networking/account-virtual-service.yaml
	
deploy-all: deploy-membership deploy-account deploy-gateway deploy-membership-vs deploy-account-vs


delete-membership:
	kubectl delete -f ./networking/membership.yaml
delete-account:
	kubectl delete -f ./networking/account.yaml
delete-gateway:
	kubectl delete -f ./networking/membership-gateway.yaml
delete-membership-vs:
	kubectl delete -f ./networking/membership-virtual-service.yaml
delete-account-vs:
	kubectl delete -f ./networking/account-virtual-service.yaml

delete-all: delete-membership delete-account delete-gateway delete-membership-vs delete-account-vs


get-ip:
	kubectl get svc istio-ingressgateway -n istio-system