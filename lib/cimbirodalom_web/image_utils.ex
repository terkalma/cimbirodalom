defmodule CimbirodalomWeb.ImageUtils do
  alias Cimbirodalom.Authors.Author

  def cloudfront_url() do
    "https://d2r6hb3ca6lz0f.cloudfront.net"
  end

  def author_prefix() do
    "images/authors"
  end

  def fallbacks() do
    %{
      "thumb" => ["medium", "large", "base"],
      "medium" => ["large", "thumb", "base"],
      "large" => ["medium", "base", "thumb"],
      "base" => [],
    }
  end

  def image_url(%Author{img_data: %{} = image_data}, "original") do
    "#{cloudfront_url()}/#{Map.get(image_data, "original")}"
  end

  def image_url(%Author{img_data: %{} = image_data}, image_type) when image_type in ["thumb", "medium", "large", "base"] do
    if Map.get(image_data, image_type) do
      "#{cloudfront_url()}/#{Map.get(image_data, image_type)}"
    else
      case Enum.find(fallbacks()[image_type], :original, fn fallback ->
        Map.get(image_data, fallback)
      end) do
        nil -> "#{cloudfront_url()}/#{Map.get(image_data, :original)}"
        fallback_image -> "#{cloudfront_url()}/#{fallback_image}"
      end
    end
  end

  def image_url(%Author{}, image_type) when image_type in ["thumb", "medium", "large", "base"] do
    nil
  end
end
