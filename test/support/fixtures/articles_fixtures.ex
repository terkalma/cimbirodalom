defmodule Cimbirodalom.ArticlesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cimbirodalom.Articles` context.
  """

  @doc """
  Generate a unique article slug.
  """
  def unique_article_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a article.
  """
  def article_fixture(attrs \\ %{}) do
    {:ok, article} =
      attrs
      |> Enum.into(%{
        slug: unique_article_slug(),
        subtitle: "some subtitle",
        title: "some title"
      })
      |> Cimbirodalom.Articles.create_article()

    article
  end
end
