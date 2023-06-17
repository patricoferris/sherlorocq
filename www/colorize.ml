module H = Tyxml.Html
module Higlo = Higlo.Lang

let span cl s = H.span ~a:[ H.a_class [ cl ] ] [ H.txt s ]

let html_of_token = function
  | Higlo.Text (str, _) -> H.txt str
  | Symbol (_, (s, _)) -> span "symbol" s
  | String (s, _) -> span "string" s
  | Numeric (s, _) -> span "numeric" s
  | Lcomment (s, _) -> span "comment" s
  | Bcomment (s, _) -> span "comment" s
  | Keyword (_, (s, _)) -> span "kw" s
  | Escape (s, _) -> span "escape" s
  | Directive (s, _) -> span "directive" s
  | Constant (s, _) -> span "constant" s
  | Id (s, _) -> span "ident" s
  | Title (_, (s, _)) -> span "title" s

let string_of_token = function
  | Higlo.Text s
  | Symbol (_, s)
  | String s
  | Numeric s
  | Lcomment s
  | Bcomment s
  | Keyword (_, s)
  | Escape s
  | Directive s
  | Constant s
  | Title (_, s)
  | Id s -> fst s

let token_replace s = function
  | Higlo.Text (_, i) -> Higlo.Text (s, i)
  | Symbol (n, (_, i)) -> Symbol (n, (s, i))
  | String (_, i) -> String (s, i)
  | Numeric (_, i) -> Numeric (s, i)
  | Lcomment (_, i) -> Lcomment (s, i)
  | Bcomment (_, i) -> Bcomment (s, i)
  | Keyword (n, (_, i)) -> Keyword (n, (s, i))
  | Escape (_, i) -> Escape (s, i)
  | Directive (_, i) -> Directive (s, i)
  | Constant (_, i) -> Constant (s, i)
  | Id (_, i) -> Id (s, i)
  | Title (f, (_, i)) -> Title (f, (s, i))

let string_split i str = String.sub str 0 i, String.sub str i (String.length str - i)

let rec take acc n = function
  | [] -> List.rev acc, []
  | t :: ts ->
    let txt = string_of_token t in
    let txt_len = String.length txt in
    if n > txt_len
    then take (t :: acc) (n - txt_len) ts
    else (
      let txt_before, txt_after = string_split n txt in
      let tok_before = token_replace txt_before t in
      let tok_after = token_replace txt_after t in
      List.rev (tok_before :: acc), tok_after :: ts)

let take n ts = take [] n ts

let to_html line =
  let tokens = Higlo.parse ~lang:"ocaml" line in
  List.map html_of_token tokens

let to_html_highlight ~mark line (start_at, end_at) =
  let tokens = Higlo.parse ~lang:"ocaml" line in
  let start, rest = take start_at tokens in
  let inside, rest = take (end_at - start_at) rest in
  List.map html_of_token start
  @ [ mark @@ List.map html_of_token inside ]
  @ List.map html_of_token rest
