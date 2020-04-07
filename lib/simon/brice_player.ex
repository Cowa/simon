defmodule Simon.BricePlayer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    join_game(opts)

    {:ok,
     %{
       # Config state
       name: opts[:name],
       game_server: opts[:game_server],
       guess_delay: opts[:guess_delay],
       round_delay: opts[:round_delay],
       perk: opts[:perk],

       # AI state
       current_round: 0,
       current_sequence: [],
       current_player: nil,
       current_player_name: ""
     }}
  end

  def join_game(opts) do
    GenServer.cast(opts[:game_server], {:join, self(), opts[:name]})
  end

  ###
  ### GenServer Callbacks
  ###

  def handle_info({:sequence_color, round, color}, state) do
    new_state = %{
      state
      | current_round: round,
        current_sequence: state.current_sequence ++ [color]
    }

    {:noreply, new_state}
  end

  def handle_info({:current_player, {player_pid, player_name}}, state) do
    new_state = %{
      state
      | current_player: player_pid,
        current_player_name: player_name,
        current_round: 0,
        current_sequence: []
    }

    perk_current_player(new_state)

    {:noreply, new_state}
  end

  def handle_info({:your_round, round}, state) do
    # I have been chosen.

    # Try not to act like an AI.
    Process.sleep(state.round_delay)

    guess_sequence(state.game_server, state.guess_delay, state.current_sequence)

    {:noreply, state}
  end

  def handle_info({:guess, color, {player_pid, player_name}}, state) do
    {:noreply, state}
  end

  def handle_info(:win, state) do
    {:noreply, reset_state(state)}
  end

  def handle_info(:lose, state) do
    {:noreply, reset_state(state)}
  end

  def handle_info(trash, state) do
    IO.puts("Unknown: #{inspect(trash)}")
    {:noreply, state}
  end

  ###
  ###
  ###

  def reset_state(state) do
    %{state | current_round: 0, current_sequence: []}
  end

  def guess_sequence(_game_server, _guess_delay, []) do
    :ok
  end

  def guess_sequence(game_server, _guess_delay, [hd | nil]) do
    # Last color, no need to wait after
    send_guess(game_server, hd)
  end

  def guess_sequence(game_server, guess_delay, [hd | tl]) do
    case send_guess(game_server, hd) do
      :ok ->
        # Remaining colors in sequence, make some delay
        Process.sleep(guess_delay)

        # Recursive call
        guess_sequence(game_server, guess_delay, tl)

      :bad_guess ->
        :bad_guess
    end
  end

  def send_guess(game_server, color) do
    GenServer.call(game_server, {:color_guess, color}, :infinity)
  end

  ###
  ### Perks strategy
  ###

  def supported_perks() do
    [:asshole, :supportive]
  end

  def perk_current_player(state = %{perk: :supportive}) do
    if state.current_player != self() do
      send(state.current_player, "Good luck #{state.current_player_name}! -#{state.name}")
    end
  end

  def perk_current_player(state = %{perk: :asshole}) do
    if state.current_player != self() do
      # Send a random color to the current player
      send(
        state.current_player,
        {:sequence_color, Enum.random(1..10), Enum.random([:blue, :green, :yellow, :red])}
      )
    end
  end

  def perk_current_player(state) do
    nil
  end
end
