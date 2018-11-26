defmodule MastaniServer.Test.CMS.Search do
  use MastaniServer.TestTools

  # alias Helper.ORM
  alias MastaniServer.CMS

  setup do
    {:ok, user} = db_insert(:user)
    {:ok, _community} = db_insert(:community, %{title: "react"})
    {:ok, _community} = db_insert(:community, %{title: "php"})
    {:ok, _community} = db_insert(:community, %{title: "每日妹子"})
    {:ok, _community} = db_insert(:community, %{title: "javascript"})
    {:ok, _community} = db_insert(:community, %{title: "java"})

    {:ok, _community} = db_insert(:post, %{title: "react"})
    {:ok, _community} = db_insert(:post, %{title: "php"})
    {:ok, _community} = db_insert(:post, %{title: "每日妹子"})
    {:ok, _community} = db_insert(:post, %{title: "javascript"})
    {:ok, _community} = db_insert(:post, %{title: "java"})

    {:ok, ~m(user)a}
  end

  describe "[cms search post]" do
    test "search post by full title should valid paged posts" do
      {:ok, searched} = CMS.search_items(:post, %{title: "react"})

      assert searched |> is_valid_pagination?(:raw)
      assert searched.total_count == 1
      assert searched.entries |> Enum.at(0) |> Map.get(:title) == "react"
    end

    test "search post blur title should return valid communities" do
      {:ok, searched} = CMS.search_items(:post, %{title: "reac"})
      assert searched.entries |> Enum.at(0) |> Map.get(:title) == "react"

      {:ok, searched} = CMS.search_items(:post, %{title: "rea"})
      assert searched.entries |> Enum.at(0) |> Map.get(:title) == "react"

      {:ok, searched} = CMS.search_items(:post, %{title: "eac"})
      assert searched.entries |> Enum.at(0) |> Map.get(:title) == "react"

      {:ok, searched} = CMS.search_items(:post, %{title: "每日"})
      assert searched.entries |> Enum.at(0) |> Map.get(:title) == "每日妹子"

      {:ok, searched} = CMS.search_items(:post, %{title: "javasc"})
      assert searched.total_count == 1
      assert searched.entries |> Enum.at(0) |> Map.get(:title) == "javascript"

      {:ok, searched} = CMS.search_items(:post, %{title: "java"})
      assert searched.total_count == 2
      assert searched.entries |> Enum.any?(&(&1.title == "java"))
      assert searched.entries |> Enum.any?(&(&1.title == "javascript"))
    end

    test "search non exsit community should get empty pagi data" do
      {:ok, searched} = CMS.search_items(:community, %{title: "non-exsit"})
      assert searched |> is_valid_pagination?(:raw, :empty)
    end
  end

  describe "[cms search community]" do
    test "search community by full title should valid paged communities" do
      {:ok, searched} = CMS.search_items(:community, %{title: "react"})

      assert searched |> is_valid_pagination?(:raw)
      assert searched.total_count == 1
      assert searched.entries |> Enum.at(0) |> Map.get(:title) == "react"
    end

    test "search community blur title should return valid communities" do
      {:ok, searched} = CMS.search_items(:community, %{title: "reac"})
      assert searched.entries |> Enum.at(0) |> Map.get(:title) == "react"

      {:ok, searched} = CMS.search_items(:community, %{title: "rea"})
      assert searched.entries |> Enum.at(0) |> Map.get(:title) == "react"

      {:ok, searched} = CMS.search_items(:community, %{title: "eac"})
      assert searched.entries |> Enum.at(0) |> Map.get(:title) == "react"

      {:ok, searched} = CMS.search_items(:community, %{title: "每日"})
      assert searched.entries |> Enum.at(0) |> Map.get(:title) == "每日妹子"

      {:ok, searched} = CMS.search_items(:community, %{title: "javasc"})
      assert searched.total_count == 1
      assert searched.entries |> Enum.at(0) |> Map.get(:title) == "javascript"

      {:ok, searched} = CMS.search_items(:community, %{title: "java"})
      assert searched.total_count == 2
      assert searched.entries |> Enum.any?(&(&1.title == "java"))
      assert searched.entries |> Enum.any?(&(&1.title == "javascript"))
    end

    test "search non exsit community should get empty pagi data" do
      {:ok, searched} = CMS.search_items(:community, %{title: "non-exsit"})
      assert searched |> is_valid_pagination?(:raw, :empty)
    end
  end
end
