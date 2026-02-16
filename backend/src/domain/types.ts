export type Platform = 'ios' | 'android';

export interface DeviceRegistrationInput {
  installationId: string;
  platform: Platform;
  pushToken: string;
  tenantLinkToken?: string;
  tenantId?: string;
  appVersion: string;
}

export interface RentvineWebhookEnvelope {
  eventType: string;
  entityId?: string;
  tenantId?: string;
  payload: Record<string, unknown>;
}

export interface PushPayload {
  title: string;
  body: string;
  deepLink: string;
  eventType: string;
  entityId?: string;
  tenantId?: string;
}
