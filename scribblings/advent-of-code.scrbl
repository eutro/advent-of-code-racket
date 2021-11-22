#lang scribble/manual

@(require (for-label advent-of-code
                     racket/base
                     racket/contract
                     net/url))

@title{Advent of Code}
@author{eutro}

@defmodule[advent-of-code]

A package for fetching Advent of Code input.

@section{Input Fetching}

@defmodule[advent-of-code/input #:no-declare]

@defproc[(open-aoc-input [session aoc-session?]
                         [year advent-year?]
                         [day advent-day?]
                         [#:cache cache (or/c boolean? path-string?) #f])
         input-port?]{

Fetch the puzzle input for @racket[day] of @racket[year] as an input port.

If you are using this in your puzzle solution, use of the @racket[cache]
argument is highly recommended.

See @racket[aoc-request] for information on session, caching and error handling.

}

@defproc[(fetch-aoc-input [session aoc-session?]
                          [year advent-year?]
                          [day advent-day?]
                          [#:cache cache (or/c boolean? path-string?) #f])
         string?]{

Fetch the input data as a string, using @racket[open-aoc-input].

See @racket[open-aoc-input].

}

@defthing[advent-day? flat-contract?]{

A day of the month between 1 and 25.

Equivalent to @racket[(integer-in 1 25)].

}

@defthing[advent-year? flat-contract]{

A year since 2015.

Equivalent to @racket[(and/c exact-integer? (>=/c 2015))].

}

@section{Requests}

@defmodule[advent-of-code/request #:no-declare]

Procedures for making API requests. Reprovided by @racket[advent-of-code].

@defproc[(aoc-session? [x any/c]) boolean?]{

Predicate for an Advent of Code session cookie.

Equivalent to @racket[string?].

}

@defthing[aoc-url url?]{

The URL to @url{https://adventofcode.com}.

}

@defstruct[(exn:fail:aoc exn:fail) ([status string?])]{

Raised by @racket[aoc-request] if a request fails.

}

@defproc[(aoc-request [session aoc-session?]
                      [path any/c]
                      ...
                      [#:cache cache (or/c boolean? path-string?) #f])
         input-port?]{

Makes an HTTP GET request to the Advent of Code website,
using the given @racket[session] cookie.

The @racket[cache] argument specifies how the data should be cached.

@itemize[

  @item{
    If @racket[cache] is @racket[#f], then no caching is performed, meaning
    the HTTP request will be made to the website every time. This is the default.
  }

  @item{
    If @racket[cache] is a @racket[path-string?], then the provided path is used as
    the directory to cache requests in.
  }

  @item{
    If @racket[cache] is a @racket[#t], then @racket[(find-system-path 'cache-dir)]
    is used as the directory to cache requests in.
  }

]

Raises @racket[exn:fail:aoc] if the request fails.

}

@section{Meta and Environment Utilities}

@defmodule[advent-of-code/meta #:no-declare]

Meta and environment functions. Reprovided by @racket[advent-of-code].

@defproc[(current-aoc-time) date?]{

The current EST (UTC-5) time, on which the Advent of Code calendar is based.

}

@defthing[session-file path-string?]{

The path of the file used to fetch the current session by @racket[find-session].

}

@defproc[(find-session) aoc-session?]{

Attempt to find a valid @racket[aoc-session?] for the user.

Tries to read @racket[session-file], if it is less than one month old,
otherwise interactively prompts the user to enter the session cookie themselves,
and saves it in @racket[session-file] for later.

This is meant to be used by interactive programs, since it reads from
@racket[current-input-port] and writes to @racket[current-output-port].

}
