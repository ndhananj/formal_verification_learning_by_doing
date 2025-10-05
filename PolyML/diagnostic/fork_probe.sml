(* fork_probe.sml - Test thread creation API *)

val _ = print "=== Testing Thread Creation ===\n\n";

val _ = print "Test 1: Thread.fork...\n";
val forkTest1 = 
  (let 
    val _ = Thread.fork (fn () => (), []) 
   in "[OK] Thread.fork works" end)
  handle _ => "[FAIL] Thread.fork failed";
val _ = print (forkTest1 ^ "\n\n");

val _ = print "Test 2: Thread.Thread.fork...\n";
val forkTest2 = 
  (let 
    val t = Thread.Thread.fork (fn () => (), []) 
   in "[OK] Thread.Thread.fork works" end)
  handle _ => "[FAIL] Thread.Thread.fork failed";
val _ = print (forkTest2 ^ "\n\n");

val _ = print "=== Fork Test Complete ===\n";
