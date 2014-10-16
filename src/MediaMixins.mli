open Globals

class virtual renderable : object

  val virtual mutable texture_name : string

  val virtual mutable color : OcsfmlGraphics.Color.t

  method texture_name : string

  method color : OcsfmlGraphics.Color.t
end
