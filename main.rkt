#lang racket/base

(require advent-of-code/request
         advent-of-code/input
         advent-of-code/answer
         advent-of-code/meta)

(provide (all-from-out
          advent-of-code/request
          advent-of-code/input
          advent-of-code/answer
          advent-of-code/meta))

(module+ main
  (require racket/cmdline
           raco/command-name
           racket/port)

  (define sessionb (box #f))
  (define yearb (box #f))
  (define dayb (box #f))
  (define cacheb (box #t))
  (define answerb (box #f))

  (command-line
   #:program (short-program+command-name)
   #:once-each
   [("-s" "--session") session "The session cookie" (set-box! sessionb session)]
   [("-y" "--year") year "The year to query for" (set-box! yearb (string->number year))]
   [("-d" "--day") day "The day to fetch the input for" (set-box! dayb (string->number day))]
   #:once-any
   [("-c" "--cache") cache-dir "Override the cache directory" (set-box! cacheb cache-dir)]
   [("--no-cache") "Disable caching" (set-box! cacheb #f)]
   [("-a" "--answer") part answer
                      "An answer to submit instead of fetching input"
                      (set-box! answerb (cons (string->number part) answer))]
   #:args ()
   (void))

  (with-handlers ([exn:fail:aoc?
                   (lambda (e)
                     (define status (exn:fail:aoc-status e))
                     (parameterize ([current-output-port (current-error-port)])
                       (case status
                         [("404")
                          (displayln "Not available yet!")]
                         [("500")
                          (displayln "Internal server error, maybe your session is invalid?")
                          (printf "Try deleting and re-entering ~a~n" session-file)]))
                     (raise e))])
    (define now (current-aoc-time))
    (define session (or (unbox sessionb) (find-session)))
    (define year
      (or (unbox yearb)
          ((if (= (date-month now) 12) values sub1)
           (date-year now))))
    (define day
      (or (unbox dayb)
          (max 1 (min 25 (date-day now)))))
    (define ans (unbox answerb))
    (if ans
        (displayln (aoc-submit session year day (car ans) (cdr ans)))
        (copy-port (open-aoc-input session year day #:cache (unbox cacheb))
                   (current-output-port)))))
