-- Auto-delete webhook events older than 30 days
CREATE INDEX IF NOT EXISTS idx_webhook_events_received_at ON webhook_events(received_at);

-- Cleanup function
CREATE OR REPLACE FUNCTION cleanup_old_webhook_events() RETURNS void AS $$
BEGIN
  DELETE FROM webhook_events WHERE received_at < NOW() - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;
