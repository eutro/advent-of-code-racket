#lang racket/base

(require racket/contract/base
         racket/port
         advent-of-code/request)

(provide (contract-out
          [open-aoc-input (->* (aoc-session? advent-year? advent-day?)
                               (#:cache (or/c boolean? path-string?))
                               input-port?)]
          [fetch-aoc-input (->* (aoc-session? advent-year? advent-day?)
                                (#:cache (or/c boolean? path-string?))
                                string?)]
          [advent-day? flat-contract?]
          [advent-year? flat-contract]))

(define advent-day? (integer-in 1 25))
(define advent-year? (and/c exact-integer? (>=/c 2015)))

(define (open-aoc-input session year day #:cache [cache #f])
  (aoc-request session year "day" day "input" #:cache cache))

(define (fetch-aoc-input session year day #:cache [cache #f])
  (port->string (open-aoc-input session year day #:cache cache)))
