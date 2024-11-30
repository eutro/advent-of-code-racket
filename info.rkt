#lang info
(define collection "advent-of-code")
(define deps '("base" "net-lib" "http-easy"))
(define build-deps '("scribble-lib" "racket-doc" "net-doc"))
(define scribblings '(("scribblings/advent-of-code.scrbl" ())))
(define pkg-desc "Package for fetching Advent of Code input.")
(define version "1.0.2")
(define pkg-authors '(eutro))
(define raco-commands
  '(("aoc" (submod advent-of-code main) "Fetch Advent of Code puzzle input" #f)))
