defmodule RedisWeb.PageHtml.TablePage do
    @moduledoc false
    use RedisWeb, :surface_live_view
    alias Moon.Design.Button

    def mount(_params, session, socket) do
      {:ok, socket}
    end
end
