FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY tsconfig.json vitest.config.ts .eslintrc.cjs ./
COPY src ./src
COPY scripts ./scripts
COPY tests ./tests
RUN npm run build
EXPOSE 8080
CMD ["npm", "run", "start"]
