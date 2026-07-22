# Doink!

A local two-player arcade football game for mobile, built with the Corona SDK (now [Solar2D](https://solar2d.com/)) in Lua.

Two players share one device in portrait orientation, sitting at opposite ends of the screen. Each defends the goal on their side and tries to out-score the other.

The in-game guide describes a match timer, but none was ever implemented: a match runs until the players stop.

## Gameplay

Your player is not moved freely — it slides continuously along the border of its own half of the pitch. You control it with two buttons:

- **Red button** — shoots your player into the field to hit the ball.
- **Green button** — inverts its direction along the border, so you can line up the angle before firing.

Once shot, the player travels across the pitch and is re-hooked to the border on completion.

### Power-ups

Each player has two power-up slots shown at mid-field on their own side: the one currently active and the one coming next, so you can plan a couple of moves ahead. They are drawn at random from five types:

| Power-up | Effect |
| --- | --- |
| ❄️ Snowflake | Freezes the ball if it is moving. |
| 👊 Fist | Launches your player much faster, for a more powerful shot. |
| 🧱 Wall | Raises a barrier in front of your goal. If used while detached from the border after a shot, the wall is built at the player's current position instead. |
| 🌀 Teleport | Sends your player back to its own goal line and re-hooks it to the border. Only usable after the player has been shot. |
| 🚫 No entry | Does nothing — a null power-up, there to keep matches unpredictable. |

### Modes and settings

- **Match** — the two-player game described above.
- **Training** — intended for solo practice. **Currently a stub**: [trainingView.lua](scenes/trainingView.lua) only renders the background and a back button, with no gameplay wired up.
- **Settings** ([creditsView.lua](scenes/creditsView.lua)) — difficulty, music and SFX toggles. Difficulty scales how fast the players slide along the border, which is what makes aiming harder: Easy 0.75×, Normal 1×, Hard 1.3×. Settings apply immediately but are not persisted.
- **Customization** — selectable ball and pitch skins ([ballView.lua](scenes/ballView.lua), [fieldView.lua](scenes/fieldView.lua)), with assets in [balls/](assets/balls/) and [fields/](assets/fields/).

An in-game guide with the full rules is in [guideView.lua](scenes/guideView.lua) (text in Italian).

## Technical notes

- **Engine**: Corona SDK / Solar2D, Lua.
- **Scenes**: managed with the `composer` module; UI built with the `widget` library.
- **Physics**: Box2D via Corona's `physics`, run with **zero gravity** (`physics.setGravity(0,0)`) — it is a top-down pitch, not a side view.
- **Collision handling**: the pitch, nets, players and ball each get their own category/mask bits. Several alternate filter sets exist in [gameView.lua](scenes/gameView.lua) so that power-ups (the wall in particular) can re-body objects and change what collides with what mid-match.
- **Curved borders**: players follow the rounded pitch outline through an ellipse equation (`EllipseY`) plus timed `transition.to` segments, rather than physics-driven movement.
- **Content area**: 320×480, `letterbox` scaling, 60 fps, portrait only.
- **Input**: multitouch, so both players can press their buttons at the same time.
- **Persistence**: none at runtime. [GGData.lua](lib/GGData.lua), a third-party save/load helper, is bundled but never required by any scene — settings do not survive a restart.

## Project layout

```
main.lua                  entry point — activates multitouch, loads the menu
config.lua                content area, scaling, fps
build.settings            orientation, permissions, icons, per-platform excludes
Icon*.png                 app icons (must stay at the root — build.settings
LaunchScreen.storyboardc  and the iOS bundle reference them by bare filename)

scenes/
  menuView.lua            main menu
  gameView.lua            the match: pitch, physics, players, power-ups, scoring
  trainingView.lua        training mode (stub)
  guideView.lua           scrollable how-to-play text
  creditsView.lua         settings and credits
  ballView.lua            ball selection  (ballView2.lua is an unused variant)
  fieldView.lua           pitch selection

lib/
  variables.lua           shared global table passed between scenes
  GGData.lua              third-party save/load helper (currently unused)

assets/
  balls/ fields/ goal/ powerups/   gameplay art
  buttons/ widgets/ images/        UI art and backgrounds
  fonts/                           bundled font (unused — see License)
  sounds/                          music and sound effects

docs/
  Doink!.pdf              design document
  DEBUG_INVERT.rtf        debugging notes from development
```

Scenes are loaded by module path (`composer.gotoScene("scenes.menuView")`). Asset
paths in code are resolved from the project root, not relative to the calling file.

## Building

The project has no build script — it is opened directly by the simulator:

1. Install [Solar2D](https://solar2d.com/) (the free successor to Corona SDK; the project predates the rename and still references `docs.coronalabs.com`).
2. Open the Solar2D Simulator and point it at this directory (the one containing `main.lua`).
3. To produce an installable build, use **File → Build** for Android or iOS.

The Android build only requests `android.permission.INTERNET`. iOS uses `LaunchScreen.storyboardc` and the bundled `Icon-*.png` set.

Prebuilt APKs are not tracked in this repository (`*.apk` is in [.gitignore](.gitignore)).

## Credits

Made by **Alessandro Chiabrera, Matteo Ferrini, Luca Montenero, Riccardo Rocco**.

The design document is included as [`docs/Doink!.pdf`](docs/Doink!.pdf).

## License

The source code is released under the [MIT License](LICENSE).

This does **not** extend to every file in the repository. Third-party assets keep their own terms, and at least one is known not to be redistributable under MIT:

- `assets/fonts/BLADRMF_.TTF` — "Blade Runner Movie Font" by Phil Steinschneider. Its embedded metadata reads *"Blade Runner is a trademark of the Blade Runner Partnership. All rights reserved."* It is a fan-made font and is **not** covered by the MIT grant above. No code loads it, so it can be deleted without affecting the game.
- [GGData.lua](lib/GGData.lua) is third-party (Glitch Games) and carries its own license terms.
- The provenance of the sound files in [sounds/](assets/sounds/) has not been verified.

If you reuse this project, check those separately.

## Status

This is an archived 2017 project, published as-is and no longer actively developed.
