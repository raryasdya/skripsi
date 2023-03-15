hello:
	echo "Hello"

run-account:
	go run ./account/main.go

run-membership:
	go run ./membership/main.go

run: run-account run-membership

run-2:
	go run ./account/main.go \
	&& go run ./membership/main.go