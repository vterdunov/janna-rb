SHELL:=/bin/bash
.PHONY: doc

build:
	docker build -t janna .

start:
	docker-compose -f docker-compose.dev.yml up --build api worker redis

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

doc-api:
	@docker-compose -f docker-compose.dev.yml exec api rm -rf doc/api
	@docker-compose -f docker-compose.dev.yml exec api yard -o doc/api app/controller/api/

doc:
	@docker-compose -f docker-compose.dev.yml exec api rm -rf doc/janna
	@docker-compose -f docker-compose.dev.yml exec api yard doc -o doc/jana
