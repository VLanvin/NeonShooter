open OcsfmlGraphics

let framecount = ref 0

let current_fps = ref 0

let last_time = ref (Unix.gettimeofday ())

let font = new font (`File "ressources/digit.ttf")

let display (target : render_window) =
  incr framecount;
  let t = Unix.gettimeofday () in
  if t -. !last_time >= 1. then begin
    last_time := t;
    current_fps := !framecount;
    framecount := 0
  end;
  new text ~string:(string_of_int !current_fps)
     ~font
     ~character_size:42
     ~color:Color.blue ()
  |> target#draw;


