defmodule Cimbirodalom.AuthorsTest do
  use Cimbirodalom.DataCase

  alias Cimbirodalom.Authors

  describe "authors" do
    alias Cimbirodalom.Authors.Author

    import Cimbirodalom.AuthorsFixtures

    @invalid_attrs %{name: nil, description: nil, slug: nil, img_path: nil}

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Authors.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Authors.get_author!(author.id) == author
    end

    test "create_author/1 with valid data creates a author" do
      valid_attrs = %{name: "some name", description: "some description", img_path: "some img_path"}

      assert {:ok, %Author{} = author} = Authors.create_author(valid_attrs)
      assert author.name == "some name"
      assert author.description == "some description"
      assert author.slug == "some-name"
      assert author.img_path == "some img_path"
    end

    test "create_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Authors.create_author(@invalid_attrs)
    end

    test "update_author/2 with valid data updates the author" do
      author = author_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", img_path: "some updated img_path"}

      assert {:ok, %Author{} = author} = Authors.update_author(author, update_attrs)
      assert author.name == "some updated name"
      assert author.description == "some updated description"
      assert author.slug == "some-updated-name"
      assert author.img_path == "some updated img_path"
    end

    test "update_author/2 with invalid data returns error changeset" do
      author = author_fixture()
      assert {:error, %Ecto.Changeset{}} = Authors.update_author(author, @invalid_attrs)
      assert author == Authors.get_author!(author.id)
    end

    test "delete_author/1 deletes the author" do
      author = author_fixture()
      assert {:ok, %Author{}} = Authors.delete_author(author)
      assert_raise Ecto.NoResultsError, fn -> Authors.get_author!(author.id) end
    end

    test "change_author/1 returns a author changeset" do
      author = author_fixture()
      assert %Ecto.Changeset{} = Authors.change_author(author)
    end
  end
end
