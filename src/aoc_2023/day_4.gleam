import gleam/string
import gleam/list
import gleam/int
import gleam/float
import gleam/set
import gleam/result
import gleam/queue

fn parse(input: String) -> List(List(List(String))) {
  use line <- list.map(string.split(input, "\n"))
  use part <- list.map(string.split(line, " | "))
  use token <- list.filter(string.split(part, " "))
  !string.contains(token, "Card")
  && !string.contains(token, ":")
  && !string.is_empty(token)
}

pub fn pt_1(input: String) {
  use total, line <- list.fold(parse(input), 0)
  let assert [first, second] = line
  set.intersection(set.from_list(first), set.from_list(second))
  |> set.size
  |> int.add(-1)
  |> int.to_float
  |> int.power(2, _)
  |> result.unwrap(0.0)
  |> float.truncate
  |> int.add(total)
}

pub fn pt_2(input: String) {
  let matches = {
    use q, line <- list.fold(parse(input), queue.new())
    let assert [first, second] = line
    set.intersection(set.from_list(first), set.from_list(second))
    |> set.size
    |> queue.push_back(q, _)
  }

  count_cards(queue.to_list(matches))
}

fn count_cards(cards: List(Int)) -> Int {
  inner_count_cards(cards, 1, [])
}

fn inner_count_cards(cards: List(Int), index: Int, copies: List(Int)) -> Int {
  case cards {
    [num_matches, ..rest] ->
      case num_matches > 0 {
        False ->
          inner_count_cards(rest, index + 1, list.append(copies, [index]))
        True -> {
          let wins = list.range(index + 1, index + num_matches)
          let wins_and_card = list.append(wins, [index])
          let num_copies = list_count(copies, index)
          case num_copies > 0 {
            True -> {
              let new_copies =
                list.repeat(wins, num_copies)
                |> list.flatten
                |> list.append(wins)
                |> list.append(copies)
                |> list.append([index])

              inner_count_cards(rest, index + 1, new_copies)
            }
            False ->
              inner_count_cards(
                rest,
                index + 1,
                list.append(copies, wins_and_card),
              )
          }
        }
      }
    _ -> list.length(copies)
  }
}

pub fn list_count(l: List(var), match: var) -> Int {
  inner_list_count(l, match, 0)
}

fn inner_list_count(l: List(var), match: var, acc: Int) -> Int {
  case l {
    [first, ..rest] if first == match -> inner_list_count(rest, match, acc + 1)
    [first] if first == match -> {
      acc + 1
    }
    [_, ..rest] -> inner_list_count(rest, match, acc)
    _ -> acc
  }
}
