open Globals
open Geometry
open PhysicsMixins

class virtual slowing_down coeff = object

  inherit time_updatable

  val mutable virtual speed : (float * float)

  initializer
    updates <-
      (fun dt -> speed <- prop2D (coeff ** (dt /. 0.02)) speed) :: updates
end

class virtual speed_to_scale_x coeff = object

  inherit time_updatable

  val mutable virtual speed : (float * float)
  val mutable virtual scale : (float * float)

  initializer
    updates <-
      (fun _ -> 
        let n = norm2D speed in
        let v = clamp (n *. coeff) 0.1 1.0 in
        scale <- (v, snd scale)
      ) :: updates
end

class virtual speed_to_orientation = object

  inherit time_updatable

  val mutable virtual speed : (float * float)
  val mutable virtual orientation : float

  initializer
    updates <-
      (fun _ ->
        orientation <- to_angle speed
      ) :: updates
end

class virtual speed_to_alpha threshold = object(self)

  inherit time_updatable 

  val mutable virtual color : OcsfmlGraphics.Color.t
  val mutable virtual speed : (float * float)

  method virtual percent_life : float

  initializer
    updates <-
      (fun dt ->
        let n = norm2D speed in 
        let mul = 100. -. self#percent_life in
        let alpha_fact = min 0.5 (min (mul /. 50.) (n /. threshold)) in 
          color <- OcsfmlGraphics.Color.(
            rgba color.r color.g color.b (int_of_float (alpha_fact *. 255.)))
      ) :: updates
end

(* TODO : clean this... this was just for fun *)
class virtual blackhole force = object
  val mutable virtual speed : (float * float)
  val mutable virtual position : (float * float)
  val mutable virtual updates : (float -> unit) list

  initializer
    updates <-
      (fun dt ->
        let (px, py) = position in
        let distance = norm2D (400. -. px, 300. -. py) in
        let n = prop2D (1. /. distance) (400. -. px, 300. -. py) in
        let force = force *. (dt /. 0.02) in
        speed <- add2D 
          speed 
          (prop2D (force /. (distance *. distance +. 10000.)) n);
        if distance <= 50. then 
          speed <- add2D
            speed
            (prop2D (force /. (200. *. distance +. 1000.)) 
                    (snd n, -. fst n)
            )
      ) :: updates
end
