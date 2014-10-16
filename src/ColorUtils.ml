open Globals
open OcsfmlGraphics

let light_blue = Color.rgba 120 120 255 150 

let gold = Color.rgba 255 200 50 150

let silver = Color.rgba 160 180 200 150

let pink = Color.rgba 255 110 255 150

let red = Color.rgba 255 110 110 150

let purple = Color.rgba 120 50 255 200

let deep_blue = Color.rgba 30 30 255 90

let green = Color.rgba 85 255 150 150

let yellow = Color.rgba 255 255 50 150

let colors_array = [|light_blue; gold; deep_blue; silver; 
  pink; red; purple; green; yellow |]

let random_color () = colors_array.(Random.int (Array.length colors_array))
