open Globals


class virtual time_updatable : object

  val virtual mutable updates : (float -> unit) list

  method update : float -> unit

end


class virtual transformable : object

  val virtual mutable position : float * float

  val virtual mutable orientation : float

  val virtual mutable scale : float * float

  val virtual mutable origin : float * float

  method scale : float * float

  method orientation : float

  method position : float * float

  method origin : float * float

end


class virtual basic_physics : object

  inherit time_updatable

  val virtual mutable position : float * float

  val virtual mutable speed : float * float
  
  method speed : float * float

  method position : float * float

end


class virtual collision_handler : object

  val virtual mutable origin : float * float

  val virtual mutable collidable : bool

  val virtual mutable collision_radius : float

  method collidable : bool

  method collision_radius : float

  method origin : float * float

end


class virtual bounded_speed : object

  inherit time_updatable

  val virtual mutable speed : float * float

  val virtual mutable max_speed : float

  method max_speed : float
end


class virtual destructable : object

  val virtual mutable on_death : unit -> unit

  method dead : bool

  method kill : unit

end


class virtual screen_border_bounce : object

  inherit basic_physics

end


class virtual screen_border_death : object

  inherit basic_physics
  inherit destructable

end
