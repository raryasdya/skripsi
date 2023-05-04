include .env


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


# GKE Cluster
enable-container:
	gcloud services enable container.googleapis.com 
create-cluster:
	gcloud container clusters create ${CLUSTER_NAME} --cluster-version latest \
	--num-nodes 1 --zone ${ZONE} --project ${PROJECT_ID}

cluster-all: enable-container create-cluster


# Artifact Registry
create-artifact:
	gcloud artifacts repositories create ${REPO_NAME} --project=${PROJECT_ID} \
	--repository-format=docker --location=${REGION} --description="Skripsi Image Repository"


submit-account:
	gcloud builds submit \
	--tag ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/account ./account
submit-membership:
	gcloud builds submit \
  --tag ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/membership ./membership

submit-all: submit-account submit-membership


# Istio Installation
get-creds:
	gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE}
install-istio-demo:
	istioctl install --set profile=demo -y
enable-injection:
	kubectl label namespace default istio-injection=enabled

install-istio: get-creds install-istio-demo enable-injection


# Istio
deploy-membership:
	kubectl apply -f ./config/kubernetes/membership.yaml
deploy-account:
	kubectl apply -f ./config/kubernetes/account.yaml
deploy-gateway:
	kubectl apply -f ./config/istio/gateway.yaml
deploy-membership-vs:
	kubectl apply -f ./config/istio/membership-virtual-service.yaml
deploy-account-vs:
	kubectl apply -f ./config/istio/account-virtual-service.yaml
	
deploy-all: deploy-membership deploy-account deploy-gateway deploy-membership-vs deploy-account-vs


delete-membership:
	kubectl delete -f ./config/kubernetes/membership.yaml
delete-account:
	kubectl delete -f ./config/kubernetes/account.yaml
delete-gateway:
	kubectl delete -f ./config/istio/membership-gateway.yaml
delete-membership-vs:
	kubectl delete -f ./config/istio/membership-virtual-service.yaml
delete-account-vs:
	kubectl delete -f ./config/istio/account-virtual-service.yaml

delete-all: delete-membership delete-account delete-gateway delete-membership-vs delete-account-vs


set-mtls:
	kubectl apply -f ./config/istio/mtls.yaml


install-cert-manager:
	kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml

	
set-cert-issuer:
	kubectl apply -f ./config/cert/cert-issuer.yaml
set-certificate:
	kubectl apply -f ./config/cert/certificate.yaml

set-cert: set-cert-issuer set-certificate


get-ip:
	kubectl get svc istio-ingressgateway -n istio-system


install-kiali:
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/kiali.yaml
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/prometheus.yaml
run-kiali:
	kubectl port-forward svc/kiali -n istio-system 20001


# Cleanup
cleanup-cluster:
	gcloud container clusters delete ${CLUSTER_NAME} \
	    --zone ${ZONE}
cleanup-repo:
	gcloud artifacts docker images delete \
		${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/account
	gcloud artifacts docker images delete \
		${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/membership

cleanup-all: cleanup-cluster cleanup-repo