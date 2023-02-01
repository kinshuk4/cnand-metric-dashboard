REFERENCE := reference-app

up: 
	@vagrant up

down:
	@vagrant down

app-up:
	cd ${REFERENCE} && docker-compose up --build -d

app-down:
	cd ${REFERENCE} && docker-compose down

app-build:
	cd ${REFERENCE} && docker-compose build

app-push:
	cd ${REFERENCE} && docker-compose push

backend-up:
	cd ${REFERENCE} && docker-compose up --build backend

backend-fmt:
	cd ${REFERENCE}/backend && black .

frontend-up:
	cd ${REFERENCE} && docker-compose up --build frontend

frontend-fmt:
	cd ${REFERENCE}/frontend && black .

trial-up:
	cd ${REFERENCE} && docker-compose up --build trial

trial-fmt:
	cd ${REFERENCE}/trial && black .

setup-alias:
	alias k='kubectl'
	alias km='kubectl -n monitoring'
	alias ko='kubectl -n observability'
	alias ll='ls -l'

setup-helm:
	curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

setup-monitoring:
	kubectl create namespace monitoring
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add stable https://charts.helm.sh/stable
	helm repo update
	helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --kubeconfig /etc/rancher/k3s/k3s.yaml

setup-observability:
	kubectl create namespace observability
	kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/crds/jaegertracing.io_jaegers_crd.yaml
	kubectl create -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/service_account.yaml
	kubectl create -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role.yaml
	kubectl create -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role_binding.yaml
	kubectl create -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/operator.yaml
	kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/cluster_role.yaml
	kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/cluster_role_binding.yaml

setup-jaeger-all-in-one:
	kubectl apply -n observability -f /vagrant/manifests/other/jaeger-app.yaml

setup-app:
	kubectl apply -f /vagrant/manifests/app/

grafana-port-forward:
	kubectl port-forward -n monitoring svc/prometheus-grafana --address 0.0.0.0 3000:80

jaeger-port-forward:
	kubectl port-forward -n observability svc/simpletest-query --address 0.0.0.0 16686:16686
	
frontend-port-forward:
	kubectl port-forward svc/frontend-service --address 0.0.0.0 8080:8080

