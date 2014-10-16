type point

val pos2D : point -> (float * float)

type t

val create : float -> float -> float -> t

val update : t -> float -> unit

val points : t -> point array array

val explosive : t -> float -> (float * float * float) -> float -> unit

val implosive : t -> float -> (float * float * float) -> float -> unit
