defmodule Cimbirodalom.Articles.RegistryTest do
  # https://hexdocs.pm/ecto_sql/3.10.0/Ecto.Adapters.SQL.Sandbox.html#module-allowances
  use Cimbirodalom.DataCase, async: true

  # alias Ecto.Adapters.SQL.Sandbox
  alias Cimbirodalom.Articles.Registry
  import Cimbirodalom.ArticlesFixtures


  describe "Registry" do
    test "returns error is pid does not exist" do
      article = article_fixture_with_content()

      {:ok, registry_pid} = Registry.start_link([])
      assert Registry.find(registry_pid, article.content.id) == :error
    end

    test "returns pid if exists" do
      article = article_fixture_with_content()

      {:ok, registry_pid} = Registry.start_link([])
      {:ok, delta} = Registry.create(registry_pid, [content_id: article.content.id, delay_initialization: true])
      assert Registry.find(registry_pid, article.content.id) == {:ok, delta}
    end

    test "a single delta process is created for a given content_id" do
      article = article_fixture_with_content()

      {:ok, registry_pid} = Registry.start_link([])
      {:ok, delta} = Registry.create(registry_pid, [content_id: article.content.id, delay_initialization: true])
      assert Registry.find(registry_pid, article.content.id) == {:ok, delta}

      {:ok, delta2} = Registry.create(registry_pid, [content_id: article.content.id, delay_initialization: true])
      assert delta == delta2
    end

    test "delta process removed from registry if it stops" do
      article = article_fixture_with_content()

      {:ok, registry_pid} = Registry.start_link([])
      {:ok, delta} = Registry.create(registry_pid, [content_id: article.content.id, delay_initialization: true])
      assert Registry.find(registry_pid, article.content.id) == {:ok, delta}

      GenServer.stop(delta)
      assert Registry.find(registry_pid, article.content.id) == :error
    end

    test "delta process crash does not crash the registry" do
      article = article_fixture_with_content()

      {:ok, registry_pid} = Registry.start_link([])
      {:ok, delta} = Registry.create(registry_pid, [content_id: article.content.id, delay_initialization: true])
      assert Registry.find(registry_pid, article.content.id) == {:ok, delta}

      GenServer.stop(delta, :shutdown)
      assert Registry.find(registry_pid, article.content.id) == :error
    end
  end
end
