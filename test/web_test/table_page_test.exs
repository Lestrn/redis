defmodule Redis.TablePageTest do
  use RedisWeb.ConnCase, async: false
  alias Redis.Repository.RedisRepo
  import Phoenix.LiveViewTest

  describe "Web test" do
    setup do
      conn = build_conn()
      RedisRepo.insert("key_to_change", "gggg")
      {:ok, view, _html} = live(conn, ~p"/table")
      {:ok, conn: conn, view: view}
    end

    test "renders the page", %{view: view} do
      assert has_element?(view, "table")
    end

    test "add field event", %{view: view} do
      view
      |> element("button[phx-click]", "Insert new data")
      |> render_click()

      assert render(view) =~ "Add new field to redis"

      view
      |> form("form#insert-form",
        redis_schema: %{
          key: "inserted_key",
          value: "inserted_value"
        }
      )
      |> render_change()

      view |> form("form#insert-form") |> render_submit()

      assert render(view) =~ "inserted_key"
      assert render(view) =~ "inserted_value"
    end

    test "update field event", %{view: view} do
      view
      |> element("button[phx-click='set_open_change_dialog'][value='key_to_change']", "Change")
      |> render_click()

      assert render(view) =~ "Update field"

      view
      |> form("form#update-form",
        redis_schema: %{
          key: "key_to_change",
          value: "updated_value"
        }
      )
      |> render_change()

      view |> form("form#update-form") |> render_submit()

      assert render(view) =~ "key_to_change"
      assert render(view) =~ "updated_value"
    end

    test "delete field event", %{view: view} do
      view
      |> element("button[phx-click='set_open_change_dialog'][value='key_to_change']", "Change")
      |> render_click()

      assert render(view) =~ "Update field"

      view
      |> element("button[phx-click='submit_delete']", "Delete")
      |> render_click()

      refute render(view) =~ "key_to_change"
      refute render(view) =~ "updated_value"
    end
  end
end
