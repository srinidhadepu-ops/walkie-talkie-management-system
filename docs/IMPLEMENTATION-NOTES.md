# Implementation notes

## Implemented local-domain kernel

The schema and service establish the required foundation: device status is only changed inside service commands; issue and return use a SQLite transaction; open issue uniqueness is independently enforced for both device and employee; status history, audit hash-chain entry, and sync-outbox event are stored with the operation.

## Production next steps

1. Replace demonstration login with Argon2id, account lockout, role claims, re-authentication and OS-bound session storage.
2. Replace the local QR token with compact Ed25519 signed credentials, a public-key cache, revocation, rotation and printable label service.
3. Add all remaining state-machine transitions: maintenance, testing, incidents, damage/loss approval, QR replacement, and retirement.
4. Add Excel staging/import and employee version history.
5. Split the local server from the browser UI into a signed Tauri desktop application; protect data under the operating system service account.
6. Implement the central REST/OpenAPI service with PostgreSQL `sync_inbox`, retry/ack protocol, reference snapshots and conflict reconciliation.
7. Add encrypted scheduled backups, restore drill, report archive/PDF generation, monitoring and complete automated chaos/security tests.

## Data integrity contract

Every new state-changing endpoint must call the same transaction wrapper and add a status-history row, audit row and outbox event. No client-side state update is a source of truth. Database constraints must remain in place even when a future UI adds usability validation.
