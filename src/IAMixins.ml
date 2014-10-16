open Globals
open PhysicsMixins
open OcsfmlGraphics
open Geometry

class virtual spawning_entity = object

  val mutable spawned = false

  val mutable time_origin = Unix.gettimeofday ()

  val mutable virtual color : Color.t

  val mutable virtual scale : (float * float)

  val mutable virtual collidable : bool
  
  val mutable virtual updates : (float -> unit) list

  val mutable virtual ia_activated : bool

  val mutable first_color = Color.white

  initializer
    time_origin <- Unix.gettimeofday ();
    collidable <- false;
    ia_activated <- false;
    first_color <- color;
    color <- Color.rgba 0 0 0 0;
    updates <- (fun _ ->
      let delta_t = Unix.gettimeofday () -. time_origin in
      if delta_t >= 1. && not spawned then begin
        scale <- (1.,1.);
        color <- first_color;
        collidable <- true;
        ia_activated <- true;
        spawned <- true
      end else if not spawned then begin
        collidable <- false;
        ia_activated <- false;
        scale <- (prop2D (1.5 -. 0.5 *. delta_t) (1.,1.));
        color <- Color.rgba first_color.Color.r
          first_color.Color.g first_color.Color.b
          (int_of_float (float_of_int first_color.Color.a *. (delta_t)))
      end
    ) :: updates
end


class virtual constant_acceleration_IA = object(self)

  inherit time_updatable

  method virtual accelerate : unit

  initializer 
    updates <- (fun _ -> self#accelerate) :: updates

end


class virtual wandering_IA = object(self)

  inherit basic_physics

  val virtual mutable orientation : float

  val virtual mutable ia_activated : bool

  val mutable last_decision = Unix.gettimeofday ()

  val mutable angle_left = 0.

  val mutable step = 0.

  initializer
    updates <- (fun _ ->
      if Unix.gettimeofday () -. last_decision >= 1. then begin
        angle_left <- (Random.float 3.141592 -. (3.141592 /. 2.));
        step <- angle_left /. 10.;
        last_decision <- Unix.gettimeofday ()
      end;
      if angle_left <> 0. then begin
        orientation <- orientation +. step;
        angle_left <- angle_left -. step
      end) :: updates

end


  
