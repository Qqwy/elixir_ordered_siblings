defmodule OrderedSiblingsTest do
  use ExUnit.Case
  doctest OrderedSiblings

  alias OrderedSiblings.Repo
  import Ecto.Query

  test "the truth" do
    assert 1 + 1 == 2
  end


  test "add_to_front" do
    thread = %Thread{}
    Repo.insert!(thread)

    post1 =
      %Post{}
      |> OrderedSiblings.add_to_front()
      |> Repo.run!

    assert post1.position == 0

    post2 =
      %Post{}
      |> OrderedSiblings.add_to_front()
      |> Repo.run!

    assert post2.position == 0

    repo_result = Repo.all(from(p in Post, select: [{p.id, p.position}]))

    assert match?(repo_result, [{post2.id, 0}, {post1.id, 1}])
  end
end
