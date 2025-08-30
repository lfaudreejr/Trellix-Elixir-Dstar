defmodule TrellixWeb.AppComponents do
  use Phoenix.Component
  import TrellixWeb.CoreComponents

  def board_card(assigns) do
    ~H"""
    <a
      id={"board-#{@id}"}
      class="board w-60 h-40 p-4 block border-b-8 shadow rounded hover:shadow-lg bg-base-100 relative"
      style={"border-color:#{@color}"}
      href={"/board/#{@id}"}
    >
      <div class="font-bold text-base-content flex justify-between items-center">
        <span>{@name}</span>
        <button
          class="btn btn-circle hover:text-error"
          data-on-click={"@delete('/board/#{@id}', {headers: {'X-Csrf-Token': '#{@csrf_token}'}})"}
        >
          <.icon name="hero-trash" class="size-5 shrink-0" />
        </button>
      </div>
    </a>
    """
  end

  def board_name(assigns) do
    ~H"""
    <button
      class="text-2xl font-medium block rounded-lg text-left border border-transparent py-1 px-2"
      data-on-click={"@get('/board/#{@board.id}/name/edit')"}
    >
      {@board.name}
    </button>
    """
  end

  def board_name_edit(assigns) do
    ~H"""
    <div class="flex gap-2">
      <input type="text" value={@board.name} data-bind-board-name class="input" />
      <div class="flex gap-2">
        <button class="btn btn-ghost" data-on-click={"@get('/board/#{@board.id}/name/edit/cancel')"}>
          Cancel
        </button>
        <button
          class="btn btn-primary"
          data-on-click={"@put('/board/#{@board.id}/name/edit/submit', {headers: {'X-Csrf-Token': '#{@csrf_token}'}})"}
        >
          Save
        </button>
      </div>
    </div>
    """
  end

  def column_name(assigns) do
    ~H"""
    <button
      class="font-medium text-base-content border border-transparent"
      data-on-click={"@get('/column/#{@column.id}/name/edit')"}
    >
      {@column.name}
    </button>
    """
  end

  def column_name_edit(assigns) do
    ~H"""
    <div class="flex gap-2">
      <input type="text" value={@column.name} data-bind-column-name class="input" />
      <div class="flex gap-2">
        <button
          type="button"
          class="btn btn-ghost"
          data-on-click={"@get('/column/#{@column.id}/name/edit/cancel')"}
        >
          Cancel
        </button>
        <button
          type="button"
          class="btn btn-primary"
          data-on-click={"@put('/column/#{@column.id}/name/edit/submit', {headers: {'X-Csrf-Token': '#{@csrf_token}'}})"}
        >
          Save
        </button>
      </div>
    </div>
    """
  end

  def column(assigns) do
    ~H"""
    <div
      id={"column-#{@column.id}"}
      class="flex-shrink-0 flex flex-col overflow-hidden max-h-full w-80 border-slate-400 rounded-xl shadow-sm shadow-slate-400 bg-base-200"
    >
      <div id={"column-#{@column.id}-name"} class="p-2">
        <%!-- <span class="font-medium text-base-content">{@column.name}</span> --%>
        <.column_name column={@column} />
      </div>
      <div
        id={~c'column-#{@column.id}-cards'}
        class="px-2 space-y-4"
      >
        <.card :for={card <- @column.cards} card={card} csrf_token={@csrf_token} />
      </div>
      <div id={~c'column-#{@column.id}-actions'} class="p-2">
        <.add_card_button column_id={@column.id} />
      </div>
      <script>
        (() => {
        const Sortable = window.Sortable;
        let sortContainer = document.getElementById("<%= ~c'column-#{@column.id}-cards' %>");
        new Sortable(sortContainer, {
          animation: 150,
          ghostClass: 'opacity-25',
          group: 'cards',
          onEnd: (evt) => {
            console.log('sorted onEnd', evt);

            // Get card ID from the moved element
            const cardId = evt.item.id.replace('card-', '');
            const newColumnId = evt.to.id.replace('column-', '').replace('-cards', '');
            const newIndex = evt.newIndex;

            const params = new URLSearchParams();
            params.append('_method', 'PUT');
            params.append('columnId', newColumnId);
            params.append('newIndex', newIndex);

            fetch(`/card/${cardId}/reorder`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
              },
              body: params.toString()
            }).then(response => {
              if (!response.ok) {
                console.error('Failed to reorder card');
              }
            }).catch(error => {
              console.error('Error reordering card:', error);
            });
          }
        })
        })()
      </script>
    </div>
    """
  end

  def column_create_button(assigns) do
    ~H"""
    <button
      id="create-column"
      class="btn btn-ghost btn-large"
      data-on-click={"@get('/board/#{@board_id}/column/create', {headers: {'X-Csrf-Token': '#{@csrf_token}'}})"}
    >
      <.icon name="hero-plus" class="size-6 shrink-0" />
    </button>
    """
  end

  def column_create_form(assigns) do
    ~H"""
    <form
      id="create-column"
      class="p-2 flex-shrink-0 flex flex-col overflow-hidden max-h-full w-80 border-slate-400 rounded-xl shadow-sm shadow-slate-400 bg-base-100"
      data-on-submit={"@post('/board/#{@board_id}/column/create', {headers: {'X-Csrf-Token': '#{@csrf_token}'}}); $columnName = ''"}
    >
      <div class="space-y-4">
        <input autofocus type="text" class="input" data-bind-column-name />
        <div class="flex justify-between">
          <button
            class="btn btn-ghost"
            type="button"
            data-on-click={"@get('/board/#{@board_id}/column/create/cancel')"}
          >
            Cancel
          </button>
          <button class="btn btn-primary">Save</button>
        </div>
      </div>
    </form>
    """
  end

  def add_card_button(assigns) do
    ~H"""
    <button
      type="button"
      class="btn btn-ghost rounded-lg text-base-content w-full"
      data-on-click={"@get('/column/#{@column_id}/card/create')"}
    >
      + Add a Card
    </button>
    """
  end

  def add_card_form(assigns) do
    ~H"""
    <form
      id="add-card-form"
      class="p-2 border-slate-400 rounded-xl shadow-sm shadow-slate-400 bg-base-100"
      data-on-submit={"@post('/column/#{@column_id}/card/create', {headers: {'X-Csrf-Token': '#{@csrf_token}'}}); $cardTitle = '';"}
    >
      <div class="space-y-4">
        <input
          autofocus
          type="text"
          class="input"
          placeholder="Enter title for this card"
          data-bind-card-title
        />
        <div class="flex justify-between">
          <button
            class="btn btn-ghost"
            type="button"
            data-on-click={"@get('/column/#{@column_id}/card/create/cancel')"}
          >
            Cancel
          </button>
          <button class="btn btn-primary">Save</button>
        </div>
      </div>
    </form>
    """
  end

  def card(assigns) do
    ~H"""
    <div
      id={"card-#{@card.id}"}
      class="p-2 border-slate-400 rounded-xl shadow-sm shadow-slate-400 bg-base-100"
    >
      <div class="space-y-4">
        <h3>{@card.title}</h3>
        <button
          class="btn btn-circle hover:text-error"
          data-on-click={"@delete('/card/#{@card.id}', {headers: {'X-Csrf-Token': '#{@csrf_token}'}})"}
        >
          <.icon name="hero-trash" class="size-6 shrink-0" />
        </button>
      </div>
    </div>
    """
  end
end
