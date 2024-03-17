import gleam/list
import gleam/string
import gleam/int
import gleam/result
import gleam/regex

fn check(c) {
  let assert Ok(re) = regex.from_string("[1-9]")
  regex.check(re, c)
}

fn parse_word(word) -> String {
  let chars = string.to_graphemes(word)
  {
    chars
    |> list.find(check)
    |> result.unwrap("")
  }
  <> {
    chars
    |> list.reverse
    |> list.find(check)
    |> result.unwrap("")
  }
}

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.fold(0, fn(total, word) {
    total
    + {
      parse_word(word)
      |> int.parse
      |> result.unwrap(0)
    }
  })
}

fn fix_word(word) -> String {
  string.replace(word, "one", "o1e")
  |> string.replace("two", "t2o")
  |> string.replace("three", "t3e")
  |> string.replace("four", "4")
  |> string.replace("five", "5e")
  |> string.replace("six", "6")
  |> string.replace("seven", "7n")
  |> string.replace("eight", "e8t")
  |> string.replace("nine", "n9e")
}

pub fn pt_2(input: String) {
  input
  |> string.split("\n")
  |> list.fold(0, fn(total, word) {
    total
    + {
      fix_word(word)
      |> parse_word
      |> int.parse
      |> result.unwrap(0)
    }
  })
}
