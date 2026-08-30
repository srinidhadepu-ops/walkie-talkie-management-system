# Walkie-Talkie Management System

An offline-first local workstation application for issuing, returning, charging and auditing a pool of walkie-talkies. It is an implementation starter based on the supplied specification: it uses SQLite transactions, database-level double-assignment protections, append-only audit records, and a durable synchronization outbox.

## What you need

You do **not** need prior Git, Python, or SQL knowledge. You only need:

1. A Windows, macOS, or Linux computer.
2. Internet access once, to download Node.js and the project packages.
3. [Node.js 20 or newer](https://nodejs.org/). Download the **LTS** version, run the installer, and accept the default options.
4. A web browser such as Chrome, Edge, or Firefox.

Python and SQL are not required to run this project. SQLite is packaged through Node.js and creates the database automatically.

## Download and run it (beginner route)

1. On the project’s GitHub page, click the green **Code** button.
2. Choose **Download ZIP**.
3. Find the downloaded ZIP file (normally in Downloads), right-click it, and choose **Extract All**.
4. Open the extracted `walkie-talkie-management-system` folder.
5. Click the address bar at the top of the folder window, type `cmd`, and press Enter. A black Command Prompt window opens in that folder.
6. Run this command and wait for it to finish:

   ```text
   npm install
   ```

7. Start the application:

   ```text
   npm start
   ```

8. When the screen says `running at http://localhost:3000`, open that address in your browser.
9. Sign in with the demo account:

   ```text
   Username: operator
   Password: ChangeMe123!
   ```

10. Click **Start shift**, then issue, return, or charge a device.
11. To stop the application, return to Command Prompt and press `Ctrl + C`.

The first run creates `data/walkie.sqlite`. This is the local database. Back it up while the app is stopped; never copy only its `-wal` file.

## Using GitHub (optional route)

Git is only needed if you want updates from GitHub or want to contribute changes.

1. Install [Git for Windows](https://git-scm.com/download/win) using its default installer options.
2. On the GitHub project page click **Code**, copy the HTTPS URL.
3. Open Command Prompt in the folder where you want the project, then run:

   ```text
   git clone PASTE_THE_GITHUB_URL_HERE
   cd walkie-talkie-management-system
   npm install
   npm start
   ```

4. To get newer changes later, stop the application and run `git pull`, then run `npm install` again if package files changed.

## Demo data

The first start seeds three devices (`WT-001` through `WT-003`), three employees (`HR001` through `HR003`), and charger `CH-01`. The demo password must be changed before any real deployment.

## Architecture and safeguards

- SQLite runs in WAL mode with `synchronous=FULL`, foreign keys, and immediate write transactions.
- Partial unique indexes independently prevent more than one open issue for a device or employee.
- An issue or return writes the business record, device state, history, audit entry, and sync-outbox event in one transaction.
- The UI requires an explicit confirmation; scanning/selection alone does not issue a device.
- The outbox is durable and ready for a central synchronization adapter. Events have a sequence number and SHA-256 payload hash.
- Audit entries retain before/after data and link to the preceding entry hash to expose tampering.

## Current implementation scope

This repository is a runnable local MVP, not yet a production release. It implements the local dashboard, login demonstration, shifts, QR-token issue, QR return, charging assignments, transaction boundaries, audit log, and outbox. The following specified production features are deliberately left for the next phases: Argon2id/password-lockout and OS-bound sessions, Ed25519 signed QR credentials/key rotation, incident approvals, maintenance lifecycle, Excel employee staging/versioning, PDF reports, central PostgreSQL/API sync receiver, encrypted backups, and desktop packaging.

See [docs/IMPLEMENTATION-NOTES.md](docs/IMPLEMENTATION-NOTES.md) for the production roadmap.

## Development commands

```text
npm start       Start normally
npm run dev     Restart automatically after server changes
npm test        Run automated tests
```

## Important operational notes

- Use a unique database for every workstation. Do not place the live SQLite file in a shared network folder.
- Change demo accounts before any non-demo use.
- Do not expose port 3000 directly to a network. The local service is designed for a workstation and needs authentication hardening before deployment.
- For real operations, implement the remaining production controls before go-live and complete the acceptance checklist from the source specification.

## License

Choose and add your organization’s license before publishing or distributing this project.
