FROM node:22.12

ARG ENVIRONMENT_NAME
ENV ENVIRONMENT_NAME=${ENVIRONMENT_NAME}

WORKDIR /app

# Копируем файлы зависимостей из контекста (shared/app/frontend)
COPY package.json package-lock.json ./

RUN npm i @rollup/rollup-linux-x64-gnu --save-dev
RUN npm ci

COPY . .

# Копируем конфиг. В новой структуре они могут лежать в корне проекта,
# но если они внутри репозитория фронтенда, оставляем как есть.
RUN cp ./environments/${ENVIRONMENT_NAME}.env .env

RUN npx buf generate
RUN npm run build

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
