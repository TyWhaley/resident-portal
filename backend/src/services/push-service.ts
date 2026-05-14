import admin from 'firebase-admin';
import { env } from '../config/env.js';
import { getPushTokensForTenant, disableStalePushTokens } from '../repositories/device-repository.js';
import type { PushPayload } from '../domain/types.js';

let initialized = false;

function initFirebase(): void {
  if (initialized) {
    return;
  }

  const serviceAccount = JSON.parse(env.FIREBASE_SERVICE_ACCOUNT_JSON) as admin.ServiceAccount;
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  initialized = true;
}

export async function sendTenantPush(tenantId: string, payload: PushPayload): Promise<void> {
  initFirebase();
  const tokens = await getPushTokensForTenant(tenantId);
  if (tokens.length === 0) {
    return;
  }

  const response = await admin.messaging().sendEachForMulticast({
    tokens,
    notification: {
      title: payload.title,
      body: payload.body
    },
    data: {
      deep_link: payload.deepLink,
      event_type: payload.eventType,
      entity_id: payload.entityId ?? '',
      tenant_id: payload.tenantId ?? tenantId
    },
    android: {
      priority: 'high'
    },
    apns: {
      payload: {
        aps: {
          sound: 'default'
        }
      }
    }
  });

  const staleTokens: string[] = [];
  response.responses.forEach((res, idx) => {
    if (
      res.error &&
      (res.error.code === 'messaging/registration-token-not-registered' ||
       res.error.code === 'messaging/invalid-registration-token')
    ) {
      staleTokens.push(tokens[idx]);
    }
  });

  if (staleTokens.length > 0) {
    await disableStalePushTokens(staleTokens);
  }
}

export async function sendTopicAnnouncement(topic: string, payload: PushPayload): Promise<void> {
  initFirebase();
  await admin.messaging().send({
    topic,
    notification: {
      title: payload.title,
      body: payload.body
    },
    data: {
      deep_link: payload.deepLink,
      event_type: payload.eventType,
      entity_id: payload.entityId ?? '',
      tenant_id: payload.tenantId ?? ''
    }
  });
}
