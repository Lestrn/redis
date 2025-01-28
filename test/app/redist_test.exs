defmodule Redis.RedistTest do
  use ExUnit.Case
  alias Redis.Repository.RedisRepo

  setup %{} do
    {:ok, conn} = Redix.start_link("redis://localhost:6379") #start redis on port 6379, changing port to 6380 will make test env not isolated
    Redix.command(conn, ["FLUSHALL"])
    Redix.command(conn, ["SET", "key", "value"])
    Redix.command(conn, ["SET", "key2", "value2"])
    {:ok, conn: conn}
  end

  test "test connection", %{conn: conn} do
    assert {:ok, "PONG"} == RedisRepo.test(conn)
  end

  test "insert data success", %{conn: conn} do
    assert {:ok, "OK"} == RedisRepo.insert("key_test_1", "key_value_1", conn)
  end

  test "update data success", %{conn: conn} do
    assert {:ok, "OK"} == RedisRepo.update("key", "key1", "new_value", conn)
  end

  test "get field by a key success", %{conn: conn} do
    assert "value" == RedisRepo.get_field_by_key("key", conn)
  end

  test "fetch data succes", %{conn: conn} do
    assert [] != RedisRepo.fetch_data(conn)
  end

  test "delete data by key success", %{conn: conn} do
    assert {:ok, 1} == RedisRepo.delete_data_by_key("key", conn)
  end

  test "delete all data success", %{conn: conn} do
    assert {:ok, "OK"} == RedisRepo.delete_all_data(conn)
  end

  test "failed insert due to exisitng key", %{conn: conn} do
    assert {:error, :key_already_exists} == RedisRepo.insert("key", "new_value", conn)
  end

  test "failed update due to exisitng key", %{conn: conn} do
    assert {:error, :key_already_exists} == RedisRepo.update("key", "key2", "new_value", conn)
  end

  test "check key_exists? function", %{conn: conn} do
    assert true == RedisRepo.key_exists?("key", conn)
    assert false == RedisRepo.key_exists?("non_exisitng_key", conn)
  end
end
