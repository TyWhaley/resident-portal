import { createTenantLinkToken } from '../src/repositories/link-repository.js';

const tenantId = process.argv[2];

if (!tenantId) {
  console.error('Usage: npm run admin:link-token -- <tenant_id>');
  process.exit(1);
}

const token = createTenantLinkToken(tenantId);
console.log(JSON.stringify({ tenant_id: tenantId, tenant_link_token: token }, null, 2));
