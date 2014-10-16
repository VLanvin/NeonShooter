open Globals
open PhysicsMixins

class virtual slowing_down : float -> object

  inherit time_updatable

  val mutable virtual speed   : (float * float)

end

class virtual speed_to_scale_x : float -> object

  inherit time_updatable

  val mutable virtual speed : (float * float)

  val mutable virtual scale : (float * float)

end

class virtual speed_to_orientation : object
  
  inherit time_updatable

  val mutable virtual speed : (float * float)

  val mutable virtual orientation : float

end

class virtual speed_to_alpha : float -> object

  inherit time_updatable

  val mutable virtual color : OcsfmlGraphics.Color.t

  val mutable virtual speed : (float * float)

  method virtual percent_life : float

end

class virtual blackhole : float -> object
  val mutable virtual speed : (float * float)
  val mutable virtual position : (float * float)
  val mutable virtual updates : (float -> unit) list
end
