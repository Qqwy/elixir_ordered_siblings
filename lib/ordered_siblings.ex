defmodule OrderedSiblings do
  import Ecto.Query

  @moduledoc """
  Documentation for OrderedSiblings.
  """

  @doc """
  Pushes the given changeset to position `0` of the siblings indicated by 'scope',
  by incrementing all siblings' positions by one before inserting.
  """
  def add_to_front(changeset, scope, options \\ []) do
    prepared_changeset =
      changeset
      |> Ecto.Changeset.put_change(:position, 0)

    Ecto.Multi.new
    |> increment_siblings_order(scope)
    |> Ecto.Multi.insert(prepared_changeset)
  end

  @doc """
  Moves the changeset to a new location in the ordering,
  by changing the `position` column of all elements in-between the old position and the new one:

  - If the element moves from a high position to a low position, all elements in-between will shift one position upwards.
  - If the element moves from a low position to a high position, all elements in-betweenw ill shift one position downwards.

  The contained update statement is written in a way that works
  with a UNIQUE constraint (on `[your_scope, :position]`), which means
  that no race conditions (where two rows in your scope will end up with the same position) can occur, regardless of the transaction isolation level that you have configured for your database.
  """
  def move(changeset, scope, new_position, options \\ []) do
    current_position = Ecto.Changeset.get_field(changeset, position)

    Ecto.Multi.new
    |> Ecto.Multi.update_all(movement_query(scope, current_position, new_position), [])
  end

  @doc """
  Removes the given Ecto-schema-supporting struct from the scope,
  and decrements all later siblings' positions by one before inserting.
  """
  def remove(changeset_or_struct, scope, options \\ []) do
    changeset = Ecto.Changeset.change(changeset_or_struct)
    position = Ecto.Changeset.get_field(changeset, :position)
    later_siblings = from(p in scope, where: p.position > ^position)

    Ecto.Multi.new
    |> Ecto.Multi.delete(:remove_required_sibling, changeset)
    |> Ecto.Multi.update_all(:decrement_later_siblings, later_siblings, inc: [position: -1])
  end

  # TODO configurable 'order' column name.
  def increment_siblings_order(ecto_multi, scope) do
    ecto_multi
    |> Ecto.Multi.update_all(:increment_siblings_order, scope, inc: [position: 1])
  end

  def decrement_siblings_order(ecto_multi, scope) do
    ecto_multi
    |> Ecto.Multi.update_all(:decrement_siblings_order, scope, inc: [position: -1])
  end

  defp movement_query(scope, start_pos, end_pos) when start_pos < end_pos do
    length = end_pos - start_pos + 1
    from(p in scope, where: p.position >= ^start_pos and p.position <= ^end_pos, update: [set: [position: fragment("? + (? - ? - 1 + ?) % ? ", ^start_pos, p.position, ^start_pos, ^length, ^length)]])
  end

  defp movement_query(scope, start_pos, end_pos) do
    length = start_pos - end_pos + 1
    from(p in scope, where: p.position >= ^end_pos and p.position <= ^start_pos, update: [set: [position: fragment("? + (? - ? + 1 + ?) % ? ", ^end_pos, p.position, ^end_pos, ^length, ^length)]])
  end

  # Extracts position column name from options or configuration.
  defp position_column(options) do
    options[:position_column_name] || Application.get_env(OrderedSiblings, :position_column_name) || :position
  end
end
