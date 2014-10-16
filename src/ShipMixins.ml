open Globals
open Geometry
open PhysicsMixins
open MediaMixins
open Projectile

class virtual weapon_base = object(self)

  val virtual reload_time : float

  val mutable last_time = Unix.gettimeofday ()

  method virtual fire_projectile : (float * float) -> float -> unit

  method fire pos orient = 
    if Unix.gettimeofday () -. last_time >= reload_time then begin
      self#fire_projectile pos orient;
      last_time <- Unix.gettimeofday ()
    end

end


class virtual engine_base = object

  val virtual thrust : float

  method virtual fire : (float * float) -> float -> unit

  method thrust = thrust
  
end


type module_type = Weapon of weapon_base | Engine of engine_base | Empty


class module_slot (position : float * float) = object

  val mutable slot : module_type = Empty

  method is_empty = (slot = Empty)

  method equip_weapon w = slot <- Weapon(w)

  method equip_engine e = slot <- Engine(e)

  method slot = slot

  method position = position

end


let create_weapon_module pos w = 
  let ms = new module_slot pos in
  ms#equip_weapon w; ms

let create_engine_module pos e =
  let ms = new module_slot pos in
  ms#equip_engine e; ms
    

class virtual base_ship pos max_speed (slots : module_slot array) = object(self)
  
  val mutable position  : float * float = pos
  val mutable speed     : float * float = (0., 0.)
  val mutable orientation : float       = 0.
  val mutable scale     : float * float = (1., 1.)
  val mutable color     : OcsfmlGraphics.Color.t = OcsfmlGraphics.Color.rgba
                                                   255 255 255 140
  val mutable updates   : (float -> unit) list = []
  val mutable max_speed : float         = max_speed

  inherit transformable
  inherit basic_physics
  inherit renderable
  inherit bounded_speed
  inherit destructable
  inherit collision_handler

  method fire target = 
    let rec fire_aux s = 
      match s#slot with
      |Weapon(w) -> 
        let position' = add2D position
          (rotate (diff2D s#position origin) orientation)
        in w#fire position'
          (to_angle (diff2D target position'))
      | _        -> ()
    in Array.iter fire_aux slots

  method accelerate = 
    let rec acc_aux s =
      match s#slot with
      |Engine(e) -> 
        let position' = add2D position
          (rotate (diff2D s#position origin) orientation)
        in e#fire position' (orientation +. 3.141592); 
        e#thrust
      | _ -> 0.
    in 
    let tthrust = Array.fold_left 
      (fun i s -> i +. acc_aux s) 0. slots
    in
    let new_val = add2D speed (to_cartesian tthrust orientation) in
    if norm2D new_val >= max_speed then
      speed <- prop2D (max_speed /. (norm2D new_val)) speed
    else
      speed <- new_val


  method slot i = slots.(i)

  val mutable collidable = true

end

