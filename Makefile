APP_NAME = jperickson/trmnl

install-dev-tools:
	pip install --upgrade pip
	pip install -r requirements.txt
	pip install -r requirements-dev.txt

lint-and-typecheck: install-dev-tools
	ruff check --fix .
	ruff format .
	mypy --strict .

build:
	DOCKER_DEFAULT_PLATFORM=linux/amd64 docker build . -t $(APP_NAME)

push-image: lint-and-typecheck build
	docker push $(APP_NAME)

run-locally: build
	docker run \
	    -it \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		$(APP_NAME)
