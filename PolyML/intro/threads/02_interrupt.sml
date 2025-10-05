(* 02_interrupt.sml *)
fun say s = TextIO.print (s ^ "\n")

structure InterruptDemo =
struct
  fun run () =
    let
      val done = ref false

      fun worker () =
        (say "worker: start";
         let
           fun loop 0 = ()
             | loop k =
                 (OS.Process.sleep (Time.fromMilliseconds 10);
                  say "worker: tick";
                  loop (k-1))
         in (loop 100) handle Interrupt => say "worker: INTERRUPTED" end;
         done := true; say "worker: stop")

      val th = Thread.fork (worker, [])
      val _  = OS.Process.sleep (Time.fromMilliseconds 50)
      val _  = Thread.interrupt th  (* try to raise Interrupt in that thread *)

      fun wait_done () =
        if !done then () else (OS.Process.sleep (Time.fromMilliseconds 10); wait_done ())
    in
      wait_done ()
    end
end

val _ = InterruptDemo.run ()
fun main () = ()
