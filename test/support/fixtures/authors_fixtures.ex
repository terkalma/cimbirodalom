defmodule Cimbirodalom.AuthorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cimbirodalom.Authors` context.
  """

  @doc """
  Generate a unique author slug.
  """
  def uniq_author_name, do: "Author#{System.unique_integer([:positive])}"

  @doc """
  Generate a author.
  """
  def author_fixture(attrs \\ %{}) do
    {:ok, author} =
      attrs
      |> Enum.into(%{
        description: "some description",
        img_path: "some img_path",
        name: uniq_author_name(),
      })
      |> Cimbirodalom.Authors.create_author()

    author
  end
end
