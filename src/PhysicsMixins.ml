open Globals
open Geometry

(* A mixin for updatable objects *)
class virtual time_updatable = object

  val virtual mutable updates     : (float -> unit) list

  method update dt = List.iter (fun f -> f dt) updates
end

(* A mixin for transformable objects *)
class virtual transformable = object

  val virtual mutable position    :  float * float
  val virtual mutable orientation :  float
  val virtual mutable scale       :  float * float
  val virtual mutable origin      :  float * float

  method scale       = scale
  method orientation = orientation
  method position    = position
  method origin      = origin

end

(* A mixin that handles basic physics (speed/position) *)
class virtual basic_physics = object
  inherit time_updatable

  val virtual mutable position : (float * float)
  val virtual mutable speed    : (float * float)

  initializer
    updates <- 
      (fun dt -> 
        position <- add2D position (prop2D dt speed)
      ) :: updates

  method speed = speed
  method position = position
end


class virtual collision_handler = object
  
  val virtual mutable origin : (float * float)
  val virtual mutable collidable : bool
  val virtual mutable collision_radius : float

  method collidable = collidable
  method collision_radius = collision_radius
  method origin = origin

end


class virtual bounded_speed = object

  inherit time_updatable
  
  val virtual mutable speed : (float * float)
  val virtual mutable max_speed : float

  initializer
    updates <-
      (fun _ ->
        let n = norm2D speed in
        if n > max_speed then
          speed <- prop2D (max_speed /. n) speed
      ) :: updates

  method max_speed = max_speed
end


class virtual destructable = object

  val mutable dead = false
  val virtual mutable on_death : unit -> unit
  
  method dead = dead
  method kill = if not dead then (on_death (); dead <- true)
end

(* A mixin that handles screen-border collisions and bounces off *)
class virtual screen_border_bounce = object
  inherit basic_physics

  initializer
    updates <-
      (fun _ ->
        let (px, py) = position in
        let (sx, sy) = speed in 
        if px >= glob_width && sx > 0. then speed <- (-.sx, sy)
        else if px <= 0. && sx < 0. then speed <- (-.sx, sy)
        else if py >= glob_height && sy > 0. then speed <- (sx, -.sy)
        else if py <= 0. && sy < 0. then speed <- (sx, -.sy)
      ) :: updates
end

class virtual screen_border_death = object(self)

  inherit basic_physics

  inherit destructable

  initializer
    updates <-
      (fun _ ->
        let (px,py) = position in
        if px >= glob_width || px < 0. || py >= glob_height || py < 0. then
          self#kill
      ) :: updates
end
