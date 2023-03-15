build-account:
	go build -o ./bin/account ./account/main.go

build-membership:
	go build -o ./bin/membership ./membership/main.go

build-all:
	docker-compose build

up-all:
	docker-compose up -d

all: build-all up-all