defmodule Redis.Repository.RedisRepo do
  def test() do
    Redix.command(:redix, ["PING"])
  end

  def insert(key, value) do
    Redix.command(:redix, ["SET", key, value])
  end

  def fetch_data() do
   {:ok, keys} = Redix.command(:redix, ["KEYS", "*"])
    Enum.map(keys, fn key -> %{key: key, value:  Redix.command(:redix, ["GET", key]) |> extract_data_from_tuple()} end)
  end

  def delete_data_by_key(key) do
    Redix.command(:redix, ["DEL", key])
  end

  def delete_all_data() do
    Redix.command(:redix, ["FLUSHALL"])
  end

  defp extract_data_from_tuple(tuple) do
    case tuple do
      {:ok, data} -> data
      _ -> nil
    end
  end
end
