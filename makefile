CONF ?= .

# For local use in this makefile. This does not export to sub-processes.
-include .env.default.properties
-include $(CONF)/.env.properties

MAKEFLAGS    := --silent --always-make
MAKE_CONC    := $(MAKE) -j 128 clear=$(or $(clear),false)

SITE_URL     ?= https://$(SERVER_HOST)
NPM_RUN      := npm run

.DEFAULT_GOAL := npm.dev

# List all make targets.
list:
	grep -E '^\S+:' $(firstword $(MAKEFILE_LIST)) | sed 's/:.*//' | sort | uniq

define HOOK_PRE_COMMIT_CODE
#!/bin/sh
{
	cat .gitignore
	echo
	cat .dockerignore_add
} > .dockerignore
git add .dockerignore
endef
export HOOK_PRE_COMMIT_CODE
HOOK_PRE_COMMIT_FILE := .git/hooks/pre-commit

# Should be run once, after cloning the repo.
hook:
	echo "$${HOOK_PRE_COMMIT_CODE}" > $(HOOK_PRE_COMMIT_FILE)
	chmod +x $(HOOK_PRE_COMMIT_FILE)

# Docker

GIT_SHA ?= $(shell git rev-parse --short=8 HEAD 2>/dev/null || echo "unknown")

DOCKER_LABEL ?= $(KUBE_NAME)
DOCKER_TAG_WITH_GIT_SHA ?= $(REGISTRY_HOST)/$(DOCKER_LABEL):$(GIT_SHA)
DOCKER_TAG_LATEST ?= $(REGISTRY_HOST)/$(DOCKER_LABEL):latest
DOCKER_FILE ?= dockerfile
DOCKER_NO_CACHE ?= $(if $(filter false,$(no_cache)),,--no-cache)

docker: docker.build docker.clean docker.run # Docker build, clean, run

# TODO: only echo in verbose mode.
docker.build:
	echo "build: $(DOCKER_TAG_WITH_GIT_SHA)"
	DOCKER_BUILDKIT=0 docker build --build-arg LABEL=$(DOCKER_LABEL) --progress=plain -f $(DOCKER_FILE) $(DOCKER_NO_CACHE) --memory=16g -t $(DOCKER_TAG_WITH_GIT_SHA) -t $(DOCKER_TAG_LATEST) .

docker.run: $(eval export)
docker.run:
	docker run --rm --env-file .env.default.properties --env-file $(CONF)/.env.properties $(DOCKER_TAG_WITH_GIT_SHA)

# Deletes all untagged images built from our project.
# TODO: only keep the latest, if any.
# TODO: un-hardcode the label both in the Dockerfile and here.
docker.clean:
	docker image prune -f --filter "label=project=$(DOCKER_LABEL)"

docker.ls:
	docker images --filter "label=project=$(DOCKER_LABEL)"

docker.push:
	docker push $(DOCKER_TAG_WITH_GIT_SHA)
	docker push $(DOCKER_TAG_LATEST)


# Kubernetes

KUBE := KUBECONFIG=$(KUBE_CONFIG) kubectl --context $(KUBE_CONTEXT) --cluster "$(KUBE_CLUSTER)" --namespace "$(KUBE_NS)" $@
KUBE_DB_PROXY := $(KUBE) -n $(KUBE_DB_NS) port-forward $(KUBE_DB_POD) $(KUBE_DB_PORT):$(POSTGRES_DB_PORT)

ku.ns.create:
	$(KUBE) create namespace $(KUBE_NS) --dry-run=client -o yaml | $(KUBE) apply -f -

ku.secrets.create: ku.ns.create
ku.secrets.create:
	$(KUBE) create secret generic $(KUBE_NAME)-env-default-properties --from-env-file=.env.default.properties --dry-run=client -o yaml | $(KUBE) apply -f -
	$(KUBE) create secret generic $(KUBE_NAME)-env-properties         --from-env-file=$(CONF)/.env.properties --dry-run=client -o yaml | $(KUBE) apply -f -

ku.del.po.evicted: # Delete Evicted pods.
	$(KUBE) delete po --field-selector="status.phase==Failed"

ku.logs: app ?= $(KUBE_NAME)
ku.logs:
	echo "app=$(app)"
	$(KUBE) logs -f --all-containers -l app=$(app) --max-log-requests=8 --timestamps=false --tail=-1

ku.deploy: ku.secrets.create
ku.deploy: $(eval export)
ku.deploy: export VERSION=$(GIT_SHA)
ku.deploy:
	envsubst < ./k8s.yaml | $(KUBE) apply -f -
	$(MAKE) ku.restart

ku.update: docker.build
ku.update: docker.push
ku.update:
	$(MAKE) ku.deploy
	$(KUBE) wait --for=condition=ready pod -l app=$(KUBE_NAME) --timeout=60s
	$(MAKE) npm.build
	$(MAKE) ku.sync
	$(MAKE) ku.sync.img
	$(MAKE) ku.stamp

ku.delete: $(eval export)
ku.delete:
	$(KUBE) delete secret $(KUBE_NAME)-env-default-properties
	$(KUBE) delete secret $(KUBE_NAME)-env-properties
	envsubst < ./k8s.yaml | $(KUBE) delete -f -

ku.set.image:
	$(KUBE) set image deploy $(KUBE_NAME) $(KUBE_NAME)=$(DOCKER_TAG_LATEST)

ku.restart:
	$(KUBE) rollout restart deploy $(KUBE_NAME)

ku.refresh:
	$(MAKE) ku.deploy
	$(MAKE) ku.restart

ku.wait.success: app ?= $(APP_NAME)
ku.wait.success:
	$(KUBE) wait --for=condition=ready pod -l app=$(app)

ku.db.proxy:
	$(KUBE_DB_PROXY)
	echo "Waiting for port $(KUBE_DB_PORT) to be ready..."
	while ! nc -z localhost $(KUBE_DB_PORT) 2>/dev/null; do sleep 0.1; done
	echo "Connection established"

DB_PROXY_PID := .db_proxy.pid

ku.pg.dump:
	echo "Open PG connection..."
	$(KUBE_DB_PROXY) > /dev/null 2>&1 & echo $$! > $(DB_PROXY_PID)
	echo "Waiting for port $(KUBE_DB_PORT) to be ready..."
	while ! nc -z localhost $(KUBE_DB_PORT) 2>/dev/null; do sleep 0.1; done
	echo "Connection established"
	$(MAKE) pg.dump
	kill `cat $(DB_PROXY_PID)` 2>/dev/null || true
	rm -f $(DB_PROXY_PID)
	echo "Done PG dump"

ku.des:
	$(KUBE) describe deploy/$(KUBE_NAME)

ku.po:
	$(KUBE) get po

ku.app-pod:
	$(eval POD = $(shell $(KUBE) get po -l app=$(KUBE_NAME) -o jsonpath='{.items[0].metadata.name}'))
	echo $(POD)

ku.ssh: ku.app-pod
ku.ssh:
	$(KUBE) exec -it $(POD) -- sh

ku.cp-to: ku.app-pod
ku.cp-to:
	$(KUBE) cp $(src) $(POD):/usr/share/nginx/html

ku.sync: ku.app-pod
ku.sync:
	printf '#!/bin/sh\nshift\n$(KUBE) exec -i $(POD) -- "$$@"\n' > /tmp/.krsync
	chmod +x /tmp/.krsync
	rsync -avz --delete --blocking-io -e /tmp/.krsync ./dist/ _:/usr/share/nginx/html/
	rm -f /tmp/.krsync
	$(KUBE) exec $(POD) -- find /usr/share/nginx/html -name '*.html' -exec sed -i 's/__VERSION__/$(GIT_SHA)/g' {} +
	$(KUBE) exec $(POD) -- sed -i 's|__SITE_URL__|https://$(SERVER_HOST)|g' /usr/share/nginx/html/robots.txt
	$(KUBE) exec $(POD) -- chmod -R a+r /usr/share/nginx/html

ku.resync: npm.build
	$(MAKE) ku.sync

ku.deployed-sha:
	$(eval DEPLOYED_SHA := $(shell curl -sf https://$(SERVER_HOST)/version.txt | grep -xE '[0-9a-f]{8,40}'))

ku.sync.img: ku.deployed-sha
	@if [ -z "$(DEPLOYED_SHA)" ]; then \
		$(MAKE) ku.sync.img.full; \
	elif [ -z "$$(git diff --name-only $(DEPLOYED_SHA) HEAD -- public/img/)" ]; then \
		echo "No image changes since $(DEPLOYED_SHA)"; \
	else \
		$(MAKE) ku.sync.img.diff; \
	fi

ku.sync.img.full: ku.app-pod
	echo "No version.txt on server -- syncing ALL images..."
	cd dist && tar cf - img/ | $(KUBE) exec -i $(POD) -- tar xf - -C /usr/share/nginx/html
	$(KUBE) exec $(POD) -- chmod -R a+r /usr/share/nginx/html/img

ku.sync.img.diff: ku.app-pod ku.deployed-sha
	echo "Syncing changed images since $(DEPLOYED_SHA)..."
	git diff --name-only --diff-filter=d $(DEPLOYED_SHA) HEAD -- public/img/ | sed 's|^public/||' | (cd dist && tar cf - -T -) | $(KUBE) exec -i $(POD) -- tar xf - -C /usr/share/nginx/html
	$(KUBE) exec $(POD) -- chmod -R a+r /usr/share/nginx/html/img

ku.stamp: ku.app-pod
	$(KUBE) exec $(POD) -- sh -c 'echo "$(GIT_SHA)" > /usr/share/nginx/html/version.txt'

stripe.setup:
	node scripts/create-stripe-products.js

srv:
	srv -p 51468 -d ./static

# Astro
npm.dev:
	$(NPM_RUN) dev

npm.build:
	$(NPM_RUN) build
	echo "$(GIT_SHA)" > dist/version.txt

npm.preview:
	$(NPM_RUN) preview