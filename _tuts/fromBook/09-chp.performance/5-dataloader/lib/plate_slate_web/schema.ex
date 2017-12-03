#---
# Excerpted from "Craft GraphQL APIs in Elixir with Absinthe",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wwgraphql for more book information.
#---
defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  alias PlateSlateWeb.Resolvers
  alias PlateSlateWeb.Schema.Middleware

  def middleware(middleware, field, object) do
    middleware
    |> apply(:errors, field, object)
    |> apply(:get_string, field, object)
    |> apply(:debug, field, object)
  end

  defp apply(middleware, :errors, _field, %{identifier: :mutation}) do
    middleware ++ [Middleware.ChangesetErrors]
  end
  defp apply([], :get_string, field, %{identifier: :allergy_info}) do
    [{Absinthe.Middleware.MapGet, to_string(field.identifier)}]
  end
  defp apply(middleware, :debug, _field, _object) do
    if System.get_env("DEBUG") do
      [{Middleware.Debug, :start}] ++ middleware
    else
      middleware
    end
  end
  defp apply(middleware, _, _, _) do
    middleware
  end

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults]
  end

  def dataloader() do
    alias PlateSlate.Menu
    Dataloader.new
    |> Dataloader.add_source(Menu, Menu.data())
  end

  def context(ctx) do
    ctx
    |> Map.put(:loader, dataloader())
  end

  import_types __MODULE__.MenuTypes
  import_types __MODULE__.OrderingTypes
  import_types __MODULE__.AccountsTypes


  query do
    # Other query fields


    field :menu_items, list_of(:menu_item) do
      arg :filter, :menu_item_filter
      arg :order, type: :sort_order, default_value: :asc
      resolve &Resolvers.Menu.menu_items/3
    end

    field :search, list_of(:search_result) do
      arg :matching, non_null(:string)
      resolve &Resolvers.Menu.search/3
    end

  end

  mutation do

    field :login_employee, :employee_session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &Resolvers.Accounts.login_employee/3
    end

    field :ready_order, :order_result do
      arg :id, non_null(:id)
      resolve &Resolvers.Ordering.ready_order/3
    end
    field :complete_order, :order_result do
      arg :id, non_null(:id)
      resolve &Resolvers.Ordering.complete_order/3
    end

    field :place_order, :order_result do
      arg :input, non_null(:place_order_input)
      resolve &Resolvers.Ordering.place_order/3
    end

    field :create_menu_item, :menu_item_result do
      arg :input, non_null(:menu_item_input)
      middleware Middleware.Authorize, "employee"
      resolve &Resolvers.Menu.create_item/3
    end

  end

  subscription do
    field :update_order, :order do
      arg :id, non_null(:id)

      config fn args, _info ->
        {:ok, topic: args.id}
      end

      trigger [:ready_order, :complete_order], topic: fn
        %{order: order} -> [to_string(order.id)]
        _ -> []
      end

      resolve fn %{order: order}, _ , _ ->
        {:ok, order}
      end
    end

    field :new_order, :order do
      config fn _args, _info ->
        {:ok, topic: "*"}
      end
    end
  end

  union :viewer do
    types [:customer, :employee]

    resolve_type fn
      %{role: "customer"} -> :customer
      %{role: "employee"} -> :employee
    end
  end

  @desc "An error encountered trying to persist input"
  object :input_error do
    field :key, non_null(:string)
    field :message, non_null(:string)
  end

  scalar :date do
    parse fn input ->
      with %Absinthe.Blueprint.Input.String{value: value} <- input,
      {:ok, date} <- Date.from_iso8601(value) do
        {:ok, date}
      else
        _ -> :error
      end
    end

    serialize fn date ->
      Date.to_iso8601(date)
    end
  end

  scalar :decimal do
    parse fn
      %{value: value}, _ ->
        Decimal.parse(value)
      _, _ ->
        :error
    end
    serialize &to_string/1
  end

  enum :sort_order do
    value :asc
    value :desc
  end


end
