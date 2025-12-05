#lang racket/base

(require racket/contract/base
         net/uri-codec
         racket/port
         racket/format
         "request.rkt"
         "meta.rkt"
         (only-in "input.rkt" advent-day? advent-year?))

(provide (contract-out
          [aoc-submit (->* (aoc-session?
                            advent-year? advent-day?
                            (or/c 1 2) any/c)
                           (#:contact-info string?)
                           string?)]
          [aoc-submit* (->* (aoc-session?
                             advent-year? advent-day?
                             (or/c 1 2) any/c)
                            (#:contact-info string?)
                            input-port?)])
         advent-day?
         advent-year?)

(define (aoc-submit* session year day part answer
                     #:contact-info [contact-info (find-contact-info)])
  (aoc-request session year "day" day "answer"
               #:contact-info contact-info
               #:post
               (lambda (hs)
                 (values
                  ;; form-data would yield a "; charset=utf-8" at the end,
                  ;; which the server doesn't accept
                  (hash-set hs 'content-type #"application/x-www-form-urlencoded")
                  (alist->form-urlencoded
                   `((level . ,(~a part))
                     (answer . ,(~a answer))))))))

(define (aoc-submit session year day part answer
                    #:contact-info [contact-info (find-contact-info)])
  (define response (port->string (aoc-submit* session year day part answer
                                              #:contact-info contact-info)))
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
