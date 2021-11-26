# advent-of-code

Racket package for fetching Advent of Code input.

# CLI Usage

After installing with `raco pkg install advent-of-code`:

---

```sh
raco aoc [-y year] [-d day]
```

Fetch the puzzle input for a given day.

---

```sh
raco aoc [-y year] [-d day] [-a answer]
```

Submit an answer for the given puzzle.

---

Notes:

- `year` defaults to the latest Advent of Code, if not specified.
- `day` defaults to the current day of the month, capped at 25.
- `session` is a valid `session` cookie. Defaults to the contents of
  `session.key` in this package's install directory. You will be
  prompted for this if it is not available.

For more details, run `raco help aoc` or `raco aoc --help`.
