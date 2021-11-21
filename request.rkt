#lang racket/base

(require racket/contract/base
         racket/format
         racket/string
         racket/port
         net/url)

(provide (contract-out
          [aoc-url url?]
          [aoc-request (->* (aoc-session?) #:rest (listof any/c)
                            input-port?)]
          [aoc-session? predicate/c])
         (struct-out exn:fail:aoc))

(define (aoc-session? s)
  (string? s))

(define aoc-url (string->url "https://adventofcode.com"))

(struct exn:fail:aoc exn:fail (status))

(define (aoc-request session . path)
  (define-values (pp headers)
    (get-pure-port/headers
     (combine-url/relative
      aoc-url
      (string-join (map ~a path) "/"))
     (list (format "cookie: session=~a" session))
     #:status? #t))
  (define status-line (car (string-split headers "\r\n")))
  (define status-code (cadr (string-split status-line)))
  (unless (string=? status-code "200")
    (raise (exn:fail:aoc
            (format "couldn't fetch puzzle input~n  status: ~a~n  response: ~s"
                    status-line
                    (port->string pp))
            (current-continuation-marks)
            status-code)))
  pp)
