open Globals
open Geometry

let spawner = object(self)

  val mutable generators = []
  val mutable total_proba = 0.
  val mutable last_generation = Unix.gettimeofday ()
  val mutable frequency = 2.

  method register f p = 
    generators <- (f,p)::generators; 
    total_proba <- p+.total_proba

  method private generate = 
    let entity_manager = (Stack.top GameData.state_stack)#get_emanager in
    let pos = (Random.float glob_width, Random.float glob_height) in
    let rnd = Random.float total_proba in
    last_generation <- Unix.gettimeofday ();
    let rec aux p = function
      |[] -> assert false
      |(f,pr)::q -> if p <= pr then f pos else aux (p -. pr) q
    in aux rnd generators
    |> entity_manager#add_iaship

  method update = 
    if Unix.gettimeofday () -. last_generation >= frequency then
      self#generate
end
    
