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
    thread = insert_thread()

    post1 = insert_post(thread)
    assert post1.position == 0

    # {:ok, %{inserted_sibling: post2}} =
    #   %Post{}
    #   |> OrderedSiblings.add_to_front(post_scope(thread.id))
    #   |> Repo.transaction

    post2 = insert_post(thread)
    assert post2.position == 0

    repo_result = Repo.all(from(p in Post, select: [{p.id, p.position}]))

    assert match?(repo_result, [{post2.id, 0}, {post1.id, 1}])
  end

  test "move" do
    thread = insert_thread()
    for index <- (10..0) do
      %Post{content: "post #{index}"}
      |> (fn post -> insert_post(thread, post) end).()
    end

    post_five = Repo.one(from(p in Post, where: p.content ==  "post 5"))

    assert post_five.position == 5

    OrderedSiblings.move(post_five, post_scope(thread.id), 2)
    |> Repo.transaction

    moved_post_five = Repo.one(from(p in Post, where: p.content ==  "post 5"))
    assert post_five.position == 2

    # Structs between position 5 and 2 have moved one position up.
    post_four = Repo.one(from(p in Post, where: p.content ==  "post 4"))
    assert post_four.position == 5

    # Rows above position 5 still in same place.
    post_six = Repo.one(from(p in Post, where: p.content ==  "post 6"))
    assert post_six.position == 6
  end

  defp insert_thread do
    %Thread{}
    |> Repo.insert!()
  end

  defp insert_post(thread, post \\ %Post{}) do
    {:ok, %{inserted_sibling: post}} =
      post
      |> Map.put(:thread_id, thread.id)
      |> OrderedSiblings.add_to_front(post_scope(thread.id))
      |> Repo.transaction
    post
  end


  defp post_scope(thread_id) do
    from(p in Post, where: p.thread_id == ^thread_id)
  end
end
