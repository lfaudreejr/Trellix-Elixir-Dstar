defmodule TrellixWeb.BoardHTML do
  @moduledoc """
  This module contains pages rendered by BoardController.

  See the `board_html` directory for all templates available.
  """
  use TrellixWeb, :html

  embed_templates "board_html/*"
end
