defmodule MastaniServerWeb.Schema.CMS.PostTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: MastaniServer.Repo

  alias MastaniServerWeb.Resolvers

  import_types(MastaniServerWeb.Schema.AccountTypes)

  object :post do
    field(:id, non_null(:id))
    field(:title, non_null(:string))
    field(:body, non_null(:string))
    field(:author, :author, resolve: assoc(:author))
    # note the name convention here
    field(:starred_users, list_of(:user), resolve: assoc(:starredUsers))
  end

  object :author do
    field(:id, non_null(:id))
    field(:role, :string)
    field(:posts, list_of(:post), resolve: assoc(:posts))
  end

  object :cms_post_queries do
    @desc "hehehef: Get all links"
    field :all_posts, non_null(list_of(non_null(:post))) do
      resolve(&Resolvers.CMS.Post.all_posts/3)
    end
  end

  object :cms_post_mutations do
    @desc "hehehef: create a user"
    field :create_post, :post do
      arg(:title, non_null(:string))
      arg(:body, non_null(:string))

      resolve(&Resolvers.CMS.Post.create_post/3)
    end

    # field :star_post, :post do
      # arg(:title, non_null(:string))
      # arg(:body, non_null(:string))

      # resolve(&Resolvers.CMS.Post.start_post/3)
    # end
  end
end
