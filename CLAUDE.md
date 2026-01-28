# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Godot 4.5 game developed for a game jam with the theme "The World is Watching". This is a cosmic horror HOA (Homeowners Association) game where players complete absurd citations while being watched by a cosmic entity.

**Key Resources**:

- [Game Design Doc](https://docs.google.com/document/d/1oj2usDqIn5Sdpnh7ON6QuayOTrwhRDDoshr0Rp_YQFg/edit?tab=t.0)
- [Project Kanban](https://github.com/users/rae-ralston/projects/3/settings)

## Development Workflow

### Running the Game

This is a Godot project - open `project.godot` in the Godot 4.5 editor and press F5 to run, or use the play button in the editor toolbar.

**Important**: There is no build/test/lint command-line workflow. All development happens through the Godot editor.

### File Locations

- **Scripts**: `scripts/*.gd` - GDScript files
- **Scenes**: `scenes/*.tscn` - Scene definitions
- **Assets**: `assets/` - Sprites, music, sound, fonts
- **Data**: `data/*.json` - Game data (citations, etc.)

### Testing Phase System

To speed up phase testing during development, PhaseManager supports a test mode with shortened durations:

**Enabling Test Mode:**

1. Open Godot editor
2. In the FileSystem panel, navigate to `scripts/phase_manager.gd`
3. With PhaseManager autoload visible in Scene tree (or create a test scene that shows it)
4. In the Inspector panel, find the "Test Mode" checkbox and enable it
5. Press F5 to run the game

**Test Mode Durations:**

- Normal: 10 seconds (instead of 90)
- Warning: 5 seconds (instead of 15)
- Danger: 5 seconds (instead of 25)

**Timer Display:**
The game includes a timer display in the top-right corner that:

- Shows time remaining in the current phase (MM:SS or SS format)
- Changes color by phase: white (Normal) → orange (Warning) → red (Danger)
- Updates every frame for smooth countdown

**Note:** Test mode is an `@export` variable, so you can toggle it in the Inspector without modifying code. Remember to disable test mode before building final releases.

## MCP Servers

### Godot MCP Server

**Configuration**: Project-scoped (`.mcp.json`)
**Purpose**: Access Godot 4.5 engine API documentation, node references, method signatures, and GDScript best practices

**When to use the Godot MCP**:

- Looking up node types, methods, properties, or signals (e.g., "What methods are available on CharacterBody2D?")
- Understanding GDScript syntax or built-in functions (e.g., "How do I use @export variables?")
- Checking signal signatures or connection patterns (e.g., "What parameters does animation_finished pass?")
- Learning about Godot built-in classes (e.g., "How does Vector2 work in Godot?")
- Verifying engine patterns or best practices (e.g., "What's the proper way to handle \_process vs \_physics_process?")

**CRITICAL REQUIREMENT**: You MUST consult the Godot MCP server before implementing any GDScript features or working with Godot nodes. Never rely on memory for Godot API details - the MCP provides current, accurate Godot 4.5 documentation.

**Usage Examples**:

```
"Look up CharacterBody2D methods in the Godot MCP"
"Check the Godot MCP for Signal.emit() documentation"
"Find @export variable examples in the Godot MCP"
"What does AnimatedSprite2D.play() return according to Godot docs?"
```

## Architecture

### Autoload Singleton Pattern

The game uses Godot's autoload feature to create globally accessible singletons:

- **CitationsManager** (`scripts/citations_manager.gd`) - Central game state manager
  - Loads citation definitions from `data/citations_by_id.json`
  - Tracks active, resolved, new, and reopened citations
  - Emits `citations_changed` signal when state updates
  - Provides `get_active_list_for_ui()` for UI consumption

- **PhaseManager** (`scripts/phase_manager.gd`) - Global timer system
  - Cycles through three phases: Normal (90s) → Warning (15s) → Danger (25s)
  - Emits signals on phase transitions: `phase_changed`, `warning_started`, `danger_started`, `normal_resumed`
  - Configurable durations via `@export` variables
  - Accessible globally as autoload singleton

### Phase System

The game operates on a three-phase timer cycle managed by the PhaseManager singleton.

**Phase Behaviors:**

- **Normal Time**: Default gameplay, players complete citations
- **Warning Time**: 15-second buildup, indicates Eye approaching
- **Danger Time**: Eye is watching, citations can be sabotaged/added (future)

**Integration Points:**

- **Game.gd**: Subscribes to signals for red overlay visual feedback
- **Audio System**: Should connect to phase signals for music transitions
- **CitationsManager**: Future connection for sabotage logic on `danger_started()`

### Citation System

Citations are the core gameplay mechanic - absurd HOA violations that players must resolve.

**Data Structure** (`data/citations_by_id.json`):

```json
{
  "citation_id": {
    "id": "citation_id",
    "title": "Short title for UI",
    "detail": "Full description",
    "priority": 10,
    "deadline_phase": 0,
    "tags": ["tag1", "tag2"],
    "sabotage_weight": 2,
    "reopenable": true,
    "max_reopens": 1,
    "conditions": [
      {
        "type": "ITEM_ROTATION_NEAR",
        "params": { "item_id": "item", "angle": 0, "tolerance": 12 }
      }
    ]
  }
}
```

**Citation States**:

- `active_citations`: Array of citation IDs currently active
- `resolved_citations`: Dictionary tracking which citations are completed
- `new_citations`: Dictionary tracking newly added citations
- `reopened_citations`: Dictionary tracking citations that were sabotaged

### Player System

The player (`scripts/player.gd`) is a CharacterBody2D with:

**Animation System**:

- Programmatically generated from sprite sheet (`assets/sprites/main_character.png`)
- 64x64 frame size, 6 columns
- Animations: walk (4 directions), idle (4 directions), crawl (4 directions), crawl_idle (4 directions), plow, water, dig
- Action animations (plow, water, dig) are non-looping and use `animation_finished` signal

**Movement**:

- Normal speed: 200.0
- Crawl speed: 80.0
- Uses acceleration/friction for smooth movement
- Direction determined by input vector (prioritizes horizontal over vertical)

**Inventory System**:

- `inventory`: Array of item names
- `held_item`: Currently displayed item texture
- `held_item_name`: Name of held item
- Picking up new item while holding one moves old item to inventory

### Input Actions

Defined in `project.godot`:

- `crawl`: Shift/C - Toggle crawl mode
- `plow`: P - Perform plow action
- `water`: W - Water plants
- `dig`: D - Dig action
- Standard movement: `ui_left`, `ui_right`, `ui_up`, `ui_down`

### UI System

**Citations List UI** (`scripts/citations_list_ui.gd`):

- Connects to `CitationsManager.citations_changed` signal
- Dynamically instantiates `citation_row.tscn` for each citation
- Sorts citations by: resolved status → priority → display order
- Refreshes entire list on any change (simple but functional for game jam scope)

### Scene/Script Relationship

Each scene typically has a corresponding script:

- `scenes/player.tscn` ↔ `scripts/player.gd`
- `scenes/game.tscn` ↔ `scripts/game.gd`
- `scenes/citation_row.tscn` ↔ `scripts/citation_row.gd`

The main scene is set in `project.godot`: `run/main_scene="uid://bsneu6mo1x44l"`

## Game Design Patterns

### Signal-Driven Updates

The game uses Godot's signal system for loose coupling:

```gdscript
# Emit signal when state changes
CitationsManager.emit_signal("citations_changed")

# UI listens and refreshes
CitationsManager.citations_changed.connect(_on_citations_changed)
```

### JSON-Driven Content

Game content (citations, conditions) is defined in JSON files rather than code, allowing for easy iteration without recompiling.

### Action Animation Pattern

Player actions follow this pattern:

1. Set action flag (`is_plowing = true`)
2. Play non-looping animation
3. Freeze movement during action
4. `animation_finished` signal resets flag and returns to idle/walk

## Important Considerations

### Godot-Specific Notes

- **Resource paths**: Always use `res://` prefix for resource paths
- **Node references**: Use `@onready` for node references that exist at scene load
- **Type hints**: GDScript supports optional type hints (`: Type`)
- **Signals**: Prefer signals over direct calls for decoupled communication
- **API Documentation**: You MUST query the Godot MCP server for node methods, built-in classes, and GDScript features - never rely on memory for Godot API details

### Game Jam Context

This is a rapid prototype/game jam project:

- Prioritize functionality over polish
- Simple solutions are preferred (e.g., full UI refresh vs incremental updates)
- TODOs in code indicate planned but unimplemented features

### Asset Attribution

Assets are from commercial/free use licensed sources - see README.md. Do not remove or modify attribution comments.

## Three-Phase Tension System

The game operates on a cyclical tension model (see `soundtrack-executive-summary-v2.md`):

1. **Normal Time**: Player completes citations, explores
2. **Warning Time**: Eye approaching
3. **Danger Time**: Eye is watching, can sabotage completed citations

Music and visuals should support this three-phase cycle.
