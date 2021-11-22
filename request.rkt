#lang racket/base

(require racket/contract/base
         racket/format
         racket/string
         racket/port
         racket/runtime-path
         racket/file
         net/url
         file/sha1)

(provide (contract-out
          [aoc-url url?]
          [aoc-request (->* (aoc-session?)
                            (#:cache (or/c boolean? path-string?))
                            #:rest (listof any/c)
                            input-port?)]
          [aoc-session? predicate/c])
         (struct-out exn:fail:aoc))

(define (aoc-session? s)
  (string? s))

(define aoc-url (string->url "https://adventofcode.com"))

(struct exn:fail:aoc exn:fail (status))

(define (hash-session session)
  (define sha-bytes (sha256-bytes (string->bytes/utf-8 session)))
  (define sha-string (bytes->hex-string sha-bytes))
  (substring sha-string 0 8))

(define (get-cache-dir root session)
  (define dir-name (hash-session session))
  (build-path root dir-name))

(define (aoc-request session #:cache [cache #f] . path)
  (define str-path (map ~a path))
  (define cache-file
    (cond
      [cache
       (define cache-root
         (cond
           [(eq? #t cache) (build-path (find-system-path 'cache-dir) "adventofcoderkt")]
           [(path-string? cache) cache]
           [else (raise-argument-error "(or/c boolean? path-string?)")]))
       (define cache-dir (get-cache-dir cache-root session))
       (define cache-file (apply build-path cache-dir str-path))
       cache-file]
      [else #f]))
  (cond
    [(and cache-file (file-exists? cache-file))
     (open-input-file cache-file)]
    [else
     (define-values (pp headers)
       (get-pure-port/headers
        (combine-url/relative
         aoc-url
         (string-join str-path "/"))
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
     (cond
       [cache-file
        (make-parent-directory* cache-file)
        (define input-bytes (port->bytes pp))
        (call-with-output-file cache-file
          (lambda (file-out)
            (write-bytes input-bytes file-out)))
        (open-input-bytes input-bytes)]
       [else pp])]))
