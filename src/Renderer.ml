open Globals
open Geometry
open ParticleSystem
open Projectile
open OcsfmlGraphics

type t = {pp_texture : render_texture; 
          target : render_window;
          bloomer : BloomEffect.t;
          vao1 : vertex_array;
          vao2 : vertex_array}

let create win = 
  let (sx, sy) = win#get_size in 
  {pp_texture = new render_texture sx sy;
   target = win;
   bloomer = BloomEffect.create (sx, sy);
   vao1 = new vertex_array ~primitive_type:PrimitiveType.Lines [];
   vao2 = new vertex_array ~primitive_type:PrimitiveType.Quads []}

let draw_line (rt : #render_target) origin ending color thickness = 
  new rectangle_shape ~position:origin 
    ~size:(distance2D ending origin, thickness) ~fill_color:color
    ~rotation:(to_deg (to_angle (diff2D ending origin))) ()
  |> rt#draw ~blend_mode:BlendMode.BlendAdd

let compute_thin_line vao origin ending color = OcsfmlGraphics.Vertex.(
  vao#append (create ~position:origin ~color ());
  vao#append (create ~position:ending ~color ()))

let compute_line vao origin ending color thickness = OcsfmlGraphics.Vertex.(
  let vector = diff2D ending origin in
  let (nx, ny) = prop2D (1. /. (norm2D vector)) vector in
  let offset_vec = prop2D (thickness /. 2.) (ny, -.nx) in 
  vao#append (create ~position:(add2D offset_vec origin) ~color ());
  vao#append (create ~position:(add2D offset_vec ending) ~color ());
  vao#append (create ~position:(diff2D ending offset_vec) ~color ());
  vao#append (create ~position:(diff2D origin offset_vec) ~color ()))

let draw_circle (rt : #render_target) position fill_color radius =
  new circle_shape ~position ~fill_color ~radius ()
  |> rt#draw ~blend_mode:BlendMode.BlendAdd

let render_grid (rt : #render_target) (g : WarpingGrid.t) vao1 vao2 =
  let pts = WarpingGrid.points g in
  let columns = Array.length pts in
  let rows = Array.length pts.(0) in
  for j = 0 to rows - 1 do
    for i = 0 to columns - 1 do
      let myp = WarpingGrid.pos2D pts.(i).(j) in
      (*if i > 1 && i < columns - 1 then begin
        let controlpl = WarpingGrid.pos2D pts.(i-2).(j) in
        let leftp = WarpingGrid.pos2D pts.(i-1).(j) in
        let controlpr = WarpingGrid.pos2D pts.(i+1).(j) in
        let interpolp = interpolate2D controlpl leftp myp controlpr in
        if j mod 3 <> 1 then begin
          compute_thin_line vao1 leftp interpolp ColorUtils.deep_blue;
          compute_thin_line vao1 interpolp myp ColorUtils.deep_blue
        end else begin
          compute_line vao2 leftp interpolp ColorUtils.deep_blue 3.;
          compute_line vao2 interpolp myp ColorUtils.deep_blue 3.
        end
      end else *)if i > 0 then begin
        let leftp = WarpingGrid.pos2D pts.(i-1).(j) in
          if j mod 3 <> 1 then 
            compute_thin_line vao1 leftp myp ColorUtils.deep_blue
          else
            compute_line vao2 leftp myp ColorUtils.deep_blue 3.
      end;(* if j > 1 && j < rows - 1 then begin 
        let controlpu = WarpingGrid.pos2D pts.(i).(j-2) in
        let upp = WarpingGrid.pos2D pts.(i).(j-1) in
        let controlp = WarpingGrid.pos2D pts.(i).(j+1) in
        let interpolp = interpolate2D controlpu upp myp controlp in 
        if i mod 3 <> 1 then begin
          compute_thin_line vao1 upp interpolp ColorUtils.deep_blue;
          compute_thin_line vao1 interpolp myp ColorUtils.deep_blue
        end else begin
          compute_line vao2 upp interpolp ColorUtils.deep_blue 3.;
          compute_line vao2 interpolp myp ColorUtils.deep_blue 3.
        end
      end else *)if j > 0 then begin
        let upp = WarpingGrid.pos2D pts.(i).(j-1) in
          if i mod 3 <> 1 then
            compute_thin_line vao1 upp myp ColorUtils.deep_blue
          else
            compute_line vao2 upp myp ColorUtils.deep_blue 3.
      end;
      if i > 0 && j > 0 then begin
        let ulp = WarpingGrid.pos2D pts.(i-1).(j-1) in
        let leftp = WarpingGrid.pos2D pts.(i-1).(j) in
        let upp = WarpingGrid.pos2D pts.(i).(j-1) in
        compute_thin_line vao1 (prop2D 0.5 (add2D ulp upp))
          (prop2D 0.5 (add2D leftp myp)) ColorUtils.deep_blue;
        compute_thin_line vao1 (prop2D 0.5 (add2D ulp leftp))
          (prop2D 0.5 (add2D upp myp)) ColorUtils.deep_blue;
      end
    done;
  done;
  rt#draw ~blend_mode:BlendMode.BlendAdd vao1;
  rt#draw ~blend_mode:BlendMode.BlendAdd vao2;
  vao1#clear; vao2#clear

let render_particle (rt : #render_target) (p : #particle_base) = 
  new sprite ~position:p#position ~scale:p#scale 
    ~rotation:(to_deg p#orientation) 
    ~texture:(ImageLib.(get global_image_lib p#texture_name))
    ~color:p#color ~origin:p#origin ()
  |> rt#draw ~blend_mode:BlendMode.BlendAdd

let render_projectile (rt : #render_target) (p : #projectile_abstract) = 
  new sprite ~position:p#position ~scale:p#scale 
    ~rotation:(to_deg p#orientation) 
    ~texture:(ImageLib.(get global_image_lib p#texture_name))
    ~color:p#color ~origin:p#origin ()
  |> rt#draw ~blend_mode:BlendMode.BlendAdd

let render_ship (rt : #render_target) (p : #ShipMixins.base_ship) =
  new sprite ~position:p#position ~scale:p#scale
    ~rotation:(to_deg p#orientation) 
    ~texture:(ImageLib.(get global_image_lib p#texture_name))
    ~color:p#color ~origin:p#origin ()
  |> rt#draw 

let render_cursor (rt : #render_target) position = 
  new sprite ~texture:ImageLib.(get global_image_lib "pointer")
    ~position:(foi2D position) ()
  |> rt#draw


let render t gdata = 
  (* Rendering on post-processing texture *)
  t.pp_texture#clear ();
  render_grid t.pp_texture gdata#get_warpgrid t.vao1 t.vao2;
  List.iter 
    (render_particle t.pp_texture) 
    (ParticleSystem.particle_list gdata#get_psystem);
  List.iter
    (render_projectile t.pp_texture)
    (gdata#get_emanager#projectiles);
  List.iter
    (render_ship t.pp_texture)
    (gdata#get_emanager#ships);
  t.pp_texture#display;
  (* Post processing & final rendering *)
  BloomEffect.blooming t.bloomer t.pp_texture t.target;

  FPS.display t.target;
  render_cursor t.target 
    (OcsfmlWindow.Mouse.get_relative_position gdata#get_window)


