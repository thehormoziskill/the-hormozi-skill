# Runtime Setup

## Default user mode (no setup)

The default install is configured to use a hosted Supabase-backed API path maintained by the publisher.
Users should not need to configure Supabase keys for normal usage.

## Why this works safely

- End users receive only public/query-safe access paths.
- Service-role credentials stay private on the publisher backend.
- Ingestion and heavy refresh jobs run on the managed backend, not on user machines.

## Advanced mode (optional self-host)

Advanced users can override defaults and connect their own Supabase project.
Required variables:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

Never print or commit secrets.
