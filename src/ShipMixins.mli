open Globals
open PhysicsMixins
open MediaMixins

class virtual weapon_base : object

  val virtual reload_time : float

  method virtual fire_projectile : (float * float) -> float -> unit

  method fire : (float * float) -> float -> unit

end


class virtual engine_base : object

  val virtual thrust : float

  method virtual fire : (float * float) -> float -> unit

  method thrust : float

end


type module_type = Weapon of weapon_base | Engine of engine_base | Empty


class module_slot : float * float -> object

  method is_empty : bool

  method equip_weapon : weapon_base -> unit

  method equip_engine : engine_base -> unit

  method slot : module_type

  method position : float * float

end


val create_weapon_module : float * float -> weapon_base -> module_slot 

val create_engine_module : float * float -> engine_base -> module_slot


class virtual base_ship : float * float -> float -> 
  module_slot array -> object

  inherit transformable
  inherit basic_physics
  inherit renderable
  inherit bounded_speed
  inherit destructable
  inherit collision_handler

  val mutable position : float * float
  val mutable speed    : float * float
  val mutable orientation : float
  val mutable scale    : float * float
  val mutable color    : OcsfmlGraphics.Color.t
  val mutable updates : (float -> unit) list
  val mutable max_speed : float

  method fire : float * float -> unit

  method accelerate : unit

  method slot : int -> module_slot

  val mutable collidable : bool

end
