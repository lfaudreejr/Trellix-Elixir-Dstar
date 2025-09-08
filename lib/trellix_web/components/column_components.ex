defmodule TrellixWeb.ColumnComponents do
  use Phoenix.Component
  import TrellixWeb.CoreComponents

  def column(assigns) do
    ~H"""
    <div
      id={"column-#{@column.id}"}
      class="flex-shrink-0 flex flex-col overflow-hidden max-h-full w-80 border-slate-400 rounded-xl shadow-sm shadow-slate-400 bg-base-200 gap-4"
    >
      <div>
        <.column_name_input column={@column} csrf_token={@csrf_token} />
      </div>
      <div id={"column-#{@column.id}-cards"} class="px-2 space-y-4">
        <.column_card
          :for={card <- @column.cards}
          column={@column}
          card={card}
          csrf_token={@csrf_token}
        />
      </div>
      <div id={"column-#{@column.id}-actions"} class="p-2">
        <.add_card_button column_id={@column.id} />
      </div>
      <script type="module">
        let sortContainer = document.getElementById("<%= ~c'column-#{@column.id}-cards' %>");
        new window.Sortable(sortContainer, {
          animation: 150,
          ghostClass: 'opacity-50',
          group: 'cards',
          onEnd(evt) {
            console.log('event onEnd', evt)
            const cardId = evt.item.id.replace('card-', '');
            const newColumnId = evt.to.id.replace('column-', '').replace('-cards', '');
            const newIndex = evt.newIndex;

            const params = new URLSearchParams();
            params.append('_method', 'PUT');
            params.append('column_id', newColumnId);
            params.append('new_index', newIndex);

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
      </script>
    </div>
    """
  end

  def column_name_input(assigns) do
    ~H"""
    <form
      id={"column-#{@column.id}-name"}
      class="p-2"
      data-on-submit={"@put('/column/#{@column.id}/name', {
        headers: {'X-Csrf-Token': '#{@csrf_token}'},
        contentType: 'form'
      })"}
    >
      <input
        type="text"
        id={"column-#{@column.id}-name-input"}
        name="column_name"
        value={@column.name}
        class="input input-sm text-sm input-ghost"
      />
    </form>
    """
  end

  def create_column_form(assigns) do
    ~H"""
    <div data-signals-show_create_column_form.pascal={@show_form}>
      <div data-show="!$show_create_column_form" style="display: none">
        <button
          type="button"
          class="btn btn-square rounded-xl"
          data-on-click="$show_create_column_form = true"
        >
          <.icon name="hero-plus" class="size-6 shrink-0" />
        </button>
      </div>

      <form
        data-show="$show_create_column_form"
        class="flex-shrink-0 flex flex-col overflow-hidden max-h-full w-80 border-slate-400 rounded-xl shadow-sm shadow-slate-400 bg-base-200 gap-4"
        style="display: none"
        data-on-submit={"@post('/board/#{@board_id}/column', {headers: {'X-Csrf-Token': '#{@csrf_token}'}, contentType: 'form'})"}
      >
        <div class="p-2">
          <input
            required
            type="text"
            name="new-column-name"
            id="new-column-name"
            class="input input-sm text-sm input-ghost"
            data-on-load="
            let input = document.getElementById('new-column-name');
            input?.focus();
          "
            data-on-signal-patch-filter="{include: /show_create_column_form/}"
            data-on-signal-patch="
            let input = document.getElementById('new-column-name');
            input?.focus();
          "
          />
        </div>
        <div class="flex justify-between p-2">
          <button type="submit" class="btn btn-primary btn-sm">Create Column</button>
          <button
            type="button"
            class="btn btn-ghost btn-sm"
            data-on-click="$show_create_column_form = false"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
    """
  end

  def column_card(assigns) do
    ~H"""
    <div
      id={"card-#{@card.id}"}
      class="card card-xs border-slate-400 rounded-xl shadow-sm shadow-slate-400 bg-base-100"
    >
      <div class="card-body">
        <h3 class="text-base">{@card.title}</h3>
        <div class="card-actions justify-end">
          <button
            class="btn btn-circle btn-xs hover:text-error-content"
            data-on-click={"@delete('/column/#{@column.id}/card/#{@card.id}', {headers: {'X-Csrf-Token': '#{@csrf_token}'}})"}
          >
            <.icon name="hero-trash" class="size-4 shrink-0" />
          </button>
        </div>
      </div>
    </div>
    """
  end

  def add_card_form(assigns) do
    ~H"""
    <form
      id="add-card-form"
      class="p-2 border-slate-400 rounded-xl shadow-sm shadow-slate-400 bg-base-100"
      data-on-submit={"@post('/column/#{@column_id}/card/create', {headers: {'X-Csrf-Token': '#{@csrf_token}'}, contentType: 'form'});"}
    >
      <div class="space-y-4">
        <input
          id="add-card-input"
          name="title"
          data-on-load="
            let input = document.querySelector('#add-card-input');
            input?.focus();
          "
          type="text"
          class="input input-sm text-sm input-ghost"
          placeholder="Enter title for this card"
        />
        <div class="flex justify-between">
          <button class="btn btn-primary btn-sm" type="submit">Save</button>
          <button
            class="btn btn-ghost btn-sm"
            type="button"
            data-on-click={"@get('/column/#{@column_id}/card/create/cancel')"}
          >
            Cancel
          </button>
        </div>
      </div>
    </form>
    """
  end

  def add_card_button(assigns) do
    ~H"""
    <button
      type="button"
      class="btn btn-ghost btn-sm btn-block justify-start"
      data-on-click={"@get('/column/#{@column_id}/card/create')"}
    >
      <.icon name="hero-plus" class="size-4 shrink-0 stroke-2" /> Add Card
    </button>
    """
  end
end
