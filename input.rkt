#lang racket/base

(require racket/contract/base
         racket/port
         advent-of-code/request)

(provide (contract-out
          [open-aoc-input (-> aoc-session? advent-year? advent-day?
                              input-port?)]
          [fetch-aoc-input (-> aoc-session? advent-year? advent-day?
                               string?)]
          [advent-day? flat-contract?]
          [advent-year? flat-contract]))

(define advent-day? (integer-in 1 25))
(define advent-year? (and/c exact-integer? (>=/c 2015)))

(define (open-aoc-input session year day)
  (aoc-request session year "day" day "input"))

(define (fetch-aoc-input session year day)
  (port->string (open-aoc-input session year day)))
