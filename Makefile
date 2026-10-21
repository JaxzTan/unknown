COMPOSE     := docker compose
COMPOSE_DEV := docker compose -f compose.yaml -f compose.dev.yaml

.DEFAULT_GOAL := up
.PHONY: up dev down logs ps migrate studio clean fclean re help

up: ## Build and run the production-like stack (default)
	$(COMPOSE) up --build

dev: ## Run the dev stack in watch mode (hot reload)
	$(COMPOSE_DEV) up --build --watch

down: ## Stop all containers
	$(COMPOSE_DEV) down --remove-orphans

logs: ## Follow logs of all services
	$(COMPOSE_DEV) logs -f

ps: ## List running services
	$(COMPOSE_DEV) ps

migrate: ## Apply Prisma migrations to Supabase (runs locally, uses DIRECT_URL)
	cd backend && npx prisma migrate deploy

studio: ## Open Prisma Studio against Supabase
	cd backend && npx prisma studio

clean: ## Stop containers, remove volumes (redis data) and project images
	$(COMPOSE_DEV) down --remove-orphans --volumes --rmi local

fclean: clean ## clean + remove all images used by the stack (incl. node, flutter, redis, nginx)
	$(COMPOSE_DEV) down --remove-orphans --volumes --rmi all

re: fclean up ## Full rebuild from scratch

help: ## Show this help
	@grep -E '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  make %-8s %s\n", $$1, $$2}'
