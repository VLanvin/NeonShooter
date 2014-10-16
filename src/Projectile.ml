open Globals
open PhysicsMixins
open MediaMixins

class virtual projectile_abstract = object
    
  inherit transformable
  inherit renderable
  inherit basic_physics
  inherit bounded_speed
  inherit destructable
  inherit collision_handler

  val mutable updates : (float -> unit) list = []
  val mutable collidable = true
end
