REFERENCE := reference-app

build:
	cd ${REFERENCE} && docker-compose build -m grpc_tools.protoc -I ./${PROTO_SRC_DIR} --python_out=./${PROTO_TARGET_DIR_LOCATION} --grpc_python_out=./${PROTO_TARGET_DIR_LOCATION} ./${PROTO_SRC_DIR}/*.proto
	cp -r ${API}/location/grpc-producer/${PROTO_TARGET_DIR_LOCATION}/*  ${API}/location/consumer/${PROTO_TARGET_DIR_LOCATION}/

up:
	cd ${REFERENCE} && docker-compose up --build -d

up:
	cd ${REFERENCE} && docker-compose up --build -d

down:
	cd ${REFERENCE} && docker-compose down

push:
	cd ${REFERENCE} && docker-compose push