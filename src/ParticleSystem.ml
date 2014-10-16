open Globals
open PhysicsMixins
open MediaMixins

class virtual particle_base ~position ~orientation ~scale 
  ~speed ~duration ~color = object (self)

  val mutable position : float*float = position
  val mutable orientation : float = orientation
  val mutable scale : float*float = scale
  val mutable speed : float*float = speed
  val mutable color : OcsfmlGraphics.Color.t = color
  val mutable updates : (float -> unit) list = []

  inherit transformable
  inherit renderable
  inherit basic_physics
  inherit destructable

  val mutable age : float = 0.
  val mutable on_death = fun () -> ()

  initializer
    updates <- 
      (fun dt -> 
        age <- age +. dt;
        if age >= duration then self#kill
      ) :: updates

  method percent_life = age *. 100. /. duration
end

type t = particle_base list ref

let create () = ref []

let add_particle t p = t := (p :> particle_base) ::!t

let update t dt = 
  let rec aux = function
    |[] -> []
    |t::q -> 
        if t#dead then aux q
        else begin
          t#update dt; 
          t :: (aux q)
        end
  in t := aux !t

let particle_list t = !t



