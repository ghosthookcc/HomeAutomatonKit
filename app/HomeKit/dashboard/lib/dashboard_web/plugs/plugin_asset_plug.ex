defmodule DashboardWeb.PluginAssetPlug do
  import Plug.Conn

  @behaviour Plug

  # Base directory for plugin assets
  @plugin_dir Path.join(File.cwd!, "../plugins/")
  @relative_plugin_assets_dir "/priv/static/assets/"

  def init(opts), do: opts

  def call(%Plug.Conn{path_params: %{"plugin" => plugin, "path" => path}} = conn, _opts) do
    IO.inspect(plugin, label: "plugin")
    IO.inspect(path, label: "path")
    IO.inspect(@plugin_dir, label: "plugins_path")

    asset_path = Path.join([@plugin_dir, plugin, @relative_plugin_assets_dir, Path.join(path)])
    IO.inspect(asset_path, label: "asset_path")

    if File.exists?(asset_path) do
      content_type = mime_type(asset_path)
      IO.inspect(content_type, label: "content_type")

      conn
      |> put_resp_content_type(content_type)
      |> send_file(200, asset_path)
      |> halt()
    else
      send_resp(conn, 404, "[-] Plugin asset not found . . .")
    end
  end

  # Determine MIME type based on file extension
  defp mime_type(asset_path) do
    case Path.extname(asset_path) do
      ".css" -> "text/css"
      ".js" -> "application/javascript"
      ".json" -> "application/json"
      ".svg" -> "image/svg+xml"
      ".png" -> "image/png"
      ".jpg" -> "image/jpeg"
      ".jpeg" -> "image/jpeg"
      _ -> "application/octet-stream"
    end
  end
end
