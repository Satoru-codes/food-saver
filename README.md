# FoodSaver

FoodSaver is a household food-management application. Development happens on the `development` branch; the existing production site remains on `main`.

## Frontend stack

- Vanilla JavaScript and CSS
- Vite 8
- Supabase JavaScript SDK 2
- Supabase Auth and PostgreSQL

## Local development

1. Install Node.js 22.12 or later.
2. Install dependencies:

   ```bash
   npm install
   ```

3. Copy `.env.example` to `.env`.
4. Set the FoodSaver-dev Supabase URL and publishable key in `.env`.
5. Start the local server:

   ```bash
   npm run dev
   ```

6. Open the local URL shown by Vite (normally `http://localhost:5173`).

Do not put a Supabase secret key or service-role key in `.env` used by this browser app. The frontend uses only the publishable key; Row Level Security protects database access.

## Netlify

The `netlify.toml` file configures the build command and `dist` publish directory. Add these environment variables in Netlify:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`

Deploy previews are used for testing the `development` branch through a pull request. Do not change the production branch from `main` during development. The FoodSaver-dev URL and publishable key should be configured in Netlify before testing the preview. Because the current Netlify plan applies these variables to all deploy contexts, do not merge this development branch into production until production has a separate Supabase project and environment configuration.

## Current implementation milestone

The current development entry point implements:

- Email/password sign-up and sign-in
- Email confirmation redirect handling
- Password reset
- English and Hindi account UI
- Session restoration and sign-out
- Initial household creation using the `create_household` database function

Pantry CRUD and inventory synchronization are the next milestone. The legacy single-file prototype is preserved as `initial app`; its browser localStorage data is not automatically imported.
