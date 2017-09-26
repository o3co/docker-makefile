include Makefile.inc

VERSION := $(shell cat VERSION)
VERSION_MINOR := $(shell echo ${VERSION} | ( IFS=".$${IFS}" ; read A B C && echo $$A.$$B ) )
VERSION_MAJOR := $(shell echo ${VERSION} | ( IFS=".$${IFS}" ; read A B C && echo $$A ) )

define USAGE
Commands:
  build		Build docker image and tag versions.
  release	Push docker images and increment version

endef
export USAGE

.PHONY: help
help:
	@echo Docker info:
	@echo IMAGE:	  ${REPOS}/${IMAGE}
	@echo "VERSIONS:	${VERSION}, ${VERSION_MINOR}, ${VERSION_MAJOR}"

	@echo "$${USAGE}"

.PHONY: build 
build: docker-build-latest docker-tag-versions

# Push the current version images and increment version
.PHONY: release
release: docker-push-latest docker-push-versions increment-version

docker-build-latest:
	docker build . -t ${REPOS}/${IMAGE}

docker-tag-versions:
	docker tag ${REPOS}/${IMAGE}:latest ${REPOS}/${IMAGE}:${VERSION}
	docker tag ${REPOS}/${IMAGE}:latest ${REPOS}/${IMAGE}:${VERSION_MINOR}
	docker tag ${REPOS}/${IMAGE}:latest ${REPOS}/${IMAGE}:${VERSION_MAJOR}

docker-login:  docker-login-none

docker-login-none:
	@echo "NO LOGIN"

docker-login-ecr:
	eval $$(aws ecr get-login --region ap-northeast-1 --no-include-email)

docker-push-latest: docker-login
	docker push ${REPOS}/${IMAGE}:latest

docker-push-versions: docker-login
	docker push ${REPOS}/${IMAGE}:${VERSION}
	docker push ${REPOS}/${IMAGE}:${VERSION_MINOR}
	docker push ${REPOS}/${IMAGE}:${VERSION_MAJOR}

#echo ${NEXT_VERSION} > VERSION
increment-version: 
	$(eval NEXT_VERSION := $(shell echo ${VERSION} | ( IFS=".$${IFS}"; read A B C && echo $$A.$$B.$$((C + 1)))))
	echo ${NEXT_VERSION} > VERSION

