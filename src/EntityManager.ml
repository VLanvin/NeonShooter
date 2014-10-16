open Globals
open Geometry

class entity_manager = object(self)
  
  val mutable projectiles : Projectile.projectile_abstract list = []

  val mutable ia_ships : ShipMixins.base_ship list = []

  val mutable player_ships : ShipMixins.base_ship list = []


  method add_projectile (p : Projectile.projectile_abstract) = 
    projectiles <- p :: projectiles

  method projectiles = projectiles

  method update dt = 
    let rec update_proj = function
      |[] -> []
      |t::q -> t#update dt;
        if t#dead then update_proj q
        else t :: (update_proj q)
    in 
    self#handle_collisions;
    projectiles <- update_proj projectiles;
    ia_ships <- update_proj ia_ships;
    player_ships <- update_proj player_ships

  method ships = player_ships @ ia_ships

  method ia_ships = ia_ships

  method player_ships = player_ships

  method add_iaship (s : ShipMixins.base_ship) =
    ia_ships <- s :: ia_ships

  method add_playership (s : ShipMixins.base_ship) =
    player_ships <- s :: player_ships

  method private colliding p1 r1 p2 r2 =
    (squarenorm2D (diff2D p2 p1)) <= (r2 +. r1) *. (r2 +. r1)

  method private proj_ennemy_collisions = 
    List.iter (fun p ->  
      List.iter (fun e -> 
        if self#colliding p#position p#collision_radius
           e#position e#collision_radius && p#collidable
           && e#collidable then begin
             p#kill;
             e#kill
        end
      ) ia_ships
    ) projectiles 

  method private ennemy_player_collisions =
    List.iter (fun p ->
      List.iter (fun e ->
        if self#colliding p#position p#collision_radius
           e#position e#collision_radius && p#collidable
           && e#collidable then begin
             p#kill;
             e#kill
        end
      ) ia_ships
    ) player_ships

  method private handle_collisions = 
    self#proj_ennemy_collisions

end

