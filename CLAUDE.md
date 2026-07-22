# Doink! — working notes

A Corona SDK / Solar2D game in Lua. Two players share one phone; first to five
goals wins. Originally 2017, with a large round of work in 2021 that was merged
into this repository in v6.0.0.

## Running and checking

There is no test suite, and the simulator cannot be driven headlessly. Anything
automated has to be static:

- **Syntax**: `luac -p <file>`. The binary is not on PATH — it ships with the
  simulator at `/Applications/Corona-3731/Native/Corona/mac/bin/luac` (Lua 5.1.5).
- **Scoping**: `luac -l -l -p <file>`, then grep for `GETGLOBAL` / `SETGLOBAL`.
  **Two `-l` flags are required** — a single `-l` only dumps the top-level
  function and silently skips nested ones, which is exactly where this codebase's
  accidental-global bugs live.
- **Asset and scene paths**: they are plain strings, so a wrong one fails at
  runtime with no warning. Any sweep over them must cover **both quote styles** —
  this file mixes `"..."` and `'...'`, and a double-quote-only pass has broken the
  build here before.

Real verification means opening the project in the Solar2D simulator and playing
it. Static checks confirm that paths resolve; they say nothing about behaviour.

## Layout

`main.lua`, `config.lua`, `build.settings` and the `Icon*.png` set must stay at
the repository root — the iOS bundle references the icons by bare filename.
Everything else lives under `scenes/`, `lib/`, `assets/` and `docs/`.

Scenes are loaded by module path: `composer.gotoScene("scenes.menuView")`. Asset
paths in code resolve from the project root, not relative to the calling file,
so moving a Lua file does not affect them.

## Things that will bite you

- **`display.newImageRect` returns `nil` for a missing file** rather than
  raising. The failure surfaces one line later as "attempt to index a nil value".
- **`removeSelf()` empties an object but leaves your variable pointing at it.**
  The reference stays truthy while its methods are gone, so a second removal
  fails. Always clear the slot afterwards.
- **`isAwake = false` does not stop a body.** Box2D keeps the velocity and the
  object resumes on the next contact. Use `setLinearVelocity(0, 0)` first — see
  `stopBall()` in `gameView.lua`.
- **Never destroy a physics body inside a collision listener.** Box2D is still
  resolving the collision. Defer with `timer.performWithDelay(1, ...)`, as the
  training targets do.
- **`"touch"` fires for `began`, `moved` and `ended`.** Without a phase check a
  single tap runs the handler two or three times. Every in-game button filters on
  a phase; anything new must too.
- **`scene:destroy` runs in module scope.** Widgets declared `local` inside
  `scene:create` are invisible there and resolve to `nil` globals. Declare them at
  the top of the file. Composer only calls `destroy` under memory pressure, so
  this class of bug hides well.
- **`composer.removeScene` takes the full module path** (`"scenes.gameView"`).
  With the wrong name it fails silently, the scene stays cached, and `create`
  never re-runs on re-entry — while `physics.stop()` has already destroyed every
  body.

## Audio

Everything is MP3, not OGG: Corona only supports OGG on Android and this project
also builds for iOS. Music uses `audio.loadStream` (the track is over four
minutes; `loadSound` would hold it decoded in memory). Effects use `loadSound`
and are gated on `global.sfxFlag`.

Do not commit uncompressed audio. The 2018 Corona build server transcoded WAVs
into the package automatically; current Solar2D ships them raw, which once put a
44 MB file inside a 67 MB APK.

## Builds

Open the project in the Solar2D simulator and use **File → Build**. Android needs
a JDK — the system `/usr/bin/javac` is only a stub.

- Keep the package name `com.qwerteam.Doink`, or Android installs a second app
  instead of updating.
- `versionCode` must increase; `versionName` follows the release tag.
- Solar2D emits an `.aab` next to the `.apk`. It is only for Play Store
  submission and is not directly installable — releases here ship the APK.
- `build.settings` has an `excludeFiles.all` entry keeping the design PDF, debug
  notes, README and licence out of the package. Leave it in place.
- Release flow: `gh release create vX.Y.Z <apk> --latest`, with the SHA-256 in the
  notes so a sideloaded download can be verified.

## Conventions

Comments in the source are Italian, matching the original authors. Commit
messages and the README are English. Explain *why* in comments rather than what —
several fixes here look arbitrary without the reason.

Verified claims only: if something has not been run in the simulator, say so.
