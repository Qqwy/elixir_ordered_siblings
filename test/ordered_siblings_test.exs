defmodule OrderedSiblingsTest do
  use ExUnit.Case, async: true
  doctest OrderedSiblings

  alias OrderedSiblings.Repo
  import Ecto.Query

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "the truth" do
    assert 1 + 1 == 2
  end


  test "add_to_front" do
    thread =
      %Thread{}
     |> Repo.insert!()

    {:ok, %{inserted_sibling: post1}} =
      %Post{thread_id: thread.id}
      |> OrderedSiblings.add_to_front(post_scope(thread.id))
      |> Repo.transaction

    assert post1.position == 0

    {:ok, %{inserted_sibling: post2}} =
      %Post{}
      |> OrderedSiblings.add_to_front(post_scope(thread.id))
      |> Repo.transaction

    assert post2.position == 0

    repo_result = Repo.all(from(p in Post, select: [{p.id, p.position}]))

    assert match?(repo_result, [{post2.id, 0}, {post1.id, 1}])
  end


  defp post_scope(thread_id) do
    from(p in Post, where: p.thread_id == ^thread_id)
  end
end
