#lang racket/base

(require racket/contract/base
         racket/port
         "request.rkt"
         "meta.rkt")

(provide (contract-out
          [open-aoc-input (->* (aoc-session? advent-year? advent-day?)
                               (#:cache (or/c boolean? path-string?)
                                #:contact-info string?)
                               input-port?)]
          [fetch-aoc-input (->* (aoc-session? advent-year? advent-day?)
                                (#:cache (or/c boolean? path-string?)
                                 #:contact-info string?)
                                string?)]
          [advent-day? flat-contract?]
          [advent-year? flat-contract?]))

(define advent-day? (integer-in 1 25))
(define advent-year? (and/c exact-integer? (>=/c 2015)))

(define (open-aoc-input session year day
                        #:cache [cache #t]
                        #:contact-info [contact-info (find-contact-info)])
  (aoc-request session year "day" day "input"
               #:cache cache
               #:contact-info contact-info))

(define (fetch-aoc-input session year day
                         #:cache [cache #t]
                         #:contact-info [contact-info (find-contact-info)])
  (port->string (open-aoc-input session year day
                                #:cache cache
                                #:contact-info contact-info)))
