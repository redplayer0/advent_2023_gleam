import gleam/int
import gleam/string
import gleam/list

type Game {
  Game(id: Int, rounds: List(Round))
}

type Round {
  Round(red: Int, green: Int, blue: Int)
}

fn parse(input: String) -> List(Game) {
  string.split(input, on: "\n")
  |> list.map(parse_game)
}

fn parse_game(raw_game: String) -> Game {
  let assert "Game " <> raw_game = raw_game
  let assert [raw_id, raw_rounds] = string.split(raw_game, on: ": ")
  let assert Ok(id) = int.parse(raw_id)
  Game(id, parse_rounds(raw_rounds))
}

fn parse_rounds(raw_rounds: String) -> List(Round) {
  string.split(raw_rounds, on: "; ")
  |> list.map(parse_round)
}

fn parse_round(raw_round: String) -> Round {
  let raw_pulls =
    string.split(raw_round, on: ", ")
    |> list.map(string.split(_, on: " "))

  use round, raw_pull <- list.fold(raw_pulls, Round(0, 0, 0))
  let assert [raw_number, raw_color] = raw_pull
  let assert Ok(number) = int.parse(raw_number)
  case raw_color {
    "red" -> Round(..round, red: number)
    "green" -> Round(..round, green: number)
    "blue" -> Round(..round, blue: number)
    _ -> panic as "wrong input data"
  }
}

pub fn pt_1(input: String) {
  let max_round = Round(12, 13, 14)
  let games = parse(input)

  use sum, game <- list.fold(games, 0)
  case is_valid_game(game, max_round) {
    True -> sum + game.id
    False -> sum
  }
}

fn is_valid_game(game: Game, max: Round) -> Bool {
  use Round(red, green, blue) <- list.all(game.rounds)
  red <= max.red && green <= max.green && blue <= max.blue
}

pub fn pt_2(input: String) {
  use power_sum, game <- list.fold(parse(input), 0)
  power_sum + power(min_required_cubes(game))
}

fn power(round: Round) -> Int {
  round.red * round.green * round.blue
}

fn min_required_cubes(game: Game) -> Round {
  use max_round, round <- list.fold(game.rounds, Round(0, 0, 0))
  Round(
    int.max(max_round.red, round.red),
    int.max(max_round.green, round.green),
    int.max(max_round.blue, round.blue),
  )
}
