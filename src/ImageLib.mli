type t

val create : unit -> t

val loadImage : t -> string -> unit

val load : t -> string -> unit

val get : t -> string -> OcsfmlGraphics.texture

val global_image_lib : t
