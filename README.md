# RTS demo

This is a simple tech demo for an RTS game that I was working on, using a custom version of Godot, of which repository can be found [here](https://github.com/UwUOwOUmUOmO/custom-godot).

<img title="Main stage" src="screenshots/main_stage.png">

## Installation
Download and extract the archive from the release page, run the `.exe` file to open the Godot Editor, run the `.bat` file to open the game.
## Controls
- `W`/`A`/`S`/`D`: Move camera around
- Hold `Right Mouse Button` and move mouse: Rotate camera around pivot
- `Mouse scroll wheel`: Zoom in/out
- `Left Mouse Button`: Move squadron
- `Middle Mouse Button`: Fire missiles
- `Escape`: Menu
- `,`: Change window mode (Windowed/Fullscreen/Borderless Fullscreen)
- `.`: Change graphics preset (Lowest/Low/Medium/High/Highest)
- `/`: Change SSAA level (from 0.7 to 2.0, default 1.0)

## Level designs
<img title="Overlook" alt="Level overlook" src="screenshots/overlook.png">

Since this is just a simple tech demo, I did not put too much thought into designing the level. You, the player, control a squadron of 40 aircrafts to fire at a sinking ship, each aircraft has 100 infared-homing missile. The stage is above cloud level, and the sprawling cloud is just a single massive plane which has 2048 subdivisions by default.
## Main features

### RTS camera
The default camera in this demo (named BOSC) allow user to view the stage like in any traditional RTS game. It contains 5 components:

- Camera base
- Translation controller
- Pitch controller
- Collision detection
- The camera itself

<img title="Camera component" src="screenshots/camera_components.png">

The camera base allow the translation unit to move around relative to itself, while the translation and pitch unit handle yaw and pitch control of the camera. The collision detection unit allow the camera to stay at a predefined max distance while guarantee that it does not clip to anything unwanted.

BOSC allow users to zoom in and out of view by changing the max distance of the spring arm (collision detection unit). The transition into a new distance is smooth out thanks to linear interpolation function which give the zoom feature a snappy feeling.

BOSC has extensive configuration interface that allow the developer to fine-tune the control experience. This include min/max pitch angle, zoom delta per input, zoom modifier, min/max zoom distance, default zoom distance, camera FOV, camera panning speed, camera translation speed, camera yaw (swivel) speed, minimum delta per translation request, starting location (relative), starting rotation and custom input mapping.

### Aircraft controller

Each aircraft has its own state and controller. The state decide the vehicle's property, such as acceleration rate, max speed, drag, etc while the controller use said state and translate it into actual movement.

In this demo, an aircraft can use two types of controller: the legacy `VTOLFighterBrain` controller and the new `NAFB_Standalone` controller. The legacy controller allow each aircraft to perform standard operations such as receiving events (which then turn into translation and rotation), calculate speed, acceleration, decceleration, drag, throttle, etc. The newer NAFB controller allows the same thing to happen, but with higher efficiency, thanks to the new `state_automaton` module from custom godot build. Moreover, its new `AFBNewConfiguration` configuration file allow the controller to read `AdvancedCurve` data for acceleration, decceleration and turning radius instead of one singular number, which was not possible with the base version of Godot.

<img title="AFBNewConfiguration" alt="A property from the new AFBNewConfiguration class, which leverage the definite integral approximation ability from AdvancedCurve" src="screenshots/afbn_config.png">

`NAFB_Standalone` controllers also have the ability to run in swarm mode, which means all NAFB controllers in the scene will have its physics calculation performed asynchronously between every physics engine iteration, boosting performance for scenes that contains an absurdly large amount of controllers (although this feature is yet to be fine-tuned)

### Munition controller (guidance)

`WeaponHandler` stores information regarding an aircraft's weapon system such as its hardpoints, weapon configuration, munition reserve, target, etc. When receive the signal to fire, it will find a suitable hardpoint and spawn a new weapon there, setup the controller and fire the weapon. The base weapon controller in this demo is called `WeaponGuidance`. During setup, a `WeaponGuidance` can be loaded with the weapon configuration, the weapon reference in game world and target, along with any other additional info that derived controllers require. There are 5 derived guidance controllers in this demo:

- Dumb: Does not do any active homing calculation, relies on loaded detonation time calculated by the `WeaponHandler`
- Homing: Standard homing controller. Require a moving target, a host (of type `VTOLFighterBrain`) and gradually move toward the target until the `WeaponConfiguration.PROXIMITY_MODE` condition is satisfied or weapon timeout reached
- Forward-looking guidance (FLG): Does the same thing homing guidance does, but only track target if it is in view of the host. If the target move out of view, the weapon will stray forward until it find another target or timeout
- Integrated-homing guidance: Does the same thing FLG does, but does not use a `VTOLFighterBrain` host, per performance problem. Instead, it requires a bare-bone `Spatial` object as a host, and attach a `SimpleIntegratedMissilePerformer` controller to it, allowing operations on the host to be carried out at a much faster and more efficient pace.
- Precision: A primitive type of homing guidance. Automatically move toward a predefined coordinate until it either miss the target or timeout.

The host itself can be attached with a `MunitionController` script. This script governs the host particle emission rate and detect collision between its warhead and in-game targets. If a collision happens, the internal `WarheadController` will allow host's `WeaponHandler` to free itself before passing damage calculation to a third-party instance.

### Formations

Aircrafts are grouped into squadrons, and each squadron use one formation. Squadrons can change formation mid-flight, as long as the new formation support the total amount of members. The formation itself is just a bunch of `Spatial` objects that define where an aircraft should be. When moved, all aircraft will adjust its throttle to make sure that it will land at the nearest possible position relative to its formation coordinate.

### Level handler

At the game startup, a script can be invoked to load the main level using the `LevelManager` singleton. The singleton will then proceed to:

- Free up the old level, along with its dependencies
- Setup a new level loader
- Load new dependencies
- Create a loading screen
- Load the actual level
- Clean up the loader and loading screen

In Godot, each time a resource is loaded using `load` method, the actual resource is cached by default. Utilizing this, `LevelManager` load all dependencies before the level itself for faster access to resources.

The loading of the level is performed in coroutines, allowing the user to interact with the game and see its loading progress and prevent the game from freezing up during load.

### Level-dependent singletons

Singletons are designed to be active from start to finish of the application, however, there's a need for one that is only there during a level. That's what level-dependent singletons are for. They are loaded during level initialization as dependencies, and cleaned up during finalization.

### Shaders

This demo make extensive use of shaders to create beautiful effects that is rendered on the GPU. From 2D UI components to particles effects, they all use Godot shaders (a specialized version of GLSL). Here are some of the main effects that utilize shader in the demo level:

- Flipbook shader: Allow a flipbook animation to be rendered in 3D space over a period of time. This is used for explosion effects created by missiles in the level
- Scrolling cloud shader: Allow a flat, subdivided plane to be animated and have wavy effect of an ocean and spiral, sprawling effects of clouds.

<img title="Overlook" src="screenshots/overlook.png">

- Static shader ([Credit](https://godotshaders.com/shader/earthbound-like-battle-background-shader-w-scroll-effect-and-palette-cycling/)): Create static effects for sprites. Used in the game main menu

<img title="Main menu" src="screenshots/menu.png">

### Other features

There are features that are either partially completed or have not been tested yet and are not included inside the demo level, however you can still find them in the assets. These (in no particular order) include:

- Behavior tree (deprecated and removed)
- Chain of command (deprecated): replaced by `state_automaton` module
- Combat edicts (incomplete): decide how the AIs of each team operate
- CombatServerGDS (deprecated): replaced by `rts_com` module (or `Sentrience`)
- Processor (deprecated): specific objects that do not inherit `Node` class but can still be invoked during idle frame, thanks to `ProcessorsCluster` and `ProcessorsSwarm`. Replaced by `paralex`
- Trail ([original repository](https://github.com/OBKF/Godot-Trail-System) - deprecated): a module to create trail effect by [OBKF](https://github.com/OBKF), is not used due to performance problem ([LICENSE](https://github.com/OBKF/Godot-Trail-System/blob/master/LICENSE))
