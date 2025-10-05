(* fork_probe2.sml - Test Thread.Thread.fork *)

val _ = print "=== Testing Thread.Thread.fork ===\n\n";

val _ = print "Attempting: Thread.Thread.fork...\n";
val forkTest = 
  (let 
    val t = Thread.Thread.fork (fn () => (), []) 
   in "[OK] Thread.Thread.fork works" end)
  handle _ => "[FAIL] Thread.Thread.fork failed";
val _ = print (forkTest ^ "\n\n");

val _ = print "=== Test Complete ===\n";
