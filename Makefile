REFERENCE := reference-app

up:
	cd ${REFERENCE} && docker-compose up --build -d

down:
	cd ${REFERENCE} && docker-compose down

build:
	cd ${REFERENCE} && docker-compose build

push:
	cd ${REFERENCE} && docker-compose push

port-forward:
	kubectl port-forward -n monitoring svc/prometheus-grafana --address 0.0.0.0 3000:80