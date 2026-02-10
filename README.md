# Testing Gamemode Skeleton

This repository contains a minimal Garry's Mod gamemode skeleton at:

- `gamemodes/testing_gamemode/`

## Structure

- `gamemode/shared.lua` - shared metadata and initialization
- `gamemode/init.lua` - server entrypoint
- `gamemode/cl_init.lua` - client entrypoint
- `gamemode/player_class.lua` - custom player class setup
- `gamemode/sv_player.lua` - spawn/player handling hooks and slot-based loadout (slot 1 crowbar, empty slots unarmed) and a join intro menu gate with New Character/Load Character flow, character creation fields (first/last name dropdowns, gender, occupation, skill, model selection + skin slider), a right-side selected-model preview, and a menu-only splash layout
- `gamemode/cl_hud.lua` - stylized custom HUD inspired by the provided mockup, with subtle grayscale + vignette post-processing
- `gamemode.txt` - gamemode manifest

## Usage

Place this repository's `gamemodes` folder into your Garry's Mod installation and start a server/client with the `testing_gamemode` gamemode selected.
