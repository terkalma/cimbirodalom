defmodule Cimbirodalom.Articles.DeltaTest do
  # https://hexdocs.pm/ecto_sql/3.10.0/Ecto.Adapters.SQL.Sandbox.html#module-allowances
  use Cimbirodalom.DataCase, async: true

  alias Ecto.Adapters.SQL.Sandbox
  alias Cimbirodalom.Articles.Delta
  import Cimbirodalom.ArticlesFixtures

  describe "reset" do
    test "initializes state event if there's no data in the db" do
      article = article_fixture_with_content()

      pid =
        start_link_supervised!(
          {Delta, [content_id: article.content.id, delay_initialization: true]}
        )

      Sandbox.allow(Repo, self(), pid)

      assert Delta.reset(pid) == :ok
      assert Delta.retrieve(pid) == %{version: 0, contents: [], inverted_changes: []}
    end

    test "initializes state event with contents alone" do
      article =
        article_fixture_with_content(
          content: %{
            json_content: %{
              "contents" => [
                %{"insert" => "Hello World!"}
              ]
            }
          }
        )

      pid =
        start_link_supervised!(
          {Delta, [content_id: article.content.id, delay_initialization: true]}
        )

      Sandbox.allow(Repo, self(), pid)

      assert Delta.reset(pid) == :ok

      assert Delta.retrieve(pid) == %{
               version: 1,
               contents: [%{"insert" => "Hello World!"}],
               inverted_changes: []
             }
    end

    test "initializes state with custom version" do
      article =
        article_fixture_with_content(
          content: %{
            json_content: %{
              "version" => 10,
              "contents" => [
                %{"insert" => "Hello World!"}
              ],
              "inverted_changes" => []
            }
          }
        )

      pid =
        start_link_supervised!(
          {Delta, [content_id: article.content.id, delay_initialization: true]}
        )

      Sandbox.allow(Repo, self(), pid)

      assert Delta.reset(pid) == :ok

      assert Delta.retrieve(pid) == %{
               version: 10,
               contents: [%{"insert" => "Hello World!"}],
               inverted_changes: []
             }
    end
  end

  test "update/1 updates the state with new operations" do
    article =
      article_fixture_with_content(
        content: %{
          json_content: %{
            "contents" => [
              %{"insert" => "Hello World!"}
            ]
          }
        }
      )

    pid =
      start_link_supervised!(
        {Delta, [content_id: article.content.id, delay_initialization: true]}
      )

    Sandbox.allow(Repo, self(), pid)

    assert Delta.reset(pid) == :ok

    state = Delta.update(pid, [%{"retain" => 13}, %{"insert" => "Hiiii!"}])

    assert state.contents == [
             %{"insert" => "Hello World!"},
             %{"retain" => 1},
             %{"insert" => "Hiiii!"}
           ]
    assert state.version == 2


    assert %{version: 2, inverted_changes: [[%{"retain" => 13}, %{"delete" => 6}]]} =
             Delta.retrieve(pid)
  end
end
