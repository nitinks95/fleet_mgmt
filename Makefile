.PHONY: help

help:
    @echo "fleet_mgmt:0.1.0"

build: ## Build the Docker image
	docker build -t fleet_mgmt:0.1.0 .

run: ## Create and run the container
	docker run -it fleet_mgmt:0.1.0