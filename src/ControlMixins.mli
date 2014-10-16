open Globals

class virtual orient_mouse : object

  inherit PhysicsMixins.time_updatable

  val virtual mutable position : (float * float)
  
  val virtual mutable orientation : float

end
