open Globals

class virtual particle_base : position:(float * float) -> orientation:float ->
  scale:(float * float) -> speed:(float * float) -> duration:float ->
  color:OcsfmlGraphics.Color.t -> object

    inherit PhysicsMixins.transformable
    inherit MediaMixins.renderable
    inherit PhysicsMixins.basic_physics
    inherit PhysicsMixins.destructable

    val mutable position : float * float
    val mutable orientation : float
    val mutable scale : float * float
    val mutable speed : float * float
    val mutable color : OcsfmlGraphics.Color.t
    val mutable updates : (float -> unit) list 
    val mutable on_death : unit -> unit

    method percent_life : float

end

type t

val create : unit -> t

val add_particle : t -> #particle_base -> unit

val update : t -> float -> unit

val particle_list : t -> particle_base list
