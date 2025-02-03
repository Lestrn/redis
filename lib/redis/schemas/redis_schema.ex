defmodule Redis.Schemas.RedisSchema do
  use Ecto.Schema
  import Ecto.Changeset
  alias Redis.Repository.RedisRepo

  @primary_key false
  embedded_schema do
    field :key, :string
    field :value, :string
    field :old_key, :string
    field :action, :string
  end

  def changeset(struct, attrs, validate? \\ true) do
    struct
    |> cast(attrs, [:key, :value, :old_key, :action])
    |> maybe_validate(validate?)
  end

  defp maybe_validate(changeset, true) do
    changeset
    |> validate_required([:key, :value])
    |> validate_length(:key, max: 15)
    |> validate_length(:value, max: 15)
    |> validate_key_doesnt_exist()
  end

  defp maybe_validate(changeset, false), do: changeset

  defp validate_key_doesnt_exist(changeset) do
    action = get_field(changeset, :action)
    validate_key(action, changeset)
  end

  defp validate_key("insert", changeset) do
    key = get_field(changeset, :key)

    if RedisRepo.key_exists?(key) do
      add_error(changeset, :key, "Key already exists")
    else
      changeset
    end
  end

  defp validate_key("change", changeset) do
    key = get_field(changeset, :key)
    old_key = get_field(changeset, :old_key)
    if RedisRepo.key_exists?(key) && key != old_key do
      add_error(changeset, :key, "Key already exists")
    else
      changeset
    end
  end
end
