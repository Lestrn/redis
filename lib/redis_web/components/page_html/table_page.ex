defmodule RedisWeb.PageHtml.TablePage do
  @moduledoc false
  use RedisWeb, :surface_live_view
  alias Moon.Design.{Modal, Form, Form.Field, Form.Input, Button, Table, Table.Column}
  alias Redis.Schemas.RedisSchema
  alias Redis.Repository.RedisRepo

  data(key_already_exists, :boolean, default: false)
  data(keep_insert_dialog_open, :boolean, default: false)
  data(keep_change_dialog_open, :boolean, default: false)
  data(old_key_name, :string, default: "")

  data(form_insert_changeset, :any,
    default: RedisSchema.changeset(%RedisSchema{key: nil, value: nil}, %{})
  )

  data(form_change_changeset, :any,
    default: RedisSchema.changeset(%RedisSchema{key: nil, value: nil}, %{})
  )

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(fields: RedisRepo.fetch_data())}
  end

  def handle_event("set_open_insert_dialog", _, socket) do
    Modal.open("insert_modal")
    {:noreply, socket |> assign(keep_insert_dialog_open: true)}
  end

  def handle_event("set_close_insert_dialog", _, socket) do
    Modal.close("insert_modal")

    {:noreply,
     socket
     |> assign(
       form_insert_changeset: RedisSchema.changeset(%RedisSchema{key: nil, value: nil}, %{})
     )
     |> assign(keep_insert_dialog_open: false)
     |> assign(key_already_exists: false)}
  end

  def handle_event(
        "validate_change_insert",
        %{"redis_schema" => %{"key" => key, "value" => value}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(
       form_insert_changeset:
         socket.assigns.form_insert_changeset.data
         |> RedisSchema.changeset(%{key: key, value: value})
         |> Map.put(:action, :insert)
     )
     |> assign(key_already_exists: RedisRepo.key_exists?(key))}
  end

  def handle_event("submit_add", _params, socket) do
    Modal.close("insert_modal")

    data = socket.assigns.form_insert_changeset.changes
    RedisRepo.insert(data.key, data.value)

    {:noreply,
     socket
     |> assign(keep_insert_dialog_open: false)
     |> assign(fields: RedisRepo.fetch_data())}
  end

  def handle_event("set_open_change_dialog", %{"value" => key}, socket) do
    Modal.open("change_modal")
    value = RedisRepo.get_field_by_key(key)

    {:noreply,
     socket
     |> assign(
       form_change_changeset:
         RedisSchema.changeset(%RedisSchema{key: nil, value: nil}, %{
           "key" => key,
           "value" => value
         })
     )
     |> assign(keep_change_dialog_open: true)
     |> assign(old_key_name: key)}
  end

  def handle_event(
        "validate_change",
        %{"redis_schema" => %{"key" => key, "value" => value}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(
       form_change_changeset:
         socket.assigns.form_change_changeset.data
         |> RedisSchema.changeset(%{key: key, value: value})
         |> Map.put(:action, :insert)
     )
     |> assign(
       key_already_exists: RedisRepo.key_exists?(key) && key != socket.assigns.old_key_name
     )}
  end

  def handle_event("set_close_change_dialog", _, socket) do
    Modal.close("change_modal")

    {:noreply,
     socket
     |> assign(
       form_change_changeset: RedisSchema.changeset(%RedisSchema{key: nil, value: nil}, %{})
     )
     |> assign(keep_change_dialog_open: false)
     |> assign(key_already_exists: false)}
  end

  def handle_event("submit_update", _, socket) do
    Modal.close("change_modal")
    data = socket.assigns.form_change_changeset.changes

    RedisRepo.update(socket.assigns.old_key_name, data.key, data.value)

    {:noreply,
     socket
     |> assign(keep_change_dialog_open: false)
     |> assign(fields: RedisRepo.fetch_data())}
  end

  def handle_event("submit_delete", _, socket) do
    Modal.close("change_modal")

    RedisRepo.delete_data_by_key(socket.assigns.old_key_name)

    {:noreply,
     socket
     |> assign(keep_change_dialog_open: false)
     |> assign(fields: RedisRepo.fetch_data())}
  end
end
