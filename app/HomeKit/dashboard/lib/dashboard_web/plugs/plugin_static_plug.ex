defmodule DashboardWeb.PluginStaticPlug do
  import Plug.Conn
  alias Dashboard.PluginRegistry

  def init(opts), do: opts

  def call(%Plug.Conn{request_path: path} = conn, _opts) do
    # Match /plugins/:plugin/assets/<rest>
    case Regex.run(~r"^/plugins/([^/]+)/assets/(.+)$", path) do
      [_, plugin_name_matched, file_path] ->
        plugin_atom = String.to_atom(plugin_name_matched)
        case PluginRegistry.get(plugin_atom) do
          %{static_path: static_path} when is_binary(static_path) ->
            full_file_path = Path.join(static_path, file_path)
            if File.exists?(full_file_path) do
              conn
              |> put_resp_header("cache-control", "max-age=3600")
              |> send_file(200, full_file_path)
              |> halt()
            else
              conn
            end
          _ -> conn
        end
      _ ->
        conn
    end
  end
end
