let ifsome opt f = 
  match opt with
  |None -> ()
  |Some(e) -> f e

let (>?) = ifsome

let glob_width = 800.

let glob_height = 600.
