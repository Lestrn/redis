defmodule RedisWeb.PageHtml.TablePage do
  @moduledoc false
  use RedisWeb, :surface_live_view
  alias Moon.Design.Button
  alias Moon.Design.Table
  alias Moon.Design.Table.Column
  alias Redis.Repository.RedisRepo

  def mount(_params, _session, socket) do
    {:ok, assign(
      socket,
       fields: RedisRepo.fetch_data()
    )}
  end
end
