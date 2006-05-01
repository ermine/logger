let _ =
   let log = Some (Logger.open_log "abc.log") in
   let a = 2 +3 in
      LOG WARN log "%d" (2+3) END;
      try
	 int_of_string "a"
      with exn ->
	 LOG EXC log exn END;
	 raise exn
