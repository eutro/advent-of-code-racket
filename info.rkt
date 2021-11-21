#lang info
(define collection "advent-of-code")
(define deps '("base" "net-lib"))
(define build-deps '("scribble-lib" "racket-doc"))
(define scribblings '(("scribblings/advent-of-code.scrbl" ())))
(define pkg-desc "Package for fetching Advent of Code input.")
(define version "1.0")
(define pkg-authors '(eutro))
(define raco-commands
  '(("aoc" (submod advent-of-code main) "Advent of Code related commands" #f)))
