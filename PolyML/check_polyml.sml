(* Try to list some PolyML functions that might exist *)
val _ = print "Testing PolyML functions:\n";
val _ = print ("architecture: " ^ PolyML.architecture() ^ "\n");
val _ = print ("rtsVersion: " ^ Int.toString(PolyML.rtsVersion()) ^ "\n");
