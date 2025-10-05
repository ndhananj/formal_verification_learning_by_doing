(* 01_parmap.sml *)
structure ParMap =
struct
  fun parMap f xs =
    let
      val n   = length xs
      val m   = Thread.Mutex.mutex ()
      val cv  = Thread.ConditionVar.conditionVar ()  
      val out : 'b option Array.array = Array.array (n, NONE)
      val remaining = ref n

      fun put (i, y) =
        (Thread.Mutex.lock m;
         Array.update (out, i, SOME y);
         remaining := !remaining - 1;
         if !remaining = 0 then Thread.ConditionVar.broadcast cv else ();
         Thread.Mutex.unlock m)

      fun spawn (i, x) = Thread.Thread.fork (fn () => put (i, f x), [])  
      val _ =
        List.app (fn (i,x) => spawn (i,x))
                 (ListPair.zip (List.tabulate (n, fn i => i), xs))

      (* wait until remaining=0 (guarded by mutex to avoid races) *)
      val _ =
        (Thread.Mutex.lock m;
         while (!remaining > 0) do Thread.ConditionVar.wait (cv, m);
         Thread.Mutex.unlock m)
    in
      List.tabulate (n, fn i => valOf (Array.sub (out, i)))
    end
end

(* demo *)
val input = List.tabulate (8, fn i => i+1)
val squares = ParMap.parMap (fn x => x*x) input
val _ = List.app (fn x => TextIO.print (Int.toString x ^ " ")) squares
val _ = TextIO.print "\n"

fun main () = ()
