defmodule Cimbirodalom.Authors do
  @moduledoc """
  The Authors context.
  """

  import Ecto.Query, warn: false
  alias Cimbirodalom.Authors
  alias ExAws.S3
  alias Cimbirodalom.Repo
  alias Vix.Vips.Image, as: VixImage
  alias Vix.Vips.Operation, as: VixOperation
  alias Cimbirodalom.Authors.Author
  alias Cimbirodalom.Authors.Image
  alias CimbirodalomWeb.ImageUtils

  require Logger

  @image_version 1
  @image_sizes %{
    thumb: 100,
    medium: 500,
    large: 1200
  }


  defmodule ImageUpload do
    defstruct [:tmp_img_path, :client_type, ]
  end

  @doc """
  Returns the list of authors.

  ## Examples

      iex> list_authors()
      [%Author{}, ...]

  """
  def list_authors do
    Repo.all(Author)
  end

  @doc """
  Gets a single author.

  Raises `Ecto.NoResultsError` if the Author does not exist.

  ## Examples

      iex> get_author!(123)
      %Author{}

      iex> get_author!(456)
      ** (Ecto.NoResultsError)

  """
  def get_author!(id), do: Repo.get!(Author, id)

  @doc """
  Creates a author.

  ## Examples

      iex> create_author(%{field: value})
      {:ok, %Author{}}

      iex> create_author(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a author.

  ## Examples

      iex> update_author(author, %{field: new_value})
      {:ok, %Author{}}

      iex> update_author(author, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_author(%Author{} = author, attrs) do
    author
    |> Author.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a author.

  ## Examples

      iex> delete_author(author)
      {:ok, %Author{}}

      iex> delete_author(author)
      {:error, %Ecto.Changeset{}}

  """
  def delete_author(%Author{} = author) do
    Repo.delete(author)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking author changes.

  ## Examples

      iex> change_author(author)
      %Ecto.Changeset{data: %Author{}}

  """
  def change_author(%Author{} = author, attrs \\ %{}) do
    Author.changeset(author, attrs)
  end

  def process_images(_author, %Image{should_process: false}), do: {:ok, %{}}

  def process_images(author, %Image{should_process: true} = image_config) do
    case VixImage.new_from_file(image_config.tmp_img_path) do
      {:ok, img} ->
        generate_paths_and_images(author, img, image_config)

      {:error, error} ->
        Logger.error("Error loading Image: #{Kernel.inspect(error)}!")

        {:error,
         change_author(author, %{}) |> Ecto.Changeset.add_error(:avatar, "Unable to save image!")}
    end
  end

  def generate_paths_and_images(%Author{} = author, img, %Image{} = image_config) do
    {x, y, length, width, height} = Image.get_cropping_area(img, image_config.crop_data)

    images = generate_images(img, x, y, length, width, height)

    current_image_key =
      image_config.timestamp |> DateTime.to_unix() |> to_string() |> generate_current_image_key()

    remote_paths =
      Enum.reduce(images, %{}, fn {image_type, _}, remote_paths ->
        Map.put(
          remote_paths,
          image_type,
          "#{ImageUtils.author_prefix()}/#{author.slug}/#{current_image_key}/#{image_type}.#{image_config.extension}"
        )
      end)

    tmp_dir = System.tmp_dir!()

    all_paths =
      Enum.reduce(images, %{}, fn {image_type, _}, paths ->
        remote_path = remote_paths[image_type]
        local_path = Path.join(tmp_dir, String.replace(remote_path, "/", "_"))
        VixImage.write_to_file(images[image_type], local_path)
        Map.put(paths, image_type, {local_path, remote_path})
      end)

    {:ok, all_paths}
  end

  defp generate_images(img, x, y, length, width, height)
       when length <= width - x and length <= height - y and x >= 0 and y >= 0 do
    case VixOperation.extract_area(img, x, y, length, length) do
      {:ok, base} ->
        Enum.reduce(@image_sizes, %{base: base, original: img}, fn {image_type, size}, images ->
          case VixOperation.resize(base, size / length) do
            {:ok, resized} ->
              Map.put(images, image_type, resized)

            {:error, _} ->
              images
          end
        end)

      {:error, _} ->
        %{original: img}
    end
  end

  defp generate_images(img, x, y, length, width, height) do
    Logger.error(
      "Unable to crop image! x=#{x}, y=#{y}, length=#{length}, width=#{width}, height=#{height}"
    )

    %{original: img}
  end

  def generate_current_image_key(current_ts) do
    "#{@image_version}/#{current_ts}"
  end

  def upload_images(author_id, image_paths) do
    uploaded_paths =
      Enum.reduce(image_paths, %{version: @image_version}, fn {image_type,
                                                               {local_path, remote_path}},
                                                              uploaded_paths ->
        case S3.put_object(
               "cimbadmin-production",
               remote_path,
               File.read!(local_path),
               content_type: MIME.from_path(local_path)
             )
             |> ExAws.request() do
          {:ok, _} ->
            Map.put(uploaded_paths, image_type, remote_path)

          {:error, _} ->
            uploaded_paths
        end
      end)

    {:upload_task, author_id, uploaded_paths}
  end

  def lock_for_asset_update(author_id, duration \\ 20) do
    result =
      from(
        a in Author,
        where:
          a.id == ^author_id and
            (is_nil(a.locked_for_asset_update_at) or
               fragment("EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - locked_for_asset_update_at))") >
                 ^duration),
        update: [set: [locked_for_asset_update_at: fragment("CURRENT_TIMESTAMP")]],
        select: [:locked_for_asset_update_at]
      )
      |> Repo.update_all([])

    case result do
      {0, []} ->
        {false, nil}

      {1, [%{locked_for_asset_update_at: locked_for_asset_update_at}]} ->
        {true, locked_for_asset_update_at}
    end
  end

  def reset_asset_lock(author_id, image_paths, ts) do
    result =
      from(
        a in Author,
        where: a.id == ^author_id and a.locked_for_asset_update_at == ^ts,
        update: [set: [img_data: ^image_paths, locked_for_asset_update_at: nil]]
      )
      |> Repo.update_all([])

    author = Authors.get_author!(author_id)

    case result do
      {1, _} ->
        {:ok, author}

      _ ->
        {:error, author}
    end
  end
end
