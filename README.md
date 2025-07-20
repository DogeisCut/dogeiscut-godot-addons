# DogeisCut Godot Addons
These Godot addons were created for various projects and reasons. They are provided for public use as-is, free of charge.
# Disclaimers
- I will not be providing any support for these addons. Any issues will be addressed if/when they impact the development of anything I work on. Functionality of these addons are also subject to change at any moment, use at your own risk. Feel free to fork, or hell, even make PRs.
- These addons were designed for Godot `4.4.1`. They might work in other versions of Godot, but they are not being tested for compatability.
# Instructions
- Download any of the addons you need from here and place them into the addons folder of your Godot project. Don't forget to enable them in the project tab!
# Addon list
- **Big Int**
  - Provides a `BigInt` type for storing, comparing, and doing math on infinitley large integers while keeping precision. Useful for incremental games.
- **Cutscena**
  - A very basic global cutscene system for my games. Provides a `Cutscene` class for storing cutscenes, a `CutsceneEvent` for storing actions and events within those cutscenes, a `CutsceneInstance` for managing running instances of cutscenes, and makes a `CutsceneManager` autoload for starting and stopping playback of cutscenes.
- **Scratch .sb3 Importer**
  - Adds an importer for the `.sb3` file type used by Scratch projects. While it doesn't transpile code yet, it can import project sprites, sounds, and costumes as a scene! Useful for porting Scratch projects to Godot.
