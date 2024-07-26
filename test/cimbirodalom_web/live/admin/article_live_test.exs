defmodule CimbirodalomWeb.Admin.ArticleLiveTest do
  use CimbirodalomWeb.ConnCase

  import Phoenix.LiveViewTest
  import Cimbirodalom.ArticlesFixtures
  import Cimbirodalom.AccountsFixtures

  @create_attrs %{title: "some title", slug: "some slug", subtitle: "some subtitle"}
  @update_attrs %{title: "some updated title", slug: "some updated slug", subtitle: "some updated subtitle"}
  @invalid_attrs %{title: nil, slug: nil, subtitle: nil}

  defp create_article(_) do
    article = article_fixture()
    %{article: article}
  end

  defp login_admin(%{conn: conn}) do
    password = valid_admin_password()
    admin = admin_fixture(%{password: password})
    %{conn: log_in_admin(conn, admin), admin: admin, password: password}
  end

  describe "Authorization" do
    setup [:create_article]

    test "redirects from index if admin is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/admin/articles")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admin/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "redirects from show if admin is not logged in", %{conn: conn, article: article} do
      assert {:error, redirect} = live(conn, ~p"/admin/articles/#{article}")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admin/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "redirects from new if admin is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/admin/articles/new")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admin/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "redirects from edit if admin is not logged in", %{conn: conn, article: article} do
      assert {:error, redirect} = live(conn, ~p"/admin/articles/#{article}/edit")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admin/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "Index" do
    setup [:create_article, :login_admin]

    test "lists all articles", %{conn: conn, article: article} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/articles")

      assert html =~ "Listing Articles"
      assert html =~ article.title
    end

    test "saves new article", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/articles")

      assert index_live |> element("a", "New Article") |> render_click() =~
               "New Article"

      assert_patch(index_live, ~p"/admin/articles/new")

      assert index_live
             |> form("#article-form", article: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#article-form", article: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/articles")

      html = render(index_live)
      assert html =~ "Article created successfully"
      assert html =~ "some title"
    end

    test "updates article in listing", %{conn: conn, article: article} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/articles")

      assert index_live |> element("#articles-#{article.id} a", "Edit") |> render_click() =~
               "Edit Article"

      assert_patch(index_live, ~p"/admin/articles/#{article}/edit")

      assert index_live
             |> form("#article-form", article: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#article-form", article: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/articles")

      html = render(index_live)
      assert html =~ "Article updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes article in listing", %{conn: conn, article: article} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/articles")

      assert index_live |> element("#articles-#{article.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#articles-#{article.id}")
    end
  end

  describe "Show" do
    setup [:create_article, :login_admin]

    test "displays article", %{conn: conn, article: article} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/articles/#{article}")

      assert html =~ "Show Article"
      assert html =~ article.title
    end

    test "updates article within modal", %{conn: conn, article: article} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/articles/#{article}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Article"

      assert_patch(show_live, ~p"/admin/articles/#{article}/show/edit")

      assert show_live
             |> form("#article-form", article: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#article-form", article: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/articles/#{article}")

      html = render(show_live)
      assert html =~ "Article updated successfully"
      assert html =~ "some updated title"
    end
  end
end
