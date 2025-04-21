open Lwt.Syntax

let ( / ) a b = a ^ "/" ^ b

let api ~cursor query =
  let+ results, stop = Search.api ~cursor query in
  Present.present ~query ~start:cursor ~stop results

let api ~cursor query = if query = "" then Lwt.return Ui.frontpage else api ~cursor query
let get_query params = Option.value ~default:"" (Dream.query params "q")

let get_cursor ~db params =
  match Dream.query params "ofs" with
  | None -> Db.cursor_empty ~db
  | Some shard_offset -> Db.cursor_of_string ~db shard_offset

let root ~db fn params =
  let query = get_query params in
  let cursor = get_cursor ~db params in
  let* result = fn ~cursor query in
  Dream.html result

let string_of_tyxml html = Format.asprintf "%a" (Tyxml.Html.pp ()) html
let string_of_tyxml' html = Format.asprintf "%a" (Tyxml.Html.pp_elt ()) html

let cache : int -> Dream.middleware =
 fun max_age f req ->
  let+ response = f req in
  Dream.add_header response "Cache-Control" ("public, max-age=" ^ string_of_int max_age) ;
  response

let webserver ~static_dir ~db ~max_age =
  Dream.run ~interface:"127.0.0.1" ~port:8888
  @@ Dream.logger
  @@ cache max_age
  @@ Dream.router
       [ Dream.get
           "/"
           (root ~db (fun ~cursor q ->
              let+ result = api ~cursor q in
              string_of_tyxml @@ Ui.template q result))
       ; Dream.get
           "/api"
           (root ~db (fun ~cursor q ->
              let+ result = api ~cursor q in
              string_of_tyxml' result))
       ; Dream.get "/s.css" (Dream.from_filesystem static_dir "style.css")
       ; Dream.get "/robots.txt" (Dream.from_filesystem static_dir "robots.txt")
       ; Dream.get "/favicon.ico" (Dream.from_filesystem static_dir "favicon.ico")
       ]

let main path static_dir max_age =
  let url_tsv = static_dir / "urls.tsv" in 
  Link.load url_tsv ;
  let source_file = path ^ "/source.txt" in
  let ancient_file = path ^ "/ancient.db" in
  let db = Db.db_open_in ~source:source_file ~db:ancient_file in
  webserver ~static_dir ~db ~max_age

open Cmdliner

let path =
  let doc = "Directory where the db is available" in
  Arg.(required & pos 0 (some dir) None & info [] ~docv:"DB" ~doc)

let cache_max_age =
  let doc = "HTTP cache max age (in seconds)" in
  Arg.(value & opt int 3600 & info [ "c"; "cache" ] ~docv:"MAX_AGE" ~doc)

let static =
  let doc = "Static directory" in
  Arg.(value & opt dir "static" & info [ "s"; "static" ] ~docv:"STATIC" ~doc)

let www = Term.(const main $ path $ static $ cache_max_age)

let cmd =
  let doc = "Webserver for sherlocode" in
  let info = Cmd.info "www" ~doc in
  Cmd.v info www

let () = exit (Cmd.eval cmd)
