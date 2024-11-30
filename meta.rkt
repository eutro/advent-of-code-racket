#lang racket/base

(require racket/contract/base
         racket/runtime-path
         racket/file
         racket/string
         advent-of-code/request
         net/sendurl
         net/url)

(provide (contract-out
          [current-aoc-time (-> date?)]
          [session-file path-string?]
          [find-session (-> aoc-session?)]))

(define (current-aoc-time)
  (define aoc-offset (- (* 5 60 60)))
  (seconds->date
   (+ (current-seconds) aoc-offset)
   #f))

(define-runtime-path session-file "session.key")

(define (y-or-n prompt [default #f])
  (printf "~a [~a/~a] "
          prompt
          (if (eq? default 'y) "Y" "y")
          (if (eq? default 'n) "N" "n"))
  (flush-output)
  (define line (read-line (current-input-port) 'any))
  (if (eof-object? line)
      #f
      (case (string-downcase line)
        [("yes" "y") 'y]
        [("no" "n") 'n]
        [("") default]
        [else
         (displayln "Please enter yes/y or no/n.")
         (y-or-n prompt default)])))

(define (refresh-session!)
  (parameterize ([current-output-port (current-error-port)])
    (displayln "Session key unset or expired.")
    (printf "Please set ~a~n" session-file)
    (when (not (eq? 'y (y-or-n "Set interactively now?" 'y)))
      (exit 1))
    (when (eq? 'y (y-or-n "Open Advent of Code in browser?" 'y))
      (send-url (url->string aoc-url)))
    (displayln "Hint: Your cookies can typically be found in the developer console.")
    (displayln "- Firefox: \"Storage\" tab (Shift + F9)")
    (displayln "- Chrome: \"Application\" tab")
    (displayln "Enter the contents of your session cookie below:")
    (define session (read-line (current-input-port) 'any))
    (when (eof-object? session)
      (exit 1))
    (with-output-to-file session-file
      #:exists 'replace
      (lambda ()
        (display session)
        (flush-output)))
    (displayln "Session set successfully!")))

(define (find-session)
  (define csec (current-seconds))
  (define month-seconds (* 31 24 60 60))
  (when (<=
         month-seconds
         (-
          csec
          (file-or-directory-modify-seconds
           session-file
           #f
           (lambda () (- csec month-seconds)))))
    (refresh-session!))
  (string-trim (file->string session-file)))
