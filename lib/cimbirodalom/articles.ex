defmodule Cimbirodalom.Articles do
  @moduledoc """
  The Articles context.
  """

  import Ecto.Query, warn: false
  alias Cimbirodalom.Repo

  alias Cimbirodalom.Articles.Article
  alias Cimbirodalom.Articles.Content

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles do
    Repo.all(Article) |> Repo.preload(:content)
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123)
      %Article{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article!(id), do: Repo.get!(Article, id)

  def get_content_id_by_article(article_id) do
    case Repo.one(
           from c in Content,
             where: c.article_id == ^article_id and is_nil(c.content_id),
             select: c.id
         ) do
      nil -> raise "Content not found"
      id -> id
    end
  end

  def get_content!(id), do: Repo.get!(Content, id)

  @doc """
  Creates a article.

  ## Examples

      iex> create_article(%{field: value})
      {:ok, %Article{}}

      iex> create_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article(%{content: %{}} = attrs) do
    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  def create_article(%{} = attrs) do
    %Article{content: %Content{}}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a article.

  ## Examples

      iex> update_article(article, %{field: new_value})
      {:ok, %Article{}}

      iex> update_article(article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  def persist_document!(%{
        version: version,
        contents: contents,
        inverted_changes: inverted_changes,
        fetched: true,
        content_id: content_id
      }) do
    from(c in Content,
      where: c.id == ^content_id,
      update: [
        set: [
          json_content:
            ^%{
              "version" => version,
              "contents" => contents,
              "inverted_changes" => inverted_changes
            }
        ]
      ]
    )
    |> Repo.update_all([])
  end

  @doc """
  Deletes a article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article changes.

  ## Examples

      iex> change_article(article)
      %Ecto.Changeset{data: %Article{}}

  """
  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end

  def update_content(%Content{} = content, attrs) do
    content
    |> Content.changeset(attrs)
    |> Repo.update()
  end
end
