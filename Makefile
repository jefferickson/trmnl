APP_NAME = trmnl

set-secrets:
	fly secrets set -a $(APP_NAME) --stage \
		AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION)

deploy: set-secrets
	fly deploy

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
		-v /tmp:/data \
		$(APP_NAME) \
		sh
