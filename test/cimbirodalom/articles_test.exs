defmodule Cimbirodalom.ArticlesTest do
  use Cimbirodalom.DataCase

  alias Cimbirodalom.Articles

  describe "articles" do
    alias Cimbirodalom.Articles.Article

    import Cimbirodalom.ArticlesFixtures

    @invalid_attrs %{title: nil, slug: nil, subtitle: nil}

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      assert Articles.list_articles() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert Articles.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      valid_attrs = %{title: "some title", slug: "some slug", subtitle: "some subtitle"}

      assert {:ok, %Article{} = article} = Articles.create_article(valid_attrs)
      assert article.title == "some title"
      assert article.slug == "some slug"
      assert article.subtitle == "some subtitle"
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Articles.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()
      update_attrs = %{title: "some updated title", slug: "some updated slug", subtitle: "some updated subtitle"}

      assert {:ok, %Article{} = article} = Articles.update_article(article, update_attrs)
      assert article.title == "some updated title"
      assert article.slug == "some updated slug"
      assert article.subtitle == "some updated subtitle"
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = Articles.update_article(article, @invalid_attrs)
      assert article == Articles.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = Articles.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Articles.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = Articles.change_article(article)
    end
  end
end
