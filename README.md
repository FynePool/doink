# Doink!

A local two-player arcade football game for mobile, built with the Corona SDK (now [Solar2D](https://solar2d.com/)) in Lua.

Two players share one device in portrait orientation, sitting at opposite ends of the screen. Each defends the goal on their side, and the first to out-score the other before the timer runs out wins.

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
- **Training** — intended for solo practice. **Currently a stub**: [trainingView.lua](trainingView.lua) only renders the background and a back button, with no gameplay wired up.
- **Settings** ([creditsView.lua](creditsView.lua)) — difficulty (Easy / Normal / Hard), music and SFX toggles.
- **Customization** — selectable ball and pitch skins ([ballView.lua](ballView.lua), [fieldView.lua](fieldView.lua)), with assets in [balls/](balls/) and [fields/](fields/).

An in-game guide with the full rules is in [guideView.lua](guideView.lua) (text in Italian).

## Technical notes

- **Engine**: Corona SDK / Solar2D, Lua.
- **Scenes**: managed with the `composer` module; UI built with the `widget` library.
- **Physics**: Box2D via Corona's `physics`, run with **zero gravity** (`physics.setGravity(0,0)`) — it is a top-down pitch, not a side view.
- **Collision handling**: the pitch, nets, players and ball each get their own category/mask bits. Several alternate filter sets exist in [gameView.lua](gameView.lua) so that power-ups (the wall in particular) can re-body objects and change what collides with what mid-match.
- **Curved borders**: players follow the rounded pitch outline through an ellipse equation (`EllipseY`) plus timed `transition.to` segments, rather than physics-driven movement.
- **Content area**: 320×480, `letterbox` scaling, 60 fps, portrait only.
- **Input**: multitouch, so both players can press their buttons at the same time.
- **Persistence**: [GGData.lua](GGData.lua), a third-party save/load helper.

## Project layout

```
main.lua            entry point — activates multitouch, loads menuView
config.lua          content area, scaling, fps
build.settings      orientation, permissions, icons, per-platform excludes
variables.lua       shared global table passed between scenes

menuView.lua        main menu
gameView.lua        the match: pitch, physics, players, power-ups, scoring
trainingView.lua    training mode (stub)
guideView.lua       scrollable how-to-play text
creditsView.lua     settings and credits
ballView.lua        ball selection
fieldView.lua       pitch selection

balls/ fields/ goal/ powerups/   gameplay art
buttons/ widgets/ fonts/         UI art
sounds/                          music and sound effects
```

## Building

The project has no build script — it is opened directly by the simulator:

1. Install [Solar2D](https://solar2d.com/) (the free successor to Corona SDK; the project predates the rename and still references `docs.coronalabs.com`).
2. Open the Solar2D Simulator and point it at this directory (the one containing `main.lua`).
3. To produce an installable build, use **File → Build** for Android or iOS.

The Android build only requests `android.permission.INTERNET`. iOS uses `LaunchScreen.storyboardc` and the bundled `Icon-*.png` set.

Prebuilt APKs are not tracked in this repository (`*.apk` is in [.gitignore](.gitignore)).

## Credits

Made by **Alessandro Chiabrera, Matteo Ferrini, Luca Montenero, Riccardo Rocco**.

The design document is included as [`Doink!.pdf`](Doink!.pdf).

## License

The source code is released under the [MIT License](LICENSE).

This does **not** extend to every file in the repository. Third-party assets keep their own terms, and at least one is known not to be redistributable under MIT:

- `fonts/BLADRMF_.TTF` — "Blade Runner Movie Font" by Phil Steinschneider. Its embedded metadata reads *"Blade Runner is a trademark of the Blade Runner Partnership. All rights reserved."* It is a fan-made font and is **not** covered by the MIT grant above.
- [GGData.lua](GGData.lua) is third-party (Glitch Games) and carries its own license terms.
- The provenance of the sound files in [sounds/](sounds/) has not been verified.

If you reuse this project, check those separately.

## Status

This is an archived 2017 project, published as-is and no longer actively developed.
