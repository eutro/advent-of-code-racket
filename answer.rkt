#lang racket/base

(require racket/contract/base
         net/uri-codec
         racket/port
         racket/format
         advent-of-code/request
         (only-in advent-of-code/input advent-day? advent-year?))

(provide (contract-out
          [aoc-submit (-> aoc-session? advent-year? advent-day?
                          (or/c 1 2) any/c
                          string?)]
          [aoc-submit* (-> aoc-session? advent-year? advent-day?
                           (or/c 1 2) any/c
                           input-port?)])
         advent-day?
         advent-year?)

(define (aoc-submit* session year day part answer)
  (aoc-request session year "day" day "answer"
               #:post
               (lambda (hs)
                 (values
                  ;; form-data would yield a "; charset=utf-8" at the end,
                  ;; which the server doesn't accept
                  (hash-set hs 'content-type #"application/x-www-form-urlencoded")
                  (alist->form-urlencoded
                   `((level . ,(~a part))
                     (answer . ,(~a answer))))))))

(define (aoc-submit session year day part answer)
  (define response (port->string (aoc-submit* session year day part answer)))
  (define matches (regexp-match #px"<article><p>(.*)</p></article>" response))
  (if matches
      (regexp-replace*
       #px"</?.+?>"
       (regexp-replace*
        #px"  |</?br>"
        (cadr matches)
        "\n")       
       "")
      #f))
