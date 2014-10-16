open Globals
open Geometry
open OcsfmlGraphics
open WarpingGrid

class game_state (window:render_window) = object(self)

  inherit GameData.game_data
  
  val p_system = ParticleSystem.create ()

  val e_manager = new EntityManager.entity_manager

  val warpgrid = WarpingGrid.create 0.28 0.06 20. 

  val renderer = Renderer.create window

  val mutable last_call : float = Unix.gettimeofday ()

  (* testing values *)
  val mutable delta_test : float = 0.
  val mutable release = true

  initializer
    let player_ship = new Tests.player_ship in
    (player_ship#slot 0)#equip_weapon (new Tests.plasma_launcher);
    (player_ship#slot 1)#equip_weapon (new Tests.plasma_launcher);
    (player_ship#slot 2)#equip_engine (new Tests.simple_engine);
    e_manager#add_playership player_ship;

    let test_ship = new Tests.wanderer_ship (400., 300.) in
    e_manager#add_iaship test_ship;

    let test_ship = new Tests.wanderer_ship (500., 300.) in
    e_manager#add_iaship test_ship;

    let test_ship = new Tests.wanderer_ship (500., 500.) in
    e_manager#add_iaship test_ship;

    let test_ship = new Tests.wanderer_ship (400., 100.) in
    e_manager#add_iaship test_ship


  method private event_loop =
    match window#poll_event with
      |Some e -> OcsfmlWindow.Event.(
        begin match e with
          | Closed -> window#close
          | MouseButtonPressed(RightButton, {x;y}) -> 
              WarpingGrid.explosive warpgrid 30. (float_of_int x,float_of_int
              y,0.) 100.;
              ParticlesUtilities.simple_explosion p_system 
              (float_of_int x, float_of_int y) 120 200. ColorUtils.green;
              let rnd_str = 
                "explosion-0" ^ (string_of_int (Random.int 8 + 1))
              in ()
(*               SoundLib.(get global_sound_lib rnd_str)#play; *)
          | KeyPressed{code = OcsfmlWindow.KeyCode.K} -> begin
              match e_manager#player_ships with
              | [] -> ()
              | t::q -> t#kill 
            end
          | KeyPressed{code = OcsfmlWindow.KeyCode.R} ->
              release <- not release
          | _      -> ()
        end);
        self#event_loop
      | _ -> ()


  method main_loop = 
    if window#is_open then begin
      self#event_loop;

      (* Updates *)
      let delta_t = Unix.gettimeofday () -. last_call in
      if delta_t >= 0.04 then begin
        last_call <- last_call +. delta_t;
        ParticleSystem.update p_system delta_t;
        e_manager#update delta_t;
        Spawner.spawner#update;
        if not release then
          WarpingGrid.implosive warpgrid 30. (400., 300., 0.) 400.;
        WarpingGrid.update warpgrid (min (delta_t *. 25.) 1.);
      end;

      (* Tests *)
      delta_test <- delta_test +. delta_t;
      (* Rendering *)
      window#clear ();
      Renderer.render renderer (self :> GameData.game_data);
      window#display;
      self#main_loop  
    end

  method get_psystem = p_system

  method get_window = (window : render_window :> OcsfmlWindow.window)

  method get_emanager = e_manager

  method get_warpgrid = warpgrid

end
