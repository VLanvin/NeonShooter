open OcsfmlGraphics

type t = (string, texture) Hashtbl.t

let create () = Hashtbl.create 13

let loadImage t path =
  let i,i' = String.rindex path '.', String.rindex path '/' in 
  let name = String.sub path (i'+1) (i-i'-1) in 
  let ext  = String.sub path (i+1) (String.length path - i - 1) in
  if ext = "png" || ext = "jpg" then begin 
    let tex = new texture (`File path) in 
    tex#set_smooth true;
    print_endline (name ^ " ... stored");
    Hashtbl.add t name tex
  end

let rec loadDir t prefix path = 
  if Sys.is_directory (prefix ^ path) then begin
    let children = Sys.readdir (prefix ^ path ^ "/") in 
    Array.iter (loadDir t (prefix ^ path ^ "/")) children
  end
  else
    loadImage t (prefix ^ path)

let load t prefix = 
  let children = Sys.readdir prefix in 
  Array.iter (loadDir t prefix) children

let get t n = 
  try 
    Hashtbl.find t n
  with
    |Not_found -> failwith ("Image : " ^ n ^ " not found")

let global_image_lib = create ()
