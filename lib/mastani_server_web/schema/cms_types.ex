defmodule MastaniServerWeb.Schema.CMS.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: MastaniServer.Repo

  import Absinthe.Resolution.Helpers
  alias MastaniServer.CMS
  alias MastaniServerWeb.{Resolvers, Schema}
  alias MastaniServerWeb.Middleware

  import_types(Schema.CMS.Misc)

  object :comment do
    field(:id, :id)
    field(:body, :string)
    field(:author, :user, resolve: dataloader(CMS, :author))
    field(:inserted_at, :datetime)
    field(:updated_at, :datetime)
  end

  object :post do
    interface(:article)
    field(:id, :id)
    field(:title, :string)
    field(:digest, :string)
    field(:length, :integer)
    field(:link_addr, :string)
    field(:body, :string)
    field(:views, :integer)
    field(:tags, list_of(:tag), resolve: dataloader(CMS, :tags))
    field(:inserted_at, :datetime)
    field(:updated_at, :datetime)

    # field :author_old, :user do
    # resolve(&Resolvers.CMS.load_author/3)
    # end

    field(:author, :user, resolve: dataloader(CMS, :author))

    field :comments, list_of(:comment) do
      arg(:type, :post_type, default_value: :post)
      arg(:filter, :article_filter)
      arg(:action, :comment_action, default_value: :comment)

      middleware(Middleware.SizeChecker)
      resolve(dataloader(CMS, :comments))
    end

    field :viewer_has_favorited, :boolean do
      arg(:arg_viewer_reacted, :arg_viewer_reacted, default_value: :arg_viewer_reacted)

      middleware(Middleware.Authorize, :login)
      middleware(Middleware.PutCurrentUser)
      resolve(dataloader(CMS, :favorites))
      middleware(Middleware.ViewerReactedConvert)
      #TODO: Middleware.Logger
    end

    # field :viewer_has_favorited_old, :boolean do
    # arg(:type, :post_type, default_value: :post)
    # arg(:action, :favorite_action, default_value: :favorite)

    # middleware(Middleware.Authorize, :login)
    # resolve(&Resolvers.CMS.viewer_has_reacted/3)
    # end

    field :viewer_has_starred, :boolean do
      arg(:arg_viewer_reacted, :arg_viewer_reacted, default_value: :arg_viewer_reacted)

      middleware(Middleware.Authorize, :login)
      middleware(Middleware.PutCurrentUser)
      resolve(dataloader(CMS, :stars))
      middleware(Middleware.ViewerReactedConvert)
    end

    # field :viewer_has_starred_old, :boolean do
    # arg(:type, :post_type, default_value: :post)
    # arg(:action, :star_action, default_value: :star)

    # middleware(Middleware.Authorize, :login)
    # resolve(&Resolvers.CMS.viewer_has_reacted/3)
    # end

    field :favorited_users, list_of(:user) do
      # TODO: tmp
      arg(:filter, :article_filter)

      middleware(Middleware.SizeChecker)
      resolve(dataloader(CMS, :favorites))
    end

    # field :favorited_users_old, list_of(:user) do
    # arg(:filter, :article_filter)
    # arg(:type, :post_type, default_value: :post)
    # arg(:action, :favorite_action, default_value: :favorite)
    # resolve(&Resolvers.CMS.reaction_users/3)
    # end

    field :favorited_count, :integer do
      arg(:arg_count, :arg_count, default_value: :arg_count)
      # middleware(Middleware.SeeMe)
      resolve(dataloader(CMS, :favorites))
      middleware(Middleware.ConvertToInt)
    end

    # field :favorited_count_old, :integer do
    # arg(:type, :post_type, default_value: :post)
    # arg(:action, :favorite_action, default_value: :favorite)
    # resolve(&Resolvers.CMS.reaction_count/3)
    # end

    field :starred_count, :integer do
      arg(:arg_count, :arg_count, default_value: :arg_count)
      resolve(dataloader(CMS, :stars))
      middleware(Middleware.ConvertToInt)
    end

    # field :starred_count_old, :integer do
    # arg(:type, :post_type, default_value: :post)
    # arg(:action, :star_action, default_value: :star)
    # resolve(&Resolvers.CMS.reaction_count/3)
    # end

    field :starred_users, list_of(:user) do
      # TODO: tmp
      arg(:filter, :article_filter)

      middleware(Middleware.SizeChecker)
      resolve(dataloader(CMS, :stars))
    end

    # field :starred_users_old, list_of(:user) do
    # arg(:filter, :article_filter)
    # arg(:type, :post_type, default_value: :post)
    # arg(:action, :star_action, default_value: :star)
    # resolve(&Resolvers.CMS.reaction_users/3)
    # end
  end

  object :paged_posts do
    field(:entries, list_of(:post))
    field(:total_entries, :integer)
    field(:page_size, :integer)
    field(:total_pages, :integer)
    field(:page_number, :integer)
  end

  object :community do
    field(:title, :string)
    field(:desc, :string)
    field(:inserted_at, :datetime)
    field(:updated_at, :datetime)
  end

  object :tag do
    field(:title, :string)
    field(:color, :string)
    field(:part, :string)
    field(:inserted_at, :datetime)
    field(:updated_at, :datetime)
  end

  # object :author do
  # field(:id, non_null(:id))
  # field(:role, :string)
  # field(:posts, list_of(:post), resolve: assoc(:posts))
  # end

  # object :comment do
  # field(:id, non_null(:id))
  # field(:body, :string)
  # end
end