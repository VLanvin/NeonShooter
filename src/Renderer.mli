open Globals
open OcsfmlGraphics

type t

val create : render_window -> t

val render : t -> GameData.game_data -> unit
