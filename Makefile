# Declarar que scripts se van a invocar cuando se llame a make asecas
all: clone_site nodemodules test sonar create_imagen run_container create_build generate_artefact
.PHONY: all

# Variables!
NOW = $(shell date)
GITHUB_PAGES_REPO = https://github.com/McgyverVargas/vue_jenkins.git
NAME_PROJECT = vue-example
NAME_IMAGEN = idproyecto-dev
TAG_IMAGEN = latest
NAME_CONTAINER = proyecto-dev
PUERTO_IMAGEN = 9090
NAME_FINAL = $(NAME_CONTAINER)$(TAG_NAME)$(PUERTO_IMAGEN)
ARCHIVOS=$(shell docker ps -q --filter name=$(NAME_FINAL))

# Distintos scripts de la pipeline de despliegue
clone_site:
	@printf "\033[0;32mCloning site from remote...\033[0m\n"
	cd
	rm -rf $(NAME_PROJECT)
	git clone $(GITHUB_PAGES_REPO) $(NAME_PROJECT)

nodemodules:
	@printf "\033[0;32mDownload site from remote...\033[0m\n"
	npm i && npm cache clean --force

test:
	@printf "\033[0;32mTesting content...\033[0m\n"
	npm run test:unit

sonar:
	@printf "\033[0;32mScanning content...\033[0m\n"
	./node_modules/sonarqube-scanner/dist/bin/sonar-scanner

create_imagen:
	@printf "\033[0;32mEliminating content...\033[0m\n"
	@if [ -z "$(ARCHIVOS)" ]; then echo "\033[0;32mNot Exist content...\033[0m\n"; else docker stop $(NAME_FINAL); docker rm -f $(NAME_FINAL); fi
	#@if [ -z "$(ARCHIVOS)" ]; then echo "\033[0;32mNot Exist content...\033[0m\n"; else docker rmi -f $(NAME_IMAGEN):$(TAG_IMAGEN); fi
	@printf "\033[0;32mCreating content...\033[0m\n"
	docker build -t $(NAME_IMAGEN):$(TAG_IMAGEN) .

run_container:
	@printf "\033[0;32mCreating content...\033[0m\n"
	docker run -dp $(PUERTO_IMAGEN):80 --name $(NAME_FINAL) $(NAME_IMAGEN):$(TAG_IMAGEN)

create_build:
	@printf "\033[0;32mBuilding content...\033[0m\n"
	npm run build

generate_artefact:
	@printf "\033[0;32mGenerating content...\033[0m\n"
	aws s3 cp --recursive dist/ s3://devexamplevue/dist/ --acl bucket-owner-full-control --recursive
