// import gleam/io
import gleam/int
import gleam/string
import gleam/list

type Position {
  Position(row: Int, col: Int)
}

type Word {
  IsWord(pos: Position, length: Int, value: String)
  NoWord
}

type Token {
  Token(pos: Position, value: String)
}

const numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

const numbers_dot = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]

fn parse_tokens(input: String) -> List(List(Token)) {
  use line, row <- list.index_map(string.split(input, "\n"))
  use char, col <- list.index_map(string.to_graphemes(line))
  Token(Position(row, col), char)
}

fn parse_words(tokens: List(Token)) -> List(Word) {
  inner_parse_words(tokens, NoWord, [])
}

fn inner_parse_words(tokens: List(Token), word: Word, words: List(Word)) {
  case tokens, word {
    [], NoWord -> words
    [], IsWord(_, _, _) -> [word, ..words]
    [token, ..rest], word ->
      case list.contains(numbers, token.value), word {
        True, NoWord ->
          inner_parse_words(rest, IsWord(token.pos, 1, token.value), words)
        True, IsWord(pos, len, val) -> {
          // check if token is the first token of line
          case int.remainder(token.pos.col, 140) {
            Ok(0) ->
              inner_parse_words(rest, IsWord(token.pos, 1, token.value), [
                word,
                ..words
              ])
            _ ->
              inner_parse_words(
                rest,
                IsWord(pos, len + 1, val <> token.value),
                words,
              )
          }
        }
        False, NoWord -> inner_parse_words(rest, NoWord, words)
        False, IsWord(_, _, _) ->
          inner_parse_words(rest, NoWord, [word, ..words])
      }
  }
}

fn position_neighboors(position: Position) -> List(Position) {
  let assert Position(row, col) = position
  [
    Position(row - 1, col),
    Position(row - 1, col + 1),
    Position(row - 1, col - 1),
    Position(row, col + 1),
    Position(row, col - 1),
    Position(row + 1, col),
    Position(row + 1, col + 1),
    Position(row + 1, col - 1),
  ]
}

fn word_neighboors(word: Word) -> List(Position) {
  let assert IsWord(Position(x, y), len, _) = word
  list.range(y, y + len - 1)
  |> list.map(Position(x, _))
  |> list.map(position_neighboors)
  |> list.flatten
}

fn parse_gears(tokens: List(Token)) -> List(Position) {
  list.filter(tokens, fn(token) { !list.contains(numbers_dot, token.value) })
  |> list.map(fn(t) { t.pos })
}

pub fn pt_1(input: String) {
  let tokens =
    parse_tokens(input)
    |> list.flatten
  let words = parse_words(tokens)
  let gear_positions = parse_gears(tokens)
  let parts =
    list.filter(words, fn(w) {
      list.any(word_neighboors(w), fn(x) { list.contains(gear_positions, x) })
    })

  use total, part <- list.fold(parts, 0)
  let assert IsWord(_, _, val) = part
  let assert Ok(num) = int.parse(val)
  total + num
}

pub fn pt_2(input: String) {
  let tokens =
    parse_tokens(input)
    |> list.flatten
  let words = parse_words(tokens)
  let gear_positions =
    tokens
    |> list.filter_map(fn(t) {
      case t.value {
        "*" -> Ok(t.pos)
        _ -> Error(t)
      }
    })

  let parts = {
    use word <- list.filter(words)
    use word_neighboor <- list.any(word_neighboors(word))
    list.contains(gear_positions, word_neighboor)
  }

  list.map(gear_positions, fn(gear_pos) {
    list.fold(parts, [], fn(acc, part) {
      let assert IsWord(_, _, val) = part
      let assert Ok(num) = int.parse(val)
      case list.contains(word_neighboors(part), gear_pos) {
        True -> [num, ..acc]
        False -> acc
      }
    })
  })
  |> list.filter_map(fn(x) {
    case list.length(x) {
      2 -> Ok(list.reduce(x, int.multiply))
      _ -> Error(0)
    }
  })
  |> list.fold(0, fn(sum, l) {
    let assert Ok(s) = l
    sum + s
  })
  // let a = {
  //   use gear_pos <- list.map(gear_positions)
  //   use acc, part <- list.fold(parts, [])
  //   let assert IsWord(_, _, val) = part
  //   let assert Ok(num) = int.parse(val)
  //   case list.contains(word_neighboors(part), gear_pos) {
  //     True -> [num, ..acc]
  //     False -> acc
  //   }
  // }
}
