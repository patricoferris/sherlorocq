(lang dune 2.8)
(using menhir 2.0)
(generate_opam_files true)

(name sherlorocq)
(source (github art-w/sherlocode))
(license MIT)
(authors "Arthur Wendling")
(maintainers "art.wendling@gmail.com")
(version 0.1)

(package
  (name sherlorocq)
  (synopsis "Realtime grep for OCaml sources available on opam")
  (depends
    (ocaml (and (>= "4.08") (< "5.0.0")))
    astring
    (ancient (>= "0.9.1"))
    (cmdliner (>= "1.1.0"))
    (lwt (>= "4.5.2"))
    (higlo (>= "0.8"))
    (tyxml (>= "4.5.0"))
    (dream (= "1.0.0~alpha3"))))
