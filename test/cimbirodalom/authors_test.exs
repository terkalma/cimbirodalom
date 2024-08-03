defmodule Cimbirodalom.AuthorsTest do
  use Cimbirodalom.DataCase
  import Cimbirodalom.AuthorsFixtures

  alias Vix.Vips.Image, as: VixImage
  alias Cimbirodalom.Authors
  alias Cimbirodalom.Authors.Author
  alias Cimbirodalom.Authors.Image

  describe "authors" do
    @invalid_attrs %{name: nil, description: nil, slug: nil}

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Authors.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Authors.get_author!(author.id) == author
    end

    test "create_author/1 with valid data creates a author" do
      valid_attrs = %{
        name: "some name",
        description: "some description",
      }

      assert {:ok, %Author{} = author} = Authors.create_author(valid_attrs)
      assert author.name == "some name"
      assert author.description == "some description"
      assert author.slug == "some-name"
    end

    test "create_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Authors.create_author(@invalid_attrs)
    end

    test "update_author/2 with valid data updates the author" do
      author = author_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
      }

      assert {:ok, %Author{} = author} = Authors.update_author(author, update_attrs)
      assert author.name == "some updated name"
      assert author.description == "some updated description"
      assert author.slug == "some-updated-name"
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

  describe "images" do
    alias Cimbirodalom.Authors.Author
    import Cimbirodalom.AuthorsFixtures

    @change_author_cases %{
      "correct image_data is mapped to crop_info": {
        Jason.encode!(%{"x1" => 0.1, "x2" => 1.0, "y1" => 0.2, "y2" => 0.88}),
        %{x1: 0.1, x2: 1.0, y1: 0.2, y2: 0.88}
      },
      "missing key from image_data => uses the default range": {
        Jason.encode!(%{"x1" => 0.1, "x2" => 1.0, "y1" => 0.2}),
        %{x1: 0, x2: 1, y1: 0, y2: 1}
      },
      "invalid range 1 => uses the default range": {
        Jason.encode!(%{"x1" => -1, "x2" => 0, "y1" => 0, "y2" => 100}),
        %{x1: 0, x2: 1, y1: 0, y2: 1}
      },
      "invalid range 2 => uses the default range": {
        Jason.encode!(%{"x1" => 10, "x2" => 100, "y1" => 0, "y2" => 120}),
        %{x1: 0, x2: 1, y1: 0, y2: 1}
      },
      "invalid order 1 => uses the default range": {
        Jason.encode!(%{"x1" => 0.9, "x2" => 0.1, "y1" => 0, "y2" => 0.5}),
        %{x1: 0, x2: 1, y1: 0, y2: 1}
      },
      "invalid order 2 => uses the default range": {
        Jason.encode!(%{"x1" => 0.1, "x2" => 0.9, "y1" => 0.9, "y2" => 0.5}),
        %{x1: 0, x2: 1, y1: 0, y2: 1}
      },
      "invalid json => uses the default range": {
        "invalid json",
        %{x1: 0, x2: 1, y1: 0, y2: 1}
      },
      "missing key => uses the default range": {
        nil,
        %{x1: 0, x2: 1, y1: 0, y2: 1}
      }
    }

    for {description, _} <- @change_author_cases do
      @current_test_case description
      test "parse_crop_info/1 with #{@current_test_case}" do
        {update_params, expected_crop_info} = @change_author_cases[@current_test_case]
        assert Image.parse_crop_info(update_params) == expected_crop_info
      end
    end
  end

  test "get_cropping_area/2 returns the cropping area" do
    {:ok, img} = VixImage.new_from_file("test/support/fixtures/test_author.png")
    assert VixImage.width(img) == 2096
    assert VixImage.height(img) == 1280

    # A 524x524 square from the top left corner
    crop_info = %{x1: 0, x2: 0.25, y1: 0, y2: 0.409375}
    assert Image.get_cropping_area(img, crop_info) == {0, 0, 524, 2096, 1280}

    # A 524x524 square from the inner part of the image
    crop_info = %{x1: 0.25, x2: 0.50, y1: 0.20, y2: 0.609375}
    assert Image.get_cropping_area(img, crop_info) == {524, 256, 524, 2096, 1280}

    # with the default config, a square will be cropped using the shorter side
    crop_info = %{x1: 0, x2: 1, y1: 0, y2: 1}
    assert Image.get_cropping_area(img, crop_info) == {0, 0, 1280, 2096, 1280}
  end

  test "generate_images_and_save_them_locally/4 generates image versions" do
    author = author_fixture()
    {:ok, img} = VixImage.new_from_file("test/support/fixtures/test_author.png")
    image_config = Image.new(uploaded_entries: [{"test/support/fixtures/test_author.png", "image/png"}])
    current_ts = DateTime.to_unix(image_config.timestamp) |> to_string()

    {:ok, image_paths} =
      Authors.generate_paths_and_images(author, img, image_config)

    {local_base, remote_base} = image_paths.base
    {local_thumb, remote_thumb} = image_paths.thumb
    {local_medium, remote_medium} = image_paths.medium
    {local_large, remote_large} = image_paths.large
    {local_original, remote_original} = image_paths.original

    assert remote_base == "images/authors/#{author.slug}/1/#{current_ts}/base.png"
    assert remote_thumb == "images/authors/#{author.slug}/1/#{current_ts}/thumb.png"
    assert remote_medium == "images/authors/#{author.slug}/1/#{current_ts}/medium.png"
    assert remote_large == "images/authors/#{author.slug}/1/#{current_ts}/large.png"
    assert remote_original == "images/authors/#{author.slug}/1/#{current_ts}/original.png"

    {:ok, base} = VixImage.new_from_file(local_base)
    {:ok, thumb} = VixImage.new_from_file(local_thumb)
    {:ok, medium} = VixImage.new_from_file(local_medium)
    {:ok, large} = VixImage.new_from_file(local_large)
    {:ok, original} = VixImage.new_from_file(local_original)

    assert VixImage.width(base) == 1280
    assert VixImage.height(base) == 1280

    assert VixImage.width(thumb) == 100
    assert VixImage.height(thumb) == 100

    assert VixImage.width(medium) == 500
    assert VixImage.height(medium) == 500

    assert VixImage.width(large) == 1200
    assert VixImage.height(large) == 1200

    assert VixImage.width(original) == 2096
    assert VixImage.height(original) == 1280
  end

  test "process_images/3 test could not load image" do
    author = author_fixture()
    {:error, changeset} = Authors.process_images(author, Image.new(uploaded_entries: [{"bad_path", "image/bmp"}]))
    assert changeset.errors[:avatar] == {"Unable to save image!", []}
  end

  # test "upload_images/2 should upload image to S3" do
  #   image_paths = %{
  #     base: {"test/support/fixtures/test_author.png", "test/test_author.png"},
  #   }
  #   author = author_fixture()

  #   assert Authors.upload_images(author.id, image_paths) == {:upload_task, author.id, %{base: "test/test_author.png", version: 1}}
  # end

  test "lock_for_asset_update/1 locks  Lock" do
    author = author_fixture()

    {success1, ts1} = Authors.lock_for_asset_update(author.id, 10)
    {success2, ts2} = Authors.lock_for_asset_update(author.id, 10)

    assert ts1 != nil
    assert success1 == true
    assert success2 == false
    assert ts2 == nil
  end

  test "image utils" do
    author = author_fixture()
    image_data = %{
      original: "#{author.slug}/1/1234567890/original.jpeg",
      version: 1
    }

    Authors.update_author(author, %{img_data: image_data})
    author = Authors.get_author!(author.id)
    assert Authors.image_url(author, "original") == "https://d2r6hb3ca6lz0f.cloudfront.net/#{author.slug}/1/1234567890/original.jpeg"
  end
end
