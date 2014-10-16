open Globals

class virtual projectile_abstract : object

    inherit PhysicsMixins.transformable
    inherit MediaMixins.renderable
    inherit PhysicsMixins.basic_physics
    inherit PhysicsMixins.bounded_speed
    inherit PhysicsMixins.destructable
    inherit PhysicsMixins.collision_handler

    val mutable updates : (float -> unit) list
    val mutable collidable : bool
end

