defmodule Redis.Schemas.RedisSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :key, :string
    field :value, :string
  end

  def changeset(struct, attrs, validate? \\ true) do
    struct
    |> cast(attrs, [:key, :value])
    |> maybe_validate(validate?)
  end

  defp maybe_validate(changeset, true) do
    changeset
    |> validate_required([:key, :value])
    |> validate_length(:key, max: 15)
    |> validate_length(:value, max: 15)
  end

  defp maybe_validate(changeset, false), do: changeset
end
