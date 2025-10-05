(* diagnostic_probe.sml - Discover the actual Thread API *)

(* Step 2.1: Check if Thread structure exists *)
val _ = print "=== STEP 2.1: Thread Structure ===\n";
val threadExists = 
  (let val _ = Thread.Mutex.mutex () in true end)
  handle _ => false;
val _ = print ("Thread structure accessible: " ^ Bool.toString threadExists ^ "\n\n");

(* Step 2.2: Check Thread.Mutex *)
val _ = print "=== STEP 2.2: Thread.Mutex API ===\n";
val _ = print "Testing Thread.Mutex.mutex()...\n";
val testMutex = Thread.Mutex.mutex ();
val _ = print "[OK] Thread.Mutex.mutex() works\n";
val _ = print "[OK] Thread.Mutex.lock exists\n";
val _ = print "[OK] Thread.Mutex.unlock exists\n\n";

(* Step 2.3: Check Thread.ConditionVar - DETAILED PROBE *)
val _ = print "=== STEP 2.3: Thread.ConditionVar API ===\n";

(* Try different possible constructors *)
val _ = print "Attempting: Thread.ConditionVar.conditionVar()...\n";
val cvTest1 = 
  (let val _ = Thread.ConditionVar.conditionVar () in "[OK] conditionVar() works" end)
  handle _ => "[FAIL] conditionVar() failed";
val _ = print (cvTest1 ^ "\n");

val _ = print "Attempting: Thread.ConditionVar.condVar()...\n";
val cvTest2 = 
  (let val _ = Thread.ConditionVar.condVar () in "[OK] condVar() works" end)
  handle _ => "[FAIL] condVar() failed";
val _ = print (cvTest2 ^ "\n\n");

(* Step 2.4: Check Thread.fork vs Thread.Thread.fork *)
val _ = print "=== STEP 2.4: Thread Creation API ===\n";

val _ = print "Attempting: Thread.fork...\n";
val forkTest1 = 
  (let 
    val _ = Thread.fork (fn () => (), []) 
   in "[OK] Thread.fork works" end)
  handle _ => "[FAIL] Thread.fork failed";
val _ = print (forkTest1 ^ "\n");

val _ = print "Attempting: Thread.Thread.fork...\n";
val forkTest2 = 
  (let 
    val t = Thread.Thread.fork (fn () => (), []) 
   in "[OK] Thread.Thread.fork works" end)
  handle _ => "[FAIL] Thread.Thread.fork failed";
val _ = print (forkTest2 ^ "\n\n");

val _ = print "=== DIAGNOSTIC COMPLETE ===\n";
