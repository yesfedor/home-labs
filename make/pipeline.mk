## up: Запустить контейнеры для выбранного ENV
up:
	$(DOCKER_COMPOSE) up -d

## down: Остановить и удалить контейнеры
down:
	$(DOCKER_COMPOSE) down

## build: Пересобрать образы
build:
	$(DOCKER_COMPOSE) build

## restart: Перезапустить сервисы
restart: down up

## ps: Статус контейнеров
ps:
	$(DOCKER_COMPOSE) ps

## logs: Просмотр логов (пример: make logs s=backend)
logs:
	$(DOCKER_COMPOSE) logs -f $(s)
