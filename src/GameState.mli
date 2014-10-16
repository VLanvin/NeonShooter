open Globals

class game_state : OcsfmlGraphics.render_window -> object

  inherit GameData.game_data

  method main_loop : unit

  method get_psystem : ParticleSystem.t

  method get_window : OcsfmlWindow.window

  method get_emanager : EntityManager.entity_manager

  method get_warpgrid : WarpingGrid.t

end
