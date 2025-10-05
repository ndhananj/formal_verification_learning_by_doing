(* 03_bounded_queue.sml *)
fun say s = TextIO.print (s ^ "\n")

structure BQ =
struct
  datatype 'a queue =
    Q of { cap:int,
           data: 'a list ref,
           m: Thread.Mutex.mutex,
           notEmpty: Thread.ConditionVar.conditionVar,
           notFull:  Thread.ConditionVar.conditionVar }

  fun mk cap =
    Q { cap      = cap,
        data     = ref [],
        m        = Thread.Mutex.mutex (),
        notEmpty = Thread.ConditionVar.condVar (),
        notFull  = Thread.ConditionVar.condVar () }

  fun push (Q{cap, data, m, notEmpty, notFull}, x) =
    (Thread.Mutex.lock m;
     while (length (!data) >= cap) do Thread.ConditionVar.wait (notFull, m);
     data := !data @ [x];
     Thread.ConditionVar.signal notEmpty;
     Thread.Mutex.unlock m)

  fun pop (Q{data, m, notEmpty, notFull, ...}) =
    (Thread.Mutex.lock m;
     while (null (!data)) do Thread.ConditionVar.wait (notEmpty, m);
     val x  = hd (!data)
     val xs = tl (!data)
     val _  = data := xs
     val _  = Thread.ConditionVar.signal notFull
     val _  = Thread.Mutex.unlock m
    in x end)
end

(* demo: one producer, one consumer *)
val q   = BQ.mk 2
val sum = ref 0

fun producer () =
  (List.app (fn x => (BQ.push (q, x);
                      say ("produced " ^ Int.toString x);
                      OS.Process.sleep (Time.fromMilliseconds 5)))
            [1,2,3,4,5];
   say "producer: done")

fun consumer () =
  let fun loop 0 = ()
        | loop k =
           let val x = BQ.pop q
           in sum := !sum + x;
              say ("consumed " ^ Int.toString x);
              loop (k-1)
           end
  in loop 5; say ("consumer: sum=" ^ Int.toString (!sum)) end

val _ = Thread.fork (producer, [])
val _ = Thread.fork (consumer, [])
val _ = OS.Process.sleep (Time.fromMilliseconds 500)  (* allow threads to finish *)

fun main () = ()
