# Porting opal-rails 2.x to 3.x

`opal-rails` 3.x drops the old Sprockets-era Opal pipeline and moves Opal assets to an explicit build step.

## What changes

- Opal source files are built into `app/assets/builds`
- `opal:build` replaces request-time Opal compilation
- `opal:watch` replaces the old edit-refresh flow for development
- `manifest.js` should link built assets, not raw Opal source files
- old `Opal.use_gem` / `Opal.append_path` setup in `config/initializers/assets.rb` should move to `config/initializers/opal.rb`

## Fast path

If you are starting from a 2.x app, run:

```bash
bin/rails g opal:install
```

The generator now:

- creates `config/initializers/opal.rb` with build-based defaults
- creates `app/assets/builds/.keep`
- links `app/assets/builds` from `app/assets/config/manifest.js` when that file exists
- sets `config.assets.debug = true` in `config/environments/test.rb` when that file exists so tests prefer freshly rebuilt assets over stale checked-in digests
- creates or updates `Procfile.dev` with `opal: bin/rails opal:watch`
- creates `bin/dev` when missing, or replaces an existing `bin/dev` that does not reference `Procfile.dev` (Rails 8.1+ generates a `bin/dev` that just execs `rails server`); the generated launcher installs `foreman` if needed and runs `Procfile.dev`

## Manual migration checklist

1. Move your Opal entrypoints to either:
   - `app/opal` for a greenfield-style layout, or
   - `app/assets/opal` for a migration-friendly layout
2. Configure Opal in `config/initializers/opal.rb`.

For a single entrypoint:

```ruby
Rails.application.configure do
  config.opal.source_path = Rails.root.join("app/opal")
  config.opal.entrypoints_path = config.opal.source_path
  config.opal.entrypoints = { "application" => "application.rb" }
  config.opal.use_gems = []
end
```

For multi-entrypoint apps that keep Opal files under `app/assets/opal`:

```ruby
Rails.application.configure do
  config.opal.source_path = Rails.root.join("app/assets/opal")
  config.opal.entrypoints_path = config.opal.source_path
  config.opal.entrypoints = :all
  config.opal.use_gems = %w[some-gem]
end
```

If you keep Opal sources under `app/assets/opal`, take care of asset serving explicitly: `opal-rails` no longer hides that directory from the host asset pipeline for you.

- Propshaft apps should add an exclusion when they would otherwise serve or fingerprint raw files from `app/assets/opal`:

```ruby
config.assets.excluded_paths << Rails.root.join("app/assets/opal")
```

- Sprockets apps should make sure `app/assets/config/manifest.js` links only `app/assets/builds`, and should remove old raw-source links such as `link_tree ../opal`, `link_directory ../opal`, `require_tree`, or other directives that expose `app/assets/opal` directly.

You only need that extra asset-pipeline care when you keep the migration-friendly `app/assets/opal` layout. The default `app/opal` layout stays outside the asset load path, so there is nothing extra to exclude.

3. Remove old Opal load-path setup from `config/initializers/assets.rb`, such as:

```ruby
Opal.use_gem "some-gem"
Opal.append_path Rails.root.join("app", "assets", "opal")
```

and move it into `config.opal.use_gems` / `config.opal.append_paths`.

4. Update `app/assets/config/manifest.js` to link built outputs instead of raw Opal source files:

```js
//= link_directory ../builds .js
//= link_directory ../builds .map
```

If you do not want production builds to generate and serve Opal source maps, disable them in `config/environments/production.rb`:

```ruby
config.opal.source_map_enabled = false
```

That keeps the shared manifest configuration intact while stopping `opal:build` / `assets:precompile` from emitting `app/assets/builds/*.js.map` in production.

5. Build assets explicitly (one-off check):

```bash
bin/rails opal:build
```

In practice you rarely need to run this manually — `opal-rails` wires `opal:build` into the standard Rake lifecycle automatically (see below).

6. Include the built asset in your layout with the normal Rails helper:

```erb
<%= javascript_include_tag "application", "data-turbo-track": "reload" %>
```

or use your own logical asset name if the app already has a different `application.js`.

## Development and test

### Development

The recommended flow is `bin/dev`, which uses Foreman to run both the Rails server and `opal:watch` together via `Procfile.dev`. If you prefer to run processes separately, start `bin/rails opal:watch` in a second terminal while editing Opal files.

### Test

`opal-rails` hooks `opal:build` into these Rake tasks automatically:

| Trigger | How it works |
|---|---|
| `rake assets:precompile` | `opal:build` runs first (production deploys) |
| `rake assets:clobber` | `opal:clobber` cleans build outputs |
| `rake test` / `rake spec` | `test:prepare` (or `spec:prepare`) runs first, which triggers `opal:build` |
| `bin/rails test` | Rails' built-in `test:prepare` triggers `opal:build` |

This means `rake test` and `bin/rails test` both rebuild Opal assets before tests run. You should not need to run `opal:build` manually before running tests.

If your repo keeps old checked-in `public/assets` digests, set `config.assets.debug = true` in `config/environments/test.rb` so system tests resolve the rebuilt files from `app/assets/builds` instead of stale manifest entries.

## What to remove from old 2.x apps

- request-time Opal compilation assumptions
- `app/assets/javascripts/*.js.rb` as the primary entrypoint pattern
- raw Opal source links in `manifest.js`
- helper-side Sprockets loader assumptions
- `opal-sprockets`-specific setup
