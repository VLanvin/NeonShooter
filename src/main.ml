(* A test with GLSL shaders, mixins and ocsfml *)
open OcsfmlGraphics
open Globals


let () = 
  (* Loading ressources *)
  Random.self_init ();
  ImageLib.(load global_image_lib "ressources/");
  SoundLib.(load global_sound_lib "sounds/");

  (* Creating window *)
  let window = new render_window
    (OcsfmlWindow.VideoMode.create 
    ~w:(int_of_float glob_width) ~h:(int_of_float glob_height) ())
    "Neon" in
  window#set_framerate_limit 60;
  window#set_mouse_cursor_visible false;

  (* Creating game state *)
  let gs = new GameState.game_state window in
  Stack.push (gs :> GameData.game_data) GameData.state_stack;
  gs#main_loop
 
