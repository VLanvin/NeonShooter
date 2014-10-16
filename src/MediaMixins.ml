open Globals

(* Mixin for renderable objects *)
class virtual renderable = object
  val virtual mutable texture_name : string
  val virtual mutable color : OcsfmlGraphics.Color.t

  method texture_name = texture_name

  method color = color
end
