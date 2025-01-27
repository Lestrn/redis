defmodule RedisWeb.PageHtml.TablePage do
  @moduledoc false
  use RedisWeb, :surface_live_view
  alias Moon.Design.{Modal, Form, Form.Field, Form.Input, Button, Table, Table.Column}
  alias Redis.Schemas.RedisSchema
  alias Redis.Repository.RedisRepo

  data(keep_insert_dialog_open, :boolean, default: false)

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(fields: RedisRepo.fetch_data())
     |> assign(form_changeset: RedisSchema.changeset(%RedisSchema{key: nil, value: nil}, %{}))}
  end

  def handle_event("set_open_insert_dialog", _, socket) do
    Modal.open("insert_modal")
    {:noreply, socket |> assign(keep_insert_dialog_open: true)}
  end

  def handle_event("set_close_insert_dialog", _, socket) do
    Modal.close("insert_modal")
    {:noreply, socket |> assign(keep_insert_dialog_open: false)}
  end

  def handle_event(
        "validate_change_insert",
        %{"redis_schema" => %{"key" => key, "value" => value}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(
       form_changeset:
         socket.assigns.form_changeset.data
         |> RedisSchema.changeset(%{key: key, value: value})
         |> Map.put(:action, :insert)
     )}
  end

  def handle_event("submit_add", _params, socket) do
    Modal.close("insert_modal")

    data = socket.assigns.form_changeset.changes
    RedisRepo.insert(data.key, data.value)

    {:noreply,
     socket
     |> assign(keep_insert_dialog_open: false)
     |> assign(fields: RedisRepo.fetch_data())}
  end
end
