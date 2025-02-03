defmodule Redis.TablePageTest do
  use RedisWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  @table_id "redis-table"

  describe "Web test" do
    setup do
      conn = build_conn()
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
      |> form("form#insert_form",
        redis_schema: %{
          key: "key22",
          value: "value22"
        }
      )
      |> render_change()

      view |> form("form#insert_form") |> render_submit()

      assert render(view) =~ "key22"
      assert render(view) =~ "value22"
    end
  end
end
