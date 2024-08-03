defmodule Cimbirodalom.Articles.Document do
  alias Cimbirodalom.Articles.Registry
  alias Cimbirodalom.Articles.Delta

  def init(content_id) do
    Registry.create(Registry, [content_id: content_id])
  end

  def retrieve(content_id) do
    case init(content_id) do
      {:ok, pid} -> Delta.retrieve(pid)
      other -> other
    end
  end

  def update(content_id, change) do
    case init(content_id) do
      {:ok, pid} -> Delta.update(pid, change)
      other -> other
    end
  end
end
