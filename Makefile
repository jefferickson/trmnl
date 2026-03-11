APP_NAME = trmnl

lint-and-typecheck:
	ruff check --fix .
	ruff format .
	mypy --strict .

build-locally:
	docker build . -t $(APP_NAME)

run-locally: build-locally
	docker run \
	    -it \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		$(APP_NAME) \
		sh
