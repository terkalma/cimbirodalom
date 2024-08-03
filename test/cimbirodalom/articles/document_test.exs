defmodule Cimbirodalom.Articles.DocumentTest do
  # https://hexdocs.pm/ecto_sql/3.10.0/Ecto.Adapters.SQL.Sandbox.html#module-allowances
  use Cimbirodalom.DataCase, async: false

  alias Cimbirodalom.Articles.Document
  import Cimbirodalom.ArticlesFixtures

  test "retrieves content state by id" do
    article = article_fixture_with_content()

    Document.init(article.content.id)

    assert Document.retrieve(article.content.id) == %{
             version: 0,
             contents: [],
             inverted_changes: []
           }
  end

  test "updates content state by id" do
    article =
      article_fixture_with_content(
        content: %{"json_content" => %{"contents" => [%{"insert" => "Hello!"}]}}
      )

    Document.init(article.content.id)
    state = Document.update(article.content.id, [%{"retain" => 7}, %{"insert" => "Hello World!"}])
    assert state.contents == [%{"insert" => "Hello!"}, %{"retain" => 1}, %{"insert" => "Hello World!"}]
  end
end
