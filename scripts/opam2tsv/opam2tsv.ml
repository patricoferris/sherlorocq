(*
opam list --columns=name,dev-repo: --separator=, --repo=coq-released --available --short | _build/default/scripts/opam2tsv/opam2tsv.exe
*)

let process_url s =
  let len = String.length s in
  let no_quotes = String.sub s 1 (len - 2) in
  match Astring.String.cut ~sep:"//" no_quotes with
  | Some (_, url) -> (
    match Astring.String.cut ~sep:".git" url with
    | Some (v, _) -> v
    | None -> url
  )
  | None -> s

let () =
  let rec loop () = match In_channel.input_line In_channel.stdin with
    | Some line -> (
      match String.split_on_char ',' line with
      | [ name; url ] ->
        let name = String.trim name in
        Out_channel.output_string Out_channel.stdout (name ^ "\t" ^ process_url url);
        Out_channel.output_char Out_channel.stdout '\n';
        loop ()
      | _ -> loop ()
    )
    | None -> ()
  in
  loop ()