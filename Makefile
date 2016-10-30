SHELL:=/bin/bash

build:
	docker build -t janna .

start:
	docker-compose -f docker-compose.dev.yml up --build

shell:
	docker-compose -f docker-compose.dev.yml exec $(filter-out $@,$(MAKECMDGOALS)) /bin/sh
	sudo chown -R $(shell whoami):$(shell whoami) ./

test:
	@clear
	docker-compose -f docker-compose.dev.yml exec api /bin/sh -c 'RACK_ENV=test bundle exec rspec'

test-no-tty:
	@clear
	@docker-compose -f docker-compose.dev.yml exec api /bin/sh -c 'RACK_ENV=test bundle exec rspec'

pull:
	docker-compose -f docker-compose.dev.yml pull
