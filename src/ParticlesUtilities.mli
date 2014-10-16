open ParticleSystem
open PhysicsMixins
open MediaMixins

class basic_rectangle : speed:(float * float) -> 
  position:(float * float) -> orientation:float -> 
  color:OcsfmlGraphics.Color.t -> scale:(float * float) -> 
  duration:float -> slowing_factor:float -> scaling_factor:float ->
  alpha_factor:float -> object

    inherit particle_base
    inherit basic_physics
    inherit renderable
    inherit transformable

    val mutable texture_name : string
    val mutable origin : float * float
end


class explosive_rectangle : speed:(float * float) -> 
  position:(float * float) -> orientation:float -> 
  color:OcsfmlGraphics.Color.t -> duration:float -> object
    
    inherit basic_rectangle
end


(** rnd_explosions sys pos n spe c creates a random explosion of n particles,
  * starting at speed spe and position pos and with color c *) 
val simple_explosion : ParticleSystem.t -> (float * float) -> 
  int -> float -> OcsfmlGraphics.Color.t -> unit

val abrasion_particles : ParticleSystem.t -> (float * float) ->
  int -> float -> OcsfmlGraphics.Color.t -> unit
