open Globals
open Geometry
open OcsfmlGraphics
open ShipMixins

class plasma_launcher = 
  object(self)

  inherit weapon_base

  val reload_time = 0.30

  method fire_projectile pos orient = 
    let projectile = object (self)
        inherit Projectile.projectile_abstract 

        inherit PhysicsMixins.screen_border_death
        inherit InterpolatorMixins.speed_to_orientation

        initializer
          updates <- (fun _ ->
            WarpingGrid.explosive 
              (Stack.top GameData.state_stack)#get_warpgrid 
              (0.05 *. (norm2D speed))
              (fst position, snd position, 0.)
            80.) :: updates;
          on_death <- (fun () -> 
            let (x,y) = position in
            ParticlesUtilities.abrasion_particles
            (Stack.top GameData.state_stack)#get_psystem
            (clamp x 0. glob_width, clamp y 0. glob_height) 
            30 150. ColorUtils.light_blue)


        val mutable texture_name = "bullet"
        val mutable position = pos
        val mutable orientation = orient
        val mutable max_speed = 200.
        val mutable speed = to_cartesian 200. orient
        val mutable scale = (1.,1.)
        val mutable origin = (14., 4.)
        val mutable color = OcsfmlGraphics.Color.rgb 120 120 255
        val mutable on_death = fun () -> ()
        val mutable collision_radius = 4.

      end in
    (Stack.top GameData.state_stack)#get_emanager#add_projectile projectile

end


class auto_gun = 
  object(self)

  inherit weapon_base

  val reload_time = 0.05

  method fire_projectile pos orient = 
    let projectile = object (self)
        inherit Projectile.projectile_abstract 

        inherit PhysicsMixins.screen_border_death
        inherit InterpolatorMixins.speed_to_orientation

        initializer
          on_death <- (fun () -> 
            let (x,y) = position in
            ParticlesUtilities.abrasion_particles
            (Stack.top GameData.state_stack)#get_psystem
            (clamp x 0. glob_width, clamp y 0. glob_height) 
            10 70. ColorUtils.gold)

        val mutable texture_name = "rectangle"
        val mutable position = pos
        val mutable orientation = orient
        val mutable max_speed = 310.
        val mutable speed = to_cartesian (280. +. (Random.float 30.)) orient
        val mutable scale = (0.3,0.5)
        val mutable origin = (11., 1.)
        val mutable color = ColorUtils.yellow
        val mutable on_death = fun () -> ()
        val mutable collision_radius = 1.
      end in
    (Stack.top GameData.state_stack)#get_emanager#add_projectile projectile

end


class simple_engine = 
  object(self)

  inherit engine_base

  val thrust = 5.

  method fire position orientation = ParticlesUtilities.(
    let my_psystem = (Stack.top GameData.state_stack)#get_psystem in
    let rnd_or = orientation +. (Random.float 0.5) -. 0.25 in
    new explosive_rectangle ~speed:(to_cartesian 80. rnd_or) ~position 
      ~orientation:rnd_or ~color:ColorUtils.gold ~duration:2.
    |> ParticleSystem.add_particle my_psystem;
    let coeff = mod_float (Unix.gettimeofday ()) 0.06 -. 0.03 in
    new explosive_rectangle ~speed:(to_cartesian 80. (orientation +. coeff *. 20.)) 
      ~position ~orientation ~color:ColorUtils.gold ~duration:2.
    |> ParticleSystem.add_particle my_psystem;
    new explosive_rectangle ~speed:(to_cartesian 80. (orientation -. coeff *. 20.)) 
      ~position ~orientation ~color:ColorUtils.gold ~duration:2.
    |> ParticleSystem.add_particle my_psystem)
end
      

class player_ship =
  object(self)

    inherit base_ship (100., 100.) 200. 
      [|new module_slot (40., 0.); new module_slot (40., 40.); 
      new module_slot (0., 20.)|]

    inherit ControlMixins.orient_mouse
    inherit PhysicsMixins.screen_border_bounce

  val mutable texture_name = "player"

  val mutable origin = (10., 20.)

  val mutable on_death = fun () -> ()

  val mutable collision_radius = 10.

  initializer
    updates <-
      (fun _ ->
        let window = (Stack.top GameData.state_stack)#get_window in
        if OcsfmlWindow.(Mouse.is_button_pressed Event.LeftButton) then
          self#fire (foi2D (OcsfmlWindow.Mouse.get_relative_position window));
        if OcsfmlWindow.(Keyboard.is_key_pressed KeyCode.Space) then
          self#accelerate
      ) :: 
      (fun _ ->
        WarpingGrid.explosive 
        (Stack.top GameData.state_stack)#get_warpgrid 
        (0.1 *. (norm2D speed))
        (fst position, snd position, 0.) 80.
      ) :: updates;
    on_death <- (fun () -> 
        ParticlesUtilities.simple_explosion
        (Stack.top GameData.state_stack)#get_psystem
        position 800 800. ColorUtils.gold;
        WarpingGrid.explosive (Stack.top GameData.state_stack)#get_warpgrid
        400. (fst position, snd position, 0.) 400.)
end


class wanderer_ship pos =
  object(self)

    inherit base_ship pos 50. 
      [|create_engine_module (20., 20.) (new simple_engine)|]

    inherit PhysicsMixins.screen_border_bounce
    inherit IAMixins.spawning_entity
    inherit IAMixins.constant_acceleration_IA
    inherit IAMixins.wandering_IA

  val mutable texture_name = "wanderer"

  val mutable origin = (20., 20.)

  val mutable on_death = fun () -> ()

  val mutable ia_activated = false

  val mutable collision_radius = 20.

  initializer
    orientation <- Random.float 6.2830;
    updates <-
      (fun _ ->
        WarpingGrid.explosive 
        (Stack.top GameData.state_stack)#get_warpgrid 
        (0.1 *. (norm2D speed))
        (fst position, snd position, 0.) 50.
      ) :: updates;
    on_death <- (fun () -> 
        ParticlesUtilities.simple_explosion
        (Stack.top GameData.state_stack)#get_psystem
        position 120 200. ColorUtils.pink;
        WarpingGrid.explosive (Stack.top GameData.state_stack)#get_warpgrid
        80. (fst position, snd position, 0.) 100.
        )
end

let () = 
  Spawner.spawner#register (new wanderer_ship) 1.0
