defmodule Dashboard.Docs do
  @moduledoc """
  Loads documentation from JSON files in priv/docs.
  """

  @docs_path Path.join(File.cwd!(), "/priv/docs")

  def load_docs do
    IO.inspect(@docs_path, label: "Docs Path")
    @docs_path
    |> File.ls!()
    |> Enum.filter(&String.ends_with?(&1, ".json"))
    |> Enum.map(&load_doc/1)
    |> Enum.sort_by(& &1["title"])
  end

  defp load_doc(file) do
    path = Path.join(@docs_path, file)

    with {:ok, body} <- File.read(path),
         {:ok, json} <- Jason.decode(body) do
      atomize_keys(json)
    end
  end

  defp atomize_keys(map) do
    for {k, v} <- map, into: %{} do
      {String.to_atom(k), v}
    end
  end
end
