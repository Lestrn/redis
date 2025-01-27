defmodule Redis.Schemas.RedisSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :key, :string
    field :value, :string
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
    |> validate_length(:key, max: 15)
    |> validate_length(:value, max: 15)
  end
end
