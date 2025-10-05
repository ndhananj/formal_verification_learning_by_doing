(* intro_polyml.sml — minimal single-file Poly/ML intro test *)

(* 1) basics: values, types, expressions *)
val i = 2 + 3
val b = i > 4
val _ = print ("sum=" ^ Int.toString i ^ " b=" ^ Bool.toString b ^ "\n")

(* 2) tuples & records *)
val p = (1, "a")
val r = {x = 1, y = 2}
val _ = PolyML.print ("pair p =", p)
val _ = PolyML.print ("record r =", r)

(* 3) lists, higher-order functions, type inference *)
val xs = [1,2,3]
fun sq x = x * x
val ys = List.map sq xs
val _ = PolyML.print ("ys = ", ys)

(* 4) options + simple pattern matching *)
fun safe_hd []      = NONE
  | safe_hd (x::_)  = SOME x
val _ = PolyML.print ("safe_hd xs = ", safe_hd xs)
val _ = PolyML.print ("safe_hd [] = ", safe_hd [])

(* 5) case-expressions / destructuring *)
val _ = (case p of (a, s) => print ("p=(" ^ Int.toString a ^ "," ^ s ^ ")\n"))

(* 6) user datatypes + recursion *)
datatype 'a tree = Leaf | Node of 'a * 'a tree * 'a tree
val t = Node (10, Node (5, Leaf, Leaf), Leaf)
fun size Leaf = 0
  | size (Node(_, l, r)) = 1 + size l + size r
val _ = print ("size t = " ^ Int.toString (size t) ^ "\n")

(* 7) recursion (factorial) *)
fun fact 0 = 1
  | fact n = n * fact (n-1)
val _ = print ("fact 5 = " ^ Int.toString (fact 5) ^ "\n")

(* 8) references (mutable state) *)
val counter = ref 0
fun bump () = (counter := !counter + 1; !counter)
val _ = print ("bump -> " ^ Int.toString (bump ()) ^ ", " ^ Int.toString (bump ()) ^ "\n")

(* 9) arrays (imperative basis structures) *)
val a = Array.fromList [10,20,30]
val _ = Array.update (a, 1, 99)
val _ = print ("array[1] = " ^ Int.toString (Array.sub (a, 1)) ^ "\n")

(* 10) exceptions + handlers *)
exception Oops of string
fun risky n = if n < 0 then raise Oops "neg" else n
val _ = print ("risky 1 = " ^ Int.toString (risky 1) ^ "\n")
val _ = (risky (~1) handle Oops msg => (print ("handled:" ^ msg ^ "\n"); 0))

(* 11) modules: signature, structure, functor *)
signature COUNTER = sig val inc: unit -> int val get: unit -> int end
structure Counter :> COUNTER = struct
  val r = ref 0
  fun inc () = (r := !r + 1; !r)
  fun get () = !r
end
val _ = print ("Counter: " ^ Int.toString (Counter.inc ()) ^ "," ^ Int.toString (Counter.get ()) ^ "\n")

signature PARAM = sig val k : int end
functor MakeAdder (P: PARAM) = struct fun add x = x + P.k end
structure Add5 = MakeAdder(struct val k = 5 end)
val _ = print ("Add5 3 = " ^ Int.toString (Add5.add 3) ^ "\n")

(* Provide a main for polyc; top-level code above already exercised features. *)
fun main () = ()

