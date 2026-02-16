import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { pool } from './pool.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

async function migrate(): Promise<void> {
  for (let attempt = 1; attempt <= 20; attempt += 1) {
    try {
      await pool.query('SELECT 1');
      break;
    } catch (error) {
      if (attempt === 20) {
        throw error;
      }
      console.log(`Database not ready (attempt ${attempt}/20), retrying...`);
      await new Promise((resolve) => setTimeout(resolve, 1500));
    }
  }

  const migrationsDir = path.join(__dirname, 'migrations');
  const files = (await fs.readdir(migrationsDir)).filter((f) => f.endsWith('.sql')).sort();
  for (const file of files) {
    const sql = await fs.readFile(path.join(migrationsDir, file), 'utf8');
    await pool.query(sql);
    console.log(`Applied migration: ${file}`);
  }
  await pool.end();
}

migrate().catch((error) => {
  console.error(error);
  process.exit(1);
});
