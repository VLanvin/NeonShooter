open Globals

let clamp v mi ma = min (max v mi) ma

let foi2D (a,b) = (float_of_int a, float_of_int b)

let foi3D (a,b,c) = (float_of_int a, float_of_int b, float_of_int c)

let add2D (a,b) (c,d) = (a+.c, b+.d)

let add3D (a,b,c) (d,e,f) = (a+.d, b+.e, c+.f)

let prop2D k (a,b) = (k*.a, k*.b)

let prop3D k (a,b,c) = (k*.a, k*.b, k*.c)

let diff2D (a,b) (c,d) = (a-.c, b-.d)

let diff3D (a,b,c) (d,e,f) = (a-.d,b-.e,c-.f)

let rotate (a,b) t = 
  (a *. (cos t) -. b *. (sin t), 
   a *. (sin t) +. b *. (cos t))

let to_deg a = a *. 360. /. (2. *. 3.141592)

let to_cartesian n t = (n *. (cos t), n *. (sin t))

let to_angle (sx, sy) = 
  if sx < 0. then 
    (atan (sy /. sx)) +. 3.141592
  else if sx > 0. then
    (atan (sy /. sx))
  else if sy > 0. then
    3.141592 /. 2.
  else 
    3.141592 /. 2.

let norm2D (a,b) = sqrt (a *. a +. b *. b)

let norm3D (a,b,c) = sqrt (a *. a +. b *. b +. c *. c)

let distance2D (a,b) (c,d) = norm2D (a -. c, b -. d)

let distance3D v v' = norm3D (diff3D v v')

let squarenorm2D (a,b) = a *. a +. b *. b

let squarenorm3D (a,b,c) = a *. a +. b *. b +. c *. c

let print2D (a,b) = Printf.printf "Print : %f,%f" a b; print_endline ""


let project (a,b,c) = 
  let fact = (c +. 2000.) /. 2000. in 
  let csize = prop2D 0.5 (glob_width, glob_height) in
  add2D
    (prop2D fact (diff2D (a,b) csize))
    csize

let det2D (a,b) (c,d) = 
  (a *. d) -. (b *. c)

let proportional2D v1 v2 =
  det2D v1 v2 = 0.

let intersect2D (p1,v1) (p2,v2) =
  let res    = diff2D p2 p1 in
  let t      = (det2D res v2) /. (det2D v1 v2) in
  add2D p1 (prop2D t v1)

let interpolate2D p1 p2 p3 p4 =
  let vleft = diff2D p1 p2 in
  let mainv = diff2D p2 p3 in
  let alpha1 = (to_angle vleft) -. (to_angle mainv) in
  let vright = diff2D p4 p3 in 
  let mainv' = diff2D p3 p2 in
  let alpha2 = (to_angle vright) -. (to_angle mainv') in
  let newv1 = rotate mainv' (alpha1 /. 2.) in
  let newv2 = rotate mainv (alpha2 /. 2.) in
  intersect2D (p2, newv1) (p3, newv2)
