open Globals
open Geometry
open OcsfmlGraphics

class point_mass pos imass = object(self)

  val mutable position = pos
  val mutable speed = (0.,0.,0.)

  val mutable acceleration = (0.,0.,0.)
  val mutable damping = 0.98

  method apply_force f = 
    acceleration <- add3D acceleration (prop3D imass f)

  method prop_damping f = 
    damping <- f *. damping

  method update dt = 
    speed <- add3D speed (prop3D dt acceleration);
    position <- add3D position (prop3D dt speed);

    acceleration <- (0.,0.,0.);

    if squarenorm3D speed < 0.0001 then
      speed <- (0.,0.,0.);

    speed <- prop3D damping speed;
    damping <- 0.98

  method position = position

  method speed = speed

  method imass = imass
end

class spring point1 point2 rigid damping = object(self)

  val normal_length = 0.95 *. (distance3D point1#position point2#position)

  method update (dt : float) =
    let x = diff3D point1#position point2#position in
    let length = norm3D x in

    if length <= normal_length then ()
    else begin
      let x' = prop3D ((length -. normal_length) /. length) x in
      let dv = diff3D point2#speed point1#speed in
      let force = diff3D (prop3D rigid x') (prop3D damping dv) in

      point1#apply_force (prop3D (-1.) force);
      point2#apply_force force
    end
end

type point = point_mass

let pos2D p = project (p#position)

type t = {points : point_mass array array; springs : spring list}

let create stiffness damping spacing = 
  let foi = float_of_int in
  let iof = int_of_float in
  let ncolumns = iof (glob_width /. spacing +. 2.) in
  let nrows    = iof (glob_height /. spacing +. 2.) in
  let pts = Array.init ncolumns
    (fun i -> Array.init nrows
      (fun j -> new point_mass 
        ((foi i) *. spacing, (foi j) *. spacing, 0.) 1.)) in
  let fixpts = Array.init ncolumns
    (fun i -> Array.init nrows
      (fun j -> new point_mass 
        ((foi i) *. spacing, (foi j) *. spacing, 0.) 0.)) in 
  let rec create_springs i j =
    if j >= nrows then create_springs (i+1) 0
    else if i >= ncolumns then []
    else begin 
      let l = create_springs i (j+1) in 
      (if i = 0 || j = 0 || i = ncolumns - 1 || j = nrows - 1 then 
        [new spring fixpts.(i).(j) pts.(i).(j) 0.1 0.1]
       else if i mod 3 = 0 && j mod 3 = 0 then
        [new spring fixpts.(i).(j) pts.(i).(j) 0.002 0.02]
       else []) @
      (if i > 0 then 
        [(new spring pts.(i-1).(j) pts.(i).(j) stiffness damping)]
        else [] ) @ 
      (if j > 0 then
        [(new spring pts.(i).(j-1) pts.(i).(j) stiffness damping)]
       else [] ) @ l
    end
  in let l = create_springs 0 0 in
  {points = pts; springs = l}

let update grid dt = 
  List.iter (fun s -> s#update dt) grid.springs;
  Array.iter (Array.iter (fun p -> p#update dt)) grid.points

let points grid = grid.points

let explosive grid force pos rad = 
  Array.iter (Array.iter (fun p ->
    let dist = squarenorm3D (diff3D pos p#position) in
    if dist <= rad *. rad then begin
      let prop = 100. *. force /. (10000. +. dist) in
      p#apply_force (prop3D prop (diff3D p#position pos));
      p#prop_damping 0.6;
    end )) grid.points

let implosive grid force pos rad =
  Array.iter (Array.iter (fun p ->
    let dist = squarenorm3D (diff3D pos p#position) in
    if dist <= rad *. rad then begin
      let prop = 10. *. force /. (100. +. dist) in
      p#apply_force (prop3D prop (diff3D pos p#position));
      p#prop_damping 0.6;
    end )) grid.points
