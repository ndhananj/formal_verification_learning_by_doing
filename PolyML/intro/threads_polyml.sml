(* threads_polyml.sml — minimal Poly/ML thread examples *)

(* small utility *)
fun say s = TextIO.print (s ^ "\n")

(* =========================
   Example 1: parallel map
   - Spawns |xs| threads with Thread.fork (… , []).
   - Uses Mutex + ConditionVar to wait for completion.
   ========================= *)
structure ThreadsDemo = struct
  fun parMap f xs =
    let
      val n  = length xs
      val m  = Thread.Mutex.mutex ()
      val cv = Thread.ConditionVar.condVar ()
      val out : 'b option Array.array = Array.array (n, NONE)
      val remaining = ref n

      fun put (i, y) =
        (Thread.Mutex.lock m;
         Array.update (out, i, SOME y);
         remaining := !remaining - 1;
         if !remaining = 0 then Thread.ConditionVar.broadcast cv else ();
         Thread.Mutex.unlock m)

      fun spawn (i, x) = Thread.fork (fn () => put (i, f x), [])

      (* launch workers with indices *)
      val _ = List.app (fn (i,x) => spawn (i,x))
                       (ListPair.zip (List.tabulate (n, fn i => i), xs))

      (* wait until remaining = 0 *)
      fun await_done () =
        (Thread.Mutex.lock m;
         if !remaining = 0 then Thread.Mutex.unlock m
         else (Thread.ConditionVar.wait (cv, m); Thread.Mutex.unlock m; await_done()))
    in
      await_done ();
      List.tabulate (n, fn i => valOf (Array.sub (out, i)))
    end
end

(* =========================
   Example 2: interrupt a thread
   - Main thread interrupts a worker; worker handles Interrupt.
   ========================= *)
structure InterruptDemo = struct
  fun run () =
    let
      val running = ref true

      fun worker () =
        (say "worker: start";
         let
           fun loop 0 = ()
             | loop k =
                 ((OS.Process.sleep (Time.fromMilliseconds 10);
                   say "worker: tick";
                   loop (k-1))
                  handle Interrupt => say "worker: INTERRUPTED")
         in loop 100 end;
         running := false;
         say "worker: stop")

      val th = Thread.fork (worker, [])
      val _  = OS.Process.sleep (Time.fromMilliseconds 50)
      val _  = Thread.interrupt th  (* try to raise Interrupt in that thread *)
      fun spin () =
        if !running then (OS.Process.sleep (Time.fromMilliseconds 10); spin ())
        else ()
    in
      spin ()
    end
end

(* =========================
   Example 3: bounded queue (producer/consumer)
   - Demonstrates wait/signal for notEmpty/notFull conditions.
   ========================= *)
structure QueueDemo = struct
  datatype 'a queue =
    Q of { cap:int,
           data:'a list ref,
           m: Thread.Mutex.mutex,
           notEmpty: Thread.ConditionVar.conditionVar,
           notFull:  Thread.ConditionVar.conditionVar }

  fun mkQueue cap =
    Q { cap      = cap,
        data     = ref [],
        m        = Thread.Mutex.mutex (),
        notEmpty = Thread.ConditionVar.condVar (),
        notFull  = Thread.ConditionVar.condVar () }

  fun push (Q{cap, data, m, notEmpty, notFull}, x) =
    (Thread.Mutex.lock m;
     let fun waitIfFull () =
           if length (!data) < cap then ()
           else (Thread.ConditionVar.wait (notFull, m); waitIfFull ())
     in
       waitIfFull ();
       data := x :: !data;
       Thread.ConditionVar.signal notEmpty;
       Thread.Mutex.unlock m
     end)

  fun pop (Q{data, m, notEmpty, notFull, ...}) =
    (Thread.Mutex.lock m;
     let fun waitIfEmpty () =
           case !data of
                []  => (Thread.ConditionVar.wait (notEmpty, m); waitIfEmpty ())
              | xs  => xs
         val xs  = waitIfEmpty ()
         val x   = hd xs
         val xs' = tl xs
     in
       data := xs';
       Thread.ConditionVar.signal notFull;
       Thread.Mutex.unlock m;
       x
     end)

  fun run () =
    let
      val q   = mkQueue 2
      val sum = ref 0
      fun producer () =
        (List.app (fn x => (push (q, x);
                            say ("produced " ^ Int.toString x);
                            OS.Process.sleep (Time.fromMilliseconds 5)))
                  [1,2,3,4,5];
         say "producer: done")
      fun consumer () =
        let fun loop 0 = ()
              | loop k =
                 let val x = pop q
                 in sum := !sum + x;
                    say ("consumed " ^ Int.toString x);
                    loop (k-1)
                 end
        in loop 5; say ("consumer: sum=" ^ Int.toString (!sum)) end
      val _ = Thread.fork (producer, [])
      val _ = Thread.fork (consumer, [])
      (* crude barrier: give threads time to finish *)
      val _ = OS.Process.sleep (Time.fromMilliseconds 500)
    in () end
end

(* ===== Drive the demos ===== *)
val _ =
  (PolyML.print ("parMap squares = ",
                 ThreadsDemo.parMap (fn x => x*x)
                                   (List.tabulate (8, fn i => i+1)));
   InterruptDemo.run ();
   QueueDemo.run ();
   ())

(* main for polyc *)
fun main () = ()

