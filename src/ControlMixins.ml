open Globals
open Geometry
open PhysicsMixins

class virtual orient_mouse = object
  inherit time_updatable

  val virtual mutable position : (float * float)
  val virtual mutable orientation : float

  initializer
    updates <- (fun _ ->
      orientation <- to_angle 
        (add2D 
          (foi2D 
            (OcsfmlWindow.Mouse.get_relative_position 
            (Stack.top GameData.state_stack)#get_window))
          (prop2D (-1.) position)
    )) :: updates
end
             
