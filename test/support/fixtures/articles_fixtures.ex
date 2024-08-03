defmodule Cimbirodalom.ArticlesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cimbirodalom.Articles` context.
  """

  @doc """
  Generate a unique article slug.
  """
  def unique_article_tile, do: "some title#{System.unique_integer([:positive])}"

  @doc """
  Generate a article.
  """
  def article_fixture_with_content(attrs \\ %{}) do
    {:ok, article} =
      attrs
      |> Enum.into(%{
        subtitle: "some subtitle",
        title: unique_article_tile()
      })
      |> Cimbirodalom.Articles.create_article()

    article
  end

  def article_fixture(attrs \\ %{}) do
    article = article_fixture_with_content(attrs)
    Cimbirodalom.Articles.get_article!(article.id)
  end
end
