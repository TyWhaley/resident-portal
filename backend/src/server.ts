import { env } from './config/env.js';
import { buildApp } from './app.js';

const app = buildApp();

async function shutdown(signal: string) {
  app.log.info(`${signal} received, shutting down gracefully`);
  await app.close();
  process.exit(0);
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

app
  .listen({ port: env.PORT, host: '0.0.0.0' })
  .then(() => {
    app.log.info(`Server listening on ${env.PORT}`);
  })
  .catch((error) => {
    app.log.error(error);
    process.exit(1);
  });
