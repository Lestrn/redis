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

  data(form_insert_changeset, :any, default: nil)

  data(form_change_changeset, :any, default: nil)

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(fields: RedisRepo.fetch_data())}
  end

  def handle_event("set_open_insert_dialog", _, socket) do
    Modal.open("insert_modal")

    {:noreply,
     socket
     |> assign(keep_insert_dialog_open: true)
     |> assign(
       form_insert_changeset:
         RedisSchema.changeset(%RedisSchema{key: nil, value: nil}, %{}, false)
     )}
  end

  def handle_event("set_close_insert_dialog", _, socket) do
    Modal.close("insert_modal")

    {:noreply,
     socket
     |> assign(
       form_insert_changeset:
         RedisSchema.changeset(%RedisSchema{key: nil, value: nil}, %{}, false)
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
         |> RedisSchema.changeset(%{key: key, value: value}, false)
         |> Map.put(:action, :insert)
     )
     |> assign(key_already_exists: false)}
  end

  def handle_event("submit_add", %{"redis_schema" => %{"key" => key, "value" => value}}, socket) do
    validated_changeset = RedisSchema.changeset(%RedisSchema{key: key, value: value}, %{}, true)
    key_exists = RedisRepo.key_exists?(key)

    if(validated_changeset.valid? && !key_exists) do
      {:noreply, submit_add(key, value, socket)}
    else
      {:noreply, cancel_add(validated_changeset, key_exists, socket)}
    end
  end

  def handle_event("set_open_change_dialog", %{"value" => key}, socket) do
    Modal.open("change_modal")
    value = RedisRepo.get_field_by_key(key)

    {:noreply,
     socket
     |> assign(
       form_change_changeset:
         RedisSchema.changeset(
           %RedisSchema{key: nil, value: nil},
           %{
             "key" => key,
             "value" => value
           },
           false
         )
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
         |> RedisSchema.changeset(%{key: key, value: value}, false)
         |> Map.put(:action, :insert)
     )
     |> assign(key_already_exists: false)}
  end

  def handle_event("set_close_change_dialog", _, socket) do
    Modal.close("change_modal")

    {:noreply,
     socket
     |> assign(
       form_change_changeset:
         RedisSchema.changeset(%RedisSchema{key: nil, value: nil}, %{}, false)
     )
     |> assign(keep_change_dialog_open: false)
     |> assign(key_already_exists: false)}
  end

  def handle_event(
        "submit_update",
        %{"redis_schema" => %{"key" => key, "value" => value}},
        socket
      ) do
    validated_changeset = RedisSchema.changeset(%RedisSchema{key: key, value: value}, %{}, true)
    key_exists = RedisRepo.key_exists?(key) && key != socket.assigns.old_key_name

    if(validated_changeset.valid? && !key_exists) do
      {:noreply, submit_update(key, value, socket)}
    else
      {:noreply, cancel_update(validated_changeset, key_exists, socket)}
    end
  end

  def handle_event("submit_delete", _, socket) do
    Modal.close("change_modal")

    RedisRepo.delete_data_by_key(socket.assigns.old_key_name)

    {:noreply,
     socket
     |> assign(keep_change_dialog_open: false)
     |> assign(fields: RedisRepo.fetch_data())}
  end

  defp submit_add(key, value, socket) do
    Modal.close("insert_modal")
    RedisRepo.insert(key, value)

    socket
    |> assign(
      form_insert_changeset: RedisSchema.changeset(%RedisSchema{key: nil, value: nil}, %{}, false)
    )
    |> assign(keep_insert_dialog_open: false)
    |> assign(key_already_exists: false)
    |> assign(fields: RedisRepo.fetch_data())
  end

  defp cancel_add(validated_changeset, key_exists, socket) do
    socket
    |> assign(form_insert_changeset: validated_changeset)
    |> assign(key_already_exists: key_exists)
  end

  defp submit_update(key, value, socket) do
    Modal.close("change_modal")

    RedisRepo.update(socket.assigns.old_key_name, key, value)

    socket
    |> assign(keep_change_dialog_open: false)
    |> assign(fields: RedisRepo.fetch_data())
  end

  defp cancel_update(validated_changeset, key_exists, socket) do
    socket
    |> assign(form_change_changeset: validated_changeset)
    |> assign(key_already_exists: key_exists)
  end

end
