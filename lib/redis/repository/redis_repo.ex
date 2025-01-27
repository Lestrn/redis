defmodule Redis.Repository.RedisRepo do
  def test() do
    Redix.command(:redix, ["PING"])
  end

  def insert(key, value) do
    Redix.command(:redix, ["SET", key, value])
  end

  def update(old_key, new_key, value) do
    Redix.command(:redix, ["RENAME", old_key, new_key])
    Redix.command(:redix, ["SET", new_key, value])
  end

  def fetch_data() do
    {:ok, keys} = Redix.command(:redix, ["KEYS", "*"])

    Enum.map(keys, fn key ->
      %{key: key, value: Redix.command(:redix, ["GET", key]) |> extract_data_from_tuple()}
    end)
  end

  def get_field_by_key(key) do
    Redix.command(:redix, ["GET", key])
    |> extract_data_from_tuple()
  end

  def delete_data_by_key(key) do
    Redix.command(:redix, ["DEL", key])
  end

  def delete_all_data() do
    Redix.command(:redix, ["FLUSHALL"])
  end

  def key_exists?(key) do
    {:ok, value} = Redix.command(:redix, ["EXISTS", key])
    integer_to_boolean(value)
  end

  defp extract_data_from_tuple(tuple) do
    case tuple do
      {:ok, data} -> data
      _ -> nil
    end
  end

  def integer_to_boolean(0), do: false
  def integer_to_boolean(_), do: true
end
