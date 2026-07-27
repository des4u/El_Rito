# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
## Reglas de código
- NUNCA dejes comentarios ni notas en el código.
- Simple pero efectivo. No sobre-abstraigas.
- Sin movimiento diagonal en cutscenes: solo arriba/abajo/izq/der.
- Las cards de intro/presentación van en Draw normal con coords de cámara, no en Draw GUI.

## Arquitectura decidida (no cambiar sin preguntar)
- La party es EXPLÍCITA: solo cambia vía `party_set([...])`. No derivarla de flags de eventos.
- `scr_cutscene_stage()` corre en Room Start, no en Step. Ahí van posiciones iniciales y locks.
- Patrón de cases: un case HACE algo y avanza inmediato; otro case solo ESPERA.
  Nunca un case que hace algo Y se queda ejecutándolo cada frame.
- `cs_walk` / `cs_walk_update` / `cs_walk_done` para caminatas. `cs_walk_update()` va arriba del Step.
- `delay(seg, id)` usa static compartido: cada controlador usa su propio rango de ids.
- Los structs de diálogo declaran TODOS los campos en el constructor (`??` truena si el campo no existe).

# NO EDITAR SIN AVISAR
- GMS2 es muy sensible, todo solo dime que quieres hacer y yo lo copio y pego manual

## No tocar sin avisar
- `El Rito.yyp` y los archivos `.yy` (los maneja el IDE)
- `shaders/shd_vhs/`


## Project overview

"El Rito" is a 2D horror/story adventure game built in **GameMaker** (IDE version 2026.0.0.16, GML). The project (`El Rito.yyp`) is Spanish-language; in-game text, character names, and many code comments are in Spanish, while function/variable identifiers are a mix of English and Spanish (see the dev's own note in `notes/Para dataminners, esto es un diario/...txt`: "a veces escribo funciones en inglés y otras en español").

There is no CLI build/lint/test workflow — this is a GameMaker project edited and run through the GameMaker IDE (or `GameMaker.Console` / Igor for CLI builds, if installed). There are no automated tests. To "verify" a change, open the project in GameMaker and run it (F5), or ask the user to.

## Repository layout

Standard GameMaker resource-per-folder layout, referenced by `El Rito.yyp`:
- `objects/` — one folder per GameMaker object, containing per-event `.gml` files (`Create_0.gml`, `Step_0.gml`, `Draw_64.gml`, `CleanUp_0.gml`, `Collision_<obj>.gml`, `Other_4.gml` = Room Start, `Other_5.gml` = Room End, etc.) plus the object's `.yy` metadata.
- `scripts/` — free functions grouped into a handful of large script assets (not one-file-per-function):
  - `scripts/scr_dialogue/scr_dialogue.gml` — dialogue system (see below).
  - `scripts/scr_lighting/scr_lighting.gml` — dynamic light system consumed by `obj_shader_controller`.
  - `scripts/scr_transition/scr_transition.gml` — room transition + VHS fx triggers.
  - `scripts/scr_rooms/scr_rooms.gml` — room setup (per-room ambient light), spawn point registry, party spawning, character-key lookups, story events.
  - `scripts/cutscenes/cutscenes.gml` — cutscene helpers (locking characters, scripted walk/face, camera pan/lock, party solo mode).
  - `scripts/party/party.gml` — larger party/inventory/AI-stance logic (companion system).
  - `scripts/others/others.gml` — misc macros (e.g. `VHS_WIN_W`/`VHS_WIN_H`).
- `rooms/` — game rooms/levels (e.g. `rm_sofi`, `rm_sofi_hall`, `rm_sofi_kitchen`, `rm_sofi_outside_*`, `rm_plaza_kiosco`, `Intro`, `game_1_presentation`).
- `sprites/`, `sounds/`, `shaders/`, `fonts/`, `roomui/`, `datafiles/` — standard GameMaker asset folders.
- `notes/` — in-engine "Notes" resources (each is a folder with a `.txt` and a `.yy`); contains the dev diary and short guides/cheat-sheets for the dialogue and lighting systems. Read these before touching those systems — they document the intended call patterns with examples.
- `options/` — per-platform GameMaker export options (android, html5, ios, linux, mac, windows, etc.).

## Core architecture
El código existente tiene comentarios en español (legado). El código nuevo va SIN comentarios.
### Persistent controller singletons
A handful of objects are created once (in a startup room) and persist across rooms, each self-guarding against duplicates via `if (instance_number(obj_X) > 1) { instance_destroy(); exit; }` in their Create event:
- `obj_game_manager` — owns most `global.*` state: party arrays, spawn points, event flags (`global.events`), inventory/light structs, `global.controlled` (the currently-driven character instance). Calls `scr_register_spawns()` and `party_boot()` on Create.
- `obj_InputManager` — reads global input not owned by the active character (party-switch keys E/Q).
- `obj_CameraManager` — camera follow/pan logic, cooperates with `global.cam_locked`/`cam_target_x/y` set by `scr_cam_move`/`scr_cam_free` in cutscenes.
- `obj_shader_controller` — owns the VHS post-processing shader (`shd_vhs`), the ambient-light struct (`ambient_r/g/b` lerping toward `target_ambient_r/g/b`), and `light_list` (a `ds_list` of light structs created via `light_add`). Its `Draw_64` composites the game view into a surface, renders an `obj_wall`-based shadow mask, and feeds both plus the light list into the shader as uniforms.
- `obj_transition_controller` — fade/transition state machine driven by `transition()`/`transition_finish()`.
- `obj_fx_controller` — one-off VHS fx overlays triggered by `vhs_fx_play()`/`vhs_fx_stop()`.
- `obj_dialogue_controller` — holds the active dialogue queue/state (see Dialogue system below).
- `obj_RoomInit` — per-room bootstrap object (Create/Room-End hooks), likely calling `scr_room_setup()`/spawn logic on room start.

Because these are globally-referenced singletons, most scripts interact with them via `with (obj_X) { ... }` rather than passing references around.

### Party / character system
- Characters are `par_Character` (parent object) descendants: `obj_Sofi`, `obj_Alberto`, `obj_Santiago`, `obj_Diana`, `obj_Carlos`. Each has a `char_name` string used to resolve sprites dynamically by convention: `spr_<char_name>_idle`, `_up_idle`, `_down_w`, `_up_w`, `_side_w`, falling back to `spr_sofi_*` if a character-specific sprite is missing.
- `global.party` is an array of string keys (`"sofi"`, `"alberto"`, `"santi"`, `"diana"`, `"carlos"`); `key_to_obj()`/`key_to_stance()` in `scr_rooms.gml` map keys to object indices and default AI stances. Only the character matching `global.controlled_key` (`global.controlled` instance) reads keyboard input in `par_Character`'s Step; all others run `scr_ai_update()` (in `party.gml`) using `ai_stance`/`ai_state` for follow/wander/scared behavior.
- Party members can be "traveling" (`global.party_traveling`, carried through a room transition) or "stationed" (`global.party_stationed[room_key][char_key]`, left behind in a room at a fixed position, `cutscene_locked = true`). `door_goto()` decides per-member whether they travel or stay (respecting `global.solo_mode`).
- `party_solo(key)` / `party_solo_end()` temporarily strips the party down to one controlled character, stationing the rest.
- Switching the controlled character: `scr_switch_character(dir)` (bound to Q/E in `obj_InputManager`), skips party members with `cutscene_locked = true`.

### Room transitions & doors
- Doors are instances of objects parented to `obj_doorParent`, placed in rooms (e.g. `obj_doorhall_kitchen`). Their collision event with `par_Character` (only reacting when `other.id == global.controlled`) calls `door_goto(target_room, door_id)`, which snapshots inventory, decides travel/station per party member, and calls `transition(_room, _type)`.
- `door_id` strings (e.g. `"door_hall-kitchen"`) are looked up against a spawn-point registry built once in `scr_register_spawns()` (`spawn_register`/`spawn_register_default`) keyed by `"<room>:<door_id>"`; `spawn_get()` falls back to a room's `__default__` entry. When adding a new door/room connection, register its spawn point here.
- `scr_room_setup()` (in `scr_rooms.gml`) is the per-room switch statement that sets ambient light / VHS flicker intensity for each room — extend this when adding a room that needs custom lighting.
- `scr_cutscene_stage()` (in `cutscenes.gml`) is a similar per-room switch keyed on story-progress globals (e.g. `global.sofievent`, `global.kioscoevent`) used to position/lock characters for scripted cutscene moments as a room loads.

### Dialogue system
See `notes/SISTEMA DE DIALOGO, GUIA` for canonical usage examples. Summary (`scr_dialogue.gml`):
- Build a queue of line structs with `dialog_line(text, name, portrait_sprite, portrait_frame)` (and variants `dialog_line_right`, `dialog_line_timed`, `dialog_line_choices`, `double_dialogue[_timed]`, `dialog_tooltip[_wait]`), then start it with `dialog_start([...])`.
- Poll `dialog_is_done()` / `dialog_choice_result()` after a choice line to branch.
- `dialog_blocks_input()` tells other systems whether player input should be suppressed — tooltips (`is_tooltip`) do **not** block input, ordinary lines do.
- All dialogue state lives on `obj_dialogue_controller` and is mutated via `with (obj_dialogue_controller)`.

### Lighting system
See `notes/SISTEMA DE ILUMINACIÓN` for canonical usage examples. Summary (`scr_lighting.gml`):
- `light_add(x, y, radius, brightness, type, r, g, b)` registers a light struct on `obj_shader_controller.light_list` and returns it; `light_move(light, x, y)` updates position each Step for moving lights (e.g. a carried lantern); `light_remove(light)` deregisters it (call in Clean Up of the owning instance).
- `light_set_ambient(r, g, b, instant=false)` sets the room's global ambient lighting target (lerped unless `instant`).
- `type` is one of `"candle"`, `"lantern"`, `"window"`, `"body"`, `"flashlight"` — mapped to a shader-side integer id in `obj_shader_controller`'s Draw event (`_type_id`); only the first 16 lights in the list are actually sent to the shader per frame.
- Equipping/unequipping a light item onto a character (`scr_light_equip`/`unequip`/`extinguish`) manages `char.light_item`/`has_light` and the item's own `my_light_id`.
- Shadows are cast by `obj_wall` instances (rendered as opaque rects into `shadow_surf`, sampled by the shader as `u_shadowmap`).

### Cutscenes
`cutscenes.gml` provides scripted-movement primitives layered on top of `par_Character`: `cs_walk(inst, dx, dy, spd, y_first)` sets a `cs_target` struct that `cs_walk_update()` (called every Step, presumably from a controller/`obj_game_manager`) advances via `scr_cutscene_walk`; `cs_walk_done(inst)` polls completion; `cs_face(inst, dir)` snaps a sprite/facing without moving. `scr_cutscene_lock`/`unlock` toggle `cutscene_locked` on one or all `par_Character` instances to freeze/thaw player control during a scene. `delay(seconds, id)` and `scr_ramp(start, end, duration)` are static-variable frame-counters for simple in-place timing/tweening inside a Step event — note their `static` timers mean **only one concurrent call site per unique `id`** is safe.

## Conventions worth following
- New rooms that need custom ambient lighting or day/night state: add a `case` to `scr_room_setup()` in [scr_rooms.gml](scripts/scr_rooms/scr_rooms.gml).
- New room connections: register spawn points in `scr_register_spawns()` in the same file, and give the door instance's collision event a `door_goto(target_room, "door_id")` call matching the id used at both ends.
- New playable/companion characters: add to `par_Character`, follow the `spr_<name>_{idle,up_idle,down_w,up_w,side_w}` sprite naming convention, and add cases to `key_to_obj()`/`key_to_stance()` in [scr_rooms.gml](scripts/scr_rooms/scr_rooms.gml).
- Global mutable state is centralized on `global.*` (set up in `obj_game_manager`'s Create) rather than passed as parameters — check there first when tracing state bugs.
