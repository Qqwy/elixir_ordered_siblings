defmodule Thread do
  use Ecto.Schema

  schema "threads" do
    field :title, :string

    has_many :posts, Post
  end
end

defmodule Post do
  use Ecto.Schema

  schema "posts" do
    belongs_to :thread, Thread
    field :content, :string
  end
end
