defmodule Redis.Repository.RedisRepo do
  def test() do
    Redix.command(:redix, ["PING"])
  end

  def insert(key, value) do
    case key_exists?(key) do
      false -> Redix.command(:redix, ["SET", key, value])
      true -> {:error, :key_already_exists}
    end
  end

  def update(old_key, new_key, value) do
    case validate_update(old_key, new_key) do
      {:ok, :keys_are_equal} ->
        Redix.command(:redix, ["SET", new_key, value])

      {:ok, :keys_are_different} ->
        Redix.command(:redix, ["RENAME", old_key, new_key])
        Redix.command(:redix, ["SET", new_key, value])

      {:error, error} ->
        {:error, error}
    end
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

  defp integer_to_boolean(0), do: false
  defp integer_to_boolean(_), do: true

  defp validate_update(old_key, new_key) do
    if(old_key == new_key) do
      {:ok, :keys_are_equal}
    else
      (key_exists?(new_key) && {:error, :key_already_exists}) || {:ok, :keys_are_different}
    end
  end
end
