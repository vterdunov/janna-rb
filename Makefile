SHELL:=/bin/bash

build:
	docker-compose -f docker-compose.dev.yml up --build

run:
	docker-compose -f docker-compose.dev.yml up

shell:
	docker-compose -f docker-compose.dev.yml exec web /bin/sh
	sudo chown -R $(shell whoami):$(shell whoami) ./


test:
	@clear
	docker-compose -f docker-compose.dev.yml exec web /bin/sh -c 'RACK_ENV=test bundle exec rspec'

test-no-tty:
	@clear
	@docker-compose -f docker-compose.dev.yml exec web /bin/sh -c 'RACK_ENV=test bundle exec rspec'
