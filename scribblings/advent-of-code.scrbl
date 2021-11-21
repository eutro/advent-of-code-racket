#lang scribble/manual

@(require (for-label advent-of-code
                     racket/base
                     racket/contract
                     net/url))

@title{Advent of Code}
@author{eutro}

@defmodule[advent-of-code]

A package for fetching Advent of Code input.

@defmodule[advent-of-code/input #:no-declare]

@defproc[(open-aoc-input [session aoc-session?]
                         [year advent-year?]
                         [day advent-day?])
         input-port?]

Fetch the puzzle input as an input port.

Using this in your solution is not recommended, you should
download the data and store it locally.

See @racket[aoc-request] for session and error handling.

@defproc[(fetch-aoc-input [session aoc-session?]
                          [year advent-year?]
                          [day advent-day?])
         string?]

Fetch the input data as a string, using @racket[open-aoc-input].

See @racket[open-aoc-input].

@defthing[advent-day? flat-contract?]

A day of the month between 1 and 25.

Equivalent to @racket[(integer-in 1 25)].

@defthing[advent-year? flat-contract]

A year since 2015.

Equivalent to @racket[(and/c exact-integer? (>=/c 2015))].

@defmodule[advent-of-code/request #:no-declare]

Procedures for making API requests. Reprovided by @racket[advent-of-code].

@defproc[(aoc-session? [x any/c]) boolean?]

Predicate for an Advent of Code session cookie.

Equivalent to @racket[string?].

@defthing[aoc-url url?]

The URL to @url{https://adventofcode.com}.

@defstruct[(exn:fail:aoc exn:fail) ([status string?])]

Raised by @racket[aoc-request] if a request fails.

@defproc[(aoc-request [session aoc-session?]
                      [path any/c]
                      ...)
         input-port?]

Makes a request to the Advent of Code website, using the session cookie.

Raises @racket[exn:fail:aoc] if the request fails.

@defmodule[advent-of-code/meta #:no-declare]

Meta and environment functions. Reprovided by @racket[advent-of-code].

@defproc[(current-aoc-time) date?]

The current EST (UTC-5) time, on which the Advent of Code calendar is based.

@defthing[session-file path-string?]

The path of the file used to fetch the current session by @racket[find-session].

@defproc[(find-session) aoc-session?]

Attempt to find a valid @racket[aoc-session?] for the user.

Tries to read @racket[session-file], if it is less than one month old,
otherwise interactively prompts the user to enter the session cookie themselves,
and saves it in @racket[session-file] for later.

This is meant to be used by interactive programs, since it reads from
@racket[current-input-port] and writes to @racket[current-output-port].
