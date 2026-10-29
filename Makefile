.PHONY: check-integration stack-restart tofu-init tofu-plan tofu-apply agent-restart deploy-local
.NOTPARALLEL: deploy-local

version ?= 9.5.5
export INTEGRATION

check-integration:
	@case "$$INTEGRATION" in \
		''|*[!a-z0-9_-]*|[-_]*) \
			printf '%s\n' 'Set INTEGRATION to an integration name, e.g. make deploy-local INTEGRATION=github_issues.' >&2; exit 1 ;; \
	esac; \
	if [ ! -f "infrastructure/$$INTEGRATION/main.tf" ] || \
	   [ ! -f "integrations/$$INTEGRATION/compose.yml" ] || \
	   [ ! -f "integrations/$$INTEGRATION/terraform.tfvars" ]; then \
		printf 'Unknown or incomplete integration: %s\n' "$$INTEGRATION" >&2; exit 1; \
	fi

stack-restart:
	elastic-package stack down && elastic-package stack up --version=$(version) -d -v

tofu-init: check-integration
	./scripts/with-env.sh tofu -chdir="infrastructure/$$INTEGRATION" init

tofu-plan: check-integration
	./scripts/with-env.sh tofu -chdir="infrastructure/$$INTEGRATION" plan -var-file="../../integrations/$$INTEGRATION/terraform.tfvars" -out=deploy.tfplan

tofu-apply: check-integration
	./scripts/with-env.sh tofu -chdir="infrastructure/$$INTEGRATION" apply deploy.tfplan

agent-restart: check-integration
	docker compose --project-directory . -f "integrations/$$INTEGRATION/compose.yml" rm --stop --force "$$INTEGRATION"
	docker compose --project-directory . -f "integrations/$$INTEGRATION/compose.yml" up "$$INTEGRATION"

deploy-local: tofu-init tofu-plan tofu-apply agent-restart
