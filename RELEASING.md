# Releasing riteway

Publishing is always triggered by a human — never by an AI agent.

`bundle exec rake release` is the standard release command. It runs preflight
checks, builds the gem, creates an annotated git tag, and pushes it. GitHub
Actions detects the tag and handles publishing to RubyGems.

## Prerequisites

- Push access to the `mycargus/riteway-ruby` GitHub repository
- A RubyGems account with ownership of the `riteway` gem
- `GEM_HOST_API_KEY` secret configured in the repository (one-time setup below)

### One-time setup: RubyGems API key

Create a **scoped** API key (push-only, limited to the `riteway` gem) at
<https://rubygems.org/profile/edit> → "API keys". A scoped key limits blast
radius if the secret is ever compromised.

Add it as a GitHub repository secret:

1. **Settings → Secrets and variables → Actions → New repository secret**
2. Name: `GEM_HOST_API_KEY`, value: your scoped key

## Steps

1. Update the version in `lib/riteway/version.rb`:

   ```ruby
   VERSION = "X.Y.Z"
   ```

2. Update `CHANGELOG.md` with release notes.

3. Commit and push to `main`:

   ```sh
   git add lib/riteway/version.rb CHANGELOG.md
   git commit -m "Release vX.Y.Z"
   git push origin main
   ```

4. Run the release task:

   ```sh
   bundle exec rake release
   ```

   This checks your working tree is clean, you're on `main`, HEAD is pushed,
   and no tag already exists for this version. Then it builds the gem, creates
   an annotated `vX.Y.Z` tag, and pushes it.

5. GitHub Actions takes over:
   - Verifies tag matches `version.rb`
   - Runs lint + full test suite
   - Builds the gem
   - Publishes to RubyGems
   - Creates a GitHub release with the `.gem` attached

   Monitor progress at: <https://github.com/mycargus/riteway-ruby/actions>

---

## Versioning

Follow [Semantic Versioning](https://semver.org/):

- **PATCH** (`0.1.x`) — backwards-compatible bug fixes
- **MINOR** (`0.x.0`) — new backwards-compatible features
- **MAJOR** (`x.0.0`) — breaking changes

The version is defined in one place: `lib/riteway/version.rb`.

---

## What is intentionally blocked

AI agents (Claude Code) cannot trigger a release. The following are blocked by
a PreToolUse hook:

- `rake release` / `bundle exec rake release`
- `gem push`
- `git push origin v*` (version tags)

Human terminal usage is unaffected — the hook only runs inside Claude Code.
