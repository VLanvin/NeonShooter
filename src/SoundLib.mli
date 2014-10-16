type t

val create : unit -> t

val loadSound : t -> string -> unit

val load : t -> string -> unit

val get : t -> string -> OcsfmlAudio.sound

val global_sound_lib : t
