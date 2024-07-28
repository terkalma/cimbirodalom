defmodule Cimbirodalom.Authors.Image do
  alias Vix.Vips.Image, as: VixImage

  defstruct [
    :tmp_img_path,
    :client_type,
    :timestamp,
    :crop_data,
    :should_process,
    extension: "jpg"
  ]

  def new(uploaded_entries: uploaded_entries) do
    new(crop_info: nil, uploaded_entries: uploaded_entries)
  end

  def new(crop_info: _, uploaded_entries: []) do
    %__MODULE__{
      should_process: false
    }
  end

  def new(crop_info: crop_info, uploaded_entries: [{path, client_type} | _]) do
    %__MODULE__{
      crop_data: parse_crop_info(crop_info),
      extension: parse_extension(path, client_type),
      timestamp: DateTime.utc_now(),
      tmp_img_path: path,
      should_process: true
    }
  end

  def default_image_crop_info, do: %{x1: 0, x2: 1, y1: 0, y2: 1}
  def image_version, do: 1

  def parse_crop_info(nil), do: default_image_crop_info()

  def parse_crop_info(raw_crop_info) do
    case Jason.decode(raw_crop_info) do
      {:ok, %{"x1" => x1, "y1" => y1, "x2" => x2, "y2" => y2}}
      when x1 >= 0 and x1 <= 1 and
             x2 >= 0 and x2 <= 1 and
             y1 >= 0 and y1 <= 1 and
             y2 >= 0 and y2 <= 1 and
             x1 < x2 and y1 < y2 ->
        %{x1: x1, y1: y1, x2: x2, y2: y2}

      {:ok, _} ->
        default_image_crop_info()

      _ ->
        default_image_crop_info()
    end
  end

  def get_cropping_area(img, %{x1: x1, x2: x2, y1: y1, y2: y2}) do
    {width, height} = {VixImage.width(img), VixImage.height(img)}

    left = trunc(width * x1)
    top = trunc(height * y1)
    length_x = trunc(width * (x2 - x1))
    legnth_y = trunc(height * (y2 - y1))

    # Author images should be square, so we return the shorter value
    {left, top, min(length_x, legnth_y), width, height}
  end

  def parse_extension(tmp_img_path, client_type) do
    case MIME.extensions(client_type) do
      [ext | _] -> ext
      _ -> MIME.from_path(tmp_img_path) |> MIME.extensions() |> hd()
    end
  end
end
