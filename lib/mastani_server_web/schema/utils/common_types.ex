defmodule MastaniServerWeb.Schema.Utils.CommonTypes do
  @moduledoc """
  common types might be used in all context
  """
  import MastaniServerWeb.Schema.Utils.Helper

  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: MastaniServer.Repo

  object :status do
    field(:done, :boolean)
    field(:id, :id)
  end

  object :done do
    field(:done, :boolean)
  end

  input_object :ids do
    field(:id, :id)
  end

  input_object :common_paged_filter do
    pagination_args()
  end
end
