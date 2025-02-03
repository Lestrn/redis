defmodule Redis.Repository.RedisRepo do
  def test(conn \\ :redix) do
    Redix.command(conn, ["PING"])
  end

  def insert(key, value, conn \\ :redix) do
    case key_exists?(key) do
      false -> Redix.command(conn, ["SET", key, value])
      true -> {:error, :key_already_exists}
    end
  end

  def update(old_key, new_key, value, conn \\ :redix) do
    case validate_update(old_key, new_key, conn) do
      {:ok, :keys_are_equal} ->
        Redix.command(conn, ["SET", new_key, value])

      {:ok, :keys_are_different} ->
        Redix.command(conn, ["RENAME", old_key, new_key])
        Redix.command(conn, ["SET", new_key, value])

      {:error, error} ->
        {:error, error}
    end
  end

  def fetch_data(conn \\ :redix) do
    {:ok, keys} = Redix.command(conn, ["KEYS", "*"])

    Enum.map(keys, fn key ->
      %{key: key, value: Redix.command(conn, ["GET", key]) |> extract_data_from_tuple()}
    end)
  end

  def get_field_by_key(key, conn \\ :redix) do
    Redix.command(conn, ["GET", key])
    |> extract_data_from_tuple()
  end

  def delete_data_by_key(key, conn \\ :redix) do
    Redix.command(conn, ["DEL", key])
  end

  def delete_all_data(conn \\ :redix) do
    Redix.command(conn, ["FLUSHALL"])
  end

  def key_exists?(key, conn \\ :redix) do
    {:ok, value} = Redix.command(conn, ["EXISTS", key])
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

  defp validate_update(old_key, new_key, conn) do
    if(old_key == new_key) do
      {:ok, :keys_are_equal}
    else
      (key_exists?(new_key, conn) && {:error, :key_already_exists}) || {:ok, :keys_are_different}
    end
  end
end
