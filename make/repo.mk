## clone-all: Клонировать все репозитории в shared/app/
clone-all:
	@echo "Cloning repositories for $(ENV)..."
	git clone git@github.com:your-org/frontend.git shared/app/frontend
	git clone git@github.com:your-org/backend.git shared/app/backend
	git clone git@github.com:your-org/tg-bot.git shared/app/tg-bot

## pull-all: Обновить все репозитории
pull-all:
	@cd shared/app/frontend && git pull
	@cd shared/app/backend && git pull
	@cd shared/app/tg-bot && git pull
