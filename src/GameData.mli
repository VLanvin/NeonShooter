open Globals

class virtual game_data : object

  method virtual get_psystem : ParticleSystem.t

  method virtual get_emanager : EntityManager.entity_manager

  method virtual get_window : OcsfmlWindow.window

  method virtual get_warpgrid : WarpingGrid.t

end

val state_stack : game_data Stack.t
