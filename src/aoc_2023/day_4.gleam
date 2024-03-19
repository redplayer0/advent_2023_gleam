import gleam/string
import gleam/list
import gleam/int
import gleam/float
import gleam/set
import gleam/result
import gleam/queue
import gleam/io

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
  io.debug(matches)

  count_cards(queue.to_list(matches))
  // use total, card, index <- list.index_fold(queue.to_list(matches), 0)
  // index
  // |> list.range(index + 1, _)
  // |> int.sum
  // |> int.multiply(card)
  // |> int.add(total)
}

fn count_cards(cards: List(Int)) -> Int {
  inner_count_cards(cards, 0, [])
}

// somehow stop at max index and dont add cards
fn inner_count_cards(cards: List(Int), index: Int, copies: List(Int)) -> Int {
  case cards, copies {
    [num_matches, ..rest_cards], [] if num_matches == 0 -> {
      inner_count_cards(rest_cards, index + 1, [])
    }
    [num_matches, ..rest_cards], [] -> {
      inner_count_cards(
        rest_cards,
        index + 1,
        list.append(
          list.range(int.min(140, index + 1), int.min(140, index + num_matches)),
          copies,
        ),
      )
    }
    // [_], [] -> {
    //   inner_count_cards(
    //     rest_cards,
    //     index + 1,
    //     list.append(list.range(int.min(140, index + 1), int.min(140, index + num_matches)), copies),
    //   )
    // }
    _, _ -> 0
  }
}
