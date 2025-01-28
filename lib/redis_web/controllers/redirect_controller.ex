defmodule RedisWeb.RedirectController do
  use RedisWeb, :controller

  def to_table(conn, _params) do
    redirect(conn, to: "/table")
  end
end
