defmodule OrderedSiblings do
  import Ecto.Query

  @moduledoc """
  Documentation for OrderedSiblings.
  """

  @doc """
  Pushes the given changeset to the end of the order
  indicated by 'scope'.
  """
  def push(changeset, scope, options) do
    Ecto.Multi.new
    |> increment_siblings_order(scope)
  end

  @doc """
  Moves the changeset to a new location in the ordering.
  """
  def move(changeset, scope, new_position, options) do
  end

  @doc """
  Removes the given changeset from the scope.

  TODO
  """
  def remove(changeset, scope, options) do
  end

  # TODO configurable 'order' column name.
  def increment_siblings_order(ecto_multi, scope) do
    ecto_multi
    |> Ecto.Multi.update_all(:increment_siblings_order, scope, inc: [order: 1])
  end

  def decrement_siblings_order(ecto_multi, scope) do
    ecto_multi
    |> Ecto.Multi.update_all(:decrement_siblings_order, scope, inc: [order: -1])
  end

  def movement_query(scope, start_pos, end_pos) when start_pos < end_pos do
    length = end_pos - start_pos + 1
    from(p in scope, where: p.order >= ^start_pos and p.order <= ^end_pos, update: [set: [order: fragment("? + (? - ? - 1 + ?) % ? ", ^start_pos, p.order, ^start_pos, ^length, ^length)]])
  end

  def movement_query(scope, start_pos, end_pos) do
    length = start_pos - end_pos + 1
    from(p in scope, where: p.order >= ^end_pos and p.order <= ^start_pos, update: [set: [order: fragment("? + (? - ? + 1 + ?) % ? ", ^end_pos, p.order, ^end_pos, ^length, ^length)]])
  end
end
