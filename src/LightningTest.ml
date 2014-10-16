open Geometry
open OcsfmlGraphics

type t = (float * float) list

let rec rnd_list long interv = 
  if long <= 0. then [0.]
  else long::(rnd_list (long -. (Random.float interv)) interv) 

let rec jagg pts norm dist coeff = 
  match pts with
  |[] -> []
  |[(d,t)] -> [t]
  |(d1,p1)::(d2,p2)::t -> 
      let new_pt = 
        if t <> [] then 
          add2D p2 (prop2D (Random.float ((d2 -. d1)/.coeff)) norm)
        else 
          p2
      in p1::(jagg ((d2,new_pt)::t) norm dist coeff)


let create (ox,oy) (ex,ey) = 
  Random.self_init ();
  let vector = (ex -. ox, ey -. oy) in
  let long   = norm vector          in
  let vectn  = prop2D (1. /. (norm vector)) vector in
  let normal = (snd vectn, -. (fst vectn)) in
  let dists = rnd_list long 25. in
  let pts = List.map (fun e -> (e, add2D (prop2D e vectn) (ox,oy))) dists in
  jagg pts normal long 1.3

let color = Color.rgb 255 25 254 

let draw_line (ox,oy) (ex,ey) (target : #render_target) = 
  let vect = (ex -. ox, ey -. oy) in
  let long = norm vect in
  let orient = to_deg (to_angle vect) in
  new rectangle_shape ~rotation:orient ~position:(ox,oy) ~fill_color:color
    ~size:(long,2.) ~origin:(0.,1.) ()
  |> target#draw ~blend_mode:BlendMode.BlendAdd;
  new circle_shape ~radius:1.5 ~position:(ox,oy) ~fill_color:color
  ~origin:(1.,1.) () |> target#draw ~blend_mode:BlendMode.BlendAdd


let display t (target : #render_target) = 
  let rec aux = function
    |[] |[_] -> ()
    |t1::t2::q -> 
      draw_line t1 t2 target;
      aux (t2::q)
  in aux t
