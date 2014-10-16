open Globals
open Geometry
open OcsfmlGraphics
open ParticleSystem
open PhysicsMixins
open MediaMixins

class basic_rectangle ~speed ~position ~orientation ~color ~scale ~duration
  ~slowing_factor ~scaling_factor ~alpha_factor = object
  inherit particle_base ~speed ~position ~orientation ~color ~scale ~duration
  inherit basic_physics
  inherit renderable
  inherit transformable
  inherit InterpolatorMixins.slowing_down slowing_factor
  inherit InterpolatorMixins.speed_to_scale_x scaling_factor
  inherit InterpolatorMixins.speed_to_orientation
  inherit InterpolatorMixins.speed_to_alpha alpha_factor
  inherit screen_border_bounce

  val mutable texture_name = "rectangle"

  val mutable origin = (11., 1.)
end

class explosive_rectangle ~speed ~position ~orientation 
  ~color ~duration = object 
  inherit basic_rectangle ~speed ~position ~orientation ~color 
    ~scale:(1.,1.2) ~duration ~slowing_factor:0.95
    ~scaling_factor:0.008 ~alpha_factor:50.
end

let simple_explosion psystem position particles speed color = 
  let rec rnd_aux = function
    |0 -> ()
    |n -> begin 
      let spe_norm = ((min (Random.float 4.) 1.) *. (Random.float 0.15 +. 0.9))
        *. speed in
      let rnd_or = Random.float (2. *. 3.141592) in
      new explosive_rectangle 
        ~speed:(to_cartesian spe_norm rnd_or) 
        ~position ~orientation:rnd_or ~color
        ~duration:3.
      |> add_particle psystem;
      rnd_aux (n-1)
    end
  in rnd_aux particles

let abrasion_particles psystem position particles speed col = 
  let rec rnd_aux = function
    |0 -> ()
    |n -> begin 
      let spe_norm = Random.float speed in
      let rnd_or = Random.float (2. *. 3.141592) in
      new basic_rectangle ~speed:(to_cartesian spe_norm rnd_or) 
        ~position ~orientation:rnd_or ~color:col ~duration:1.
        ~scale:(1.,1.) ~slowing_factor:0.97 ~scaling_factor:0.01
        ~alpha_factor:50.
      |> add_particle psystem;
      rnd_aux (n-1)
    end
  in rnd_aux particles

