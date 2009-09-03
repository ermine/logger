open Ocamlbuild_plugin
open Myocamlbuild_config

let _ = dispatch begin function
  | After_rules ->
      flag ["ocaml"; "pp"; "use_logger.syntax"] &
        S[A"camlp4o"; A"-I"; A"logger"; A"pa_logger.cma"];
      dep ["ocaml"; "ocamldep"; "use_logger.syntax"]
        ["pa_logger.cma"];
      ocaml_lib "logger";

      install_lib "logger" ["pa_logger.cmo"
        ]
 
  | _ -> ()
end
