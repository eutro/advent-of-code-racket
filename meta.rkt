#lang racket/base

(require racket/contract/base
         racket/runtime-path
         racket/system
         racket/port
         racket/file
         racket/string
         net/sendurl
         net/url
         (for-syntax racket/base
                     racket/path
                     setup/getinfo))

(provide (contract-out
          [aoc-url url?]
          [aoc-session? predicate/c]
          [current-aoc-time (-> date?)]
          [session-file path-string?]
          [contact-info-file path-string?]
          [find-session (-> aoc-session?)]
          [find-contact-info (-> string?)]
          [contact-info->user-agent (-> string? bytes?)]))

(define (aoc-session? s) (string? s))
(define aoc-url (string->url "https://adventofcode.com"))

(define (current-aoc-time)
  (define aoc-offset (- (* 5 60 60)))
  (seconds->date
   (+ (current-seconds) aoc-offset)
   #f))

(define-runtime-path session-file "session.key")
(define-runtime-path contact-info-file "contact.txt")

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
    (unless (eq? 'y (y-or-n "Set interactively now?" 'y))
      (raise-user-error "Session key unset or expired"))
    (when (eq? 'y (y-or-n "Open Advent of Code in browser?" 'y))
      (send-url (url->string aoc-url)))
    (displayln "Hint: Your cookies can typically be found in the developer console.")
    (displayln "- Firefox: \"Storage\" tab (Shift + F9)")
    (displayln "- Chrome: \"Application\" tab")
    (displayln "Enter the contents of your session cookie below:")
    (define session (read-line (current-input-port) 'any))
    (when (or (eof-object? session) (string=? "" session))
      (raise-user-error "No input provided"))
    (display-to-file session session-file #:exists 'replace)
    (displayln "Session set successfully!")))

(define month-seconds (* 31 24 60 60))
(define (older-than-seconds? path seconds)
  (let/ec return
    (define csec (current-seconds))
    (define file-seconds
      (file-or-directory-modify-seconds
       path #f (lambda () (return #t))))
    (<= seconds (- csec file-seconds))))

(define (find-session)
  (when (older-than-seconds? session-file month-seconds)
    (refresh-session!))
  (string-trim (file->string session-file)))

(define (raw-find-contact-info)
  (and (file-exists? contact-info-file)
       (string-trim (file->string contact-info-file))))

(define (refresh-contact-info!)
  (let/ec return
    (parameterize ([current-output-port (current-error-port)])
      (displayln "Contact information unset or possibly outdated.")
      (displayln "Eric Wastl asks that you include a way to be contacted in automated requests.")
      (cond
        [(raw-find-contact-info)
         =>
         (lambda (contact-info)
           (printf "Your current contact information at ~a is:~n" contact-info-file)
           (printf "  ~a~n" contact-info))]
        [else
         (printf "Please set ~a to a suitable email address or URL.~n" contact-info-file)])
      (unless (eq? 'y (y-or-n "Set interactively now?" 'y))
        (cond
          [(raw-find-contact-info)
           (file-or-directory-modify-seconds contact-info-file (current-seconds)
                                             #;fail void)
           (return (void))]
          [else
           (raise-user-error "Could not find contact information")]))
      (define contact-info
        (cond
          [(and (find-executable-path "git")
                (eq? 'y (y-or-n "Use contact information from git?" 'y))
                (or (contact-info-from-git)
                    (begin
                      (displayln "Error calling git")
                      #f)))
           => values]
          [else
           (displayln "Enter your contact information below:")
           (read-line (current-input-port) 'any)]))
      (when (or (eof-object? contact-info) (string=? "" contact-info))
        (raise-user-error "No input provided"))
      (displayln "This library will send the following User-Agent to Advent of Code:")
      (printf "  ~s~n" (contact-info->user-agent contact-info))
      (unless (eq? 'y (y-or-n "Is that okay?" 'y))
        (raise-user-error "Not accepted"))
      (display-to-file contact-info contact-info-file #:exists 'replace)
      (displayln "Contact information set successfully!"))))

(define (guess-interactive?)
  (terminal-port? (current-input-port)))

(define (find-contact-info)
  (when (and (guess-interactive?)
             (older-than-seconds? contact-info-file month-seconds))
    (refresh-contact-info!))
  (cond
    [(raw-find-contact-info) => values]
    [else
     (define-logger advent-of-code-racket)
     (log-advent-of-code-racket-error
      "No contact information set. Please set ~a to an email address or URL."
      contact-info-file)
     "unknownlibraryuser@example.com"]))

(define (contact-info-from-git)
  (define git (find-executable-path "git"))
  (define (git-config key)
    (let/ec return
      (parameterize ([current-error-port (open-output-nowhere)])
        (string-trim
         (with-output-to-string
           (lambda ()
             (unless (zero? (system*/exit-code git "config" key))
               (return #f))))))))
  (git-config "user.email"))

;; Taken from http-easy
(begin-for-syntax
  (define this-path (path-only (syntax-source #'here)))
  (define info-ref (get-info/full this-path)))
(define-syntax (get-lib-version stx)
  (datum->syntax stx (info-ref 'version) stx))
(define lib-version (get-lib-version))

(define (contact-info->user-agent contact-info)
  (call-with-output-bytes
   (lambda (out)
     (fprintf out
              "advent-of-code-racket/~a (~a; racket[~a] ~a; +~a)"
              lib-version
              (system-type 'os)
              (case (system-type 'vm)
                [(chez-scheme) 'CS]
                [else 'BC])
              (version)
              contact-info))))
