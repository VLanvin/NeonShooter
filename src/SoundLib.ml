open OcsfmlAudio

type t = (string, sound) Hashtbl.t

let create () = Hashtbl.create 13

let loadSound t path =
  let i,i' = String.rindex path '.', String.rindex path '/' in 
  let name = String.sub path (i'+1) (i-i'-1) in 
  let ext  = String.sub path (i+1) (String.length path - i - 1) in
  if ext = "wav" || ext = "mp3" then begin 
    let snd = new sound ~buffer:(new sound_buffer (`File path)) () in 
    print_endline (name ^ "." ^ ext ^ " ... stored");
    Hashtbl.add t name snd
  end

let rec loadDir t prefix path = 
  if Sys.is_directory (prefix ^ path) then begin
    let children = Sys.readdir (prefix ^ path ^ "/") in 
    Array.iter (loadDir t (prefix ^ path ^ "/")) children
  end
  else
    loadSound t (prefix ^ path)

let load t prefix = 
  let children = Sys.readdir prefix in 
  Array.iter (loadDir t prefix) children

let get t n = 
  try 
    Hashtbl.find t n
  with
    |Not_found -> failwith ("Sound : " ^ n ^ " not found")

let global_sound_lib = create ()
