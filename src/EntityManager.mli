open Globals

class entity_manager : object

  method add_projectile : Projectile.projectile_abstract -> unit

  method projectiles : Projectile.projectile_abstract list

  method update : float -> unit

  method add_iaship : ShipMixins.base_ship -> unit

  method add_playership : ShipMixins.base_ship -> unit

  method ships : ShipMixins.base_ship list

  method ia_ships : ShipMixins.base_ship list

  method player_ships : ShipMixins.base_ship list

end
