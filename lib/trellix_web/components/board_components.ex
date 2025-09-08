defmodule TrellixWeb.BoardComponents do
  use Phoenix.Component
  import TrellixWeb.CoreComponents
  import TrellixWeb.ColumnComponents

  def board_content(assigns) do
    ~H"""
    <div
      id={"board-#{@board.id}"}
      class="h-full space-y-6 p-4 sm:p-6 lg:p-8"
      style={"background-color: #{@board.color}"}
      data-signals-board.id={@board.id}
    >
      <div id="board-name" class="mx-6">
        <.board_name_input board={@board} csrf_token={@csrf_token} />
      </div>
      <div class="h-full flex flex-grow min-h-0 items-start gap-4 px-8 pb-4 overflow-auto">
        <.column :for={col <- @board.columns} column={col} csrf_token={@csrf_token} />
        <.create_column_form
          board_id={@board.id}
          csrf_token={@csrf_token}
          show_form={Enum.count(@board.columns) == 0}
        />
      </div>
    </div>
    """
  end

  def board_card(assigns) do
    ~H"""
    <a
      id={"board-#{@board.id}"}
      href={"/board/#{@board.id}"}
      class="relative w-60 h-40 p-4 bg-base-200 border border-base-300 block border-b-8 transition cursor-pointer rounded hover:scale-101 hover:shadow-lg"
      style={"border-bottom-color:#{@board.color}"}
    >
      <div class="font-bold text-base-content flex justify-between items-center">
        <span>{@board.name}</span>
        <button
          type="button"
          class="btn btn-circle cursor-default hover:text-error-content"
          data-on-click={"@delete('/board/#{@board.id}', {headers: {'X-Csrf-Token': '#{@csrf_token}'}})"}
        >
          <.icon name="hero-trash" class="size-5 shrink-0" />
        </button>
      </div>
    </a>
    """
  end

  def board_name_input(assigns) do
    ~H"""
    <form
      id={"board-#{@board.id}-name"}
      data-on-submit={"@put('/board/#{@board.id}/name', {
        headers: {'X-Csrf-Token': '#{@csrf_token}'},
        contentType: 'form'
      })"}
    >
      <input
        type="text"
        id={"board-#{@board.id}-name-input"}
        name="board_name"
        value={@board.name}
        class="input input-sm text-lg input-ghost rounded-md"
      />
    </form>
    """
  end
end
