defmodule CimbirodalomWeb.Admin.AuthorLiveTest do
  use CimbirodalomWeb.ConnCase

  import Phoenix.LiveViewTest
  import Cimbirodalom.AuthorsFixtures
  import Cimbirodalom.AccountsFixtures

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}

  defp create_author(_) do
    author = author_fixture()
    %{author: author}
  end

  defp login_admin(%{conn: conn}) do
    password = valid_admin_password()
    admin = admin_fixture(%{password: password})
    %{conn: log_in_admin(conn, admin), admin: admin, password: password}
  end

  describe "Index" do
    setup [:login_admin, :create_author]

    test "lists all authors", %{conn: conn, author: author} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/authors")

      assert html =~ "Listing Authors"
      assert html =~ author.name
    end

    test "saves new author", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/authors")

      assert index_live |> element("a", "New Author") |> render_click() =~
               "New Author"

      assert_patch(index_live, ~p"/admin/authors/new")

      assert index_live
             |> form("#author-form", author: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#author-form", author: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/authors")

      html = render(index_live)
      assert html =~ "Author created successfully"
      assert html =~ "some name"
    end

    test "updates author in listing", %{conn: conn, author: author} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/authors")

      assert index_live |> element("#authors-#{author.id} a", "Edit") |> render_click() =~
               "Edit Author"

      assert_patch(index_live, ~p"/admin/authors/#{author}/edit")

      assert index_live
             |> form("#author-form", author: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#author-form", author: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/authors")

      html = render(index_live)
      assert html =~ "Author updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes author in listing", %{conn: conn, author: author} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/authors")

      assert index_live |> element("#authors-#{author.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#authors-#{author.id}")
    end
  end
end
