defmodule DashboardWeb.PluginStaticPlug do
  import Plug.Conn
  alias Dashboard.PluginRegistry

  def init(opts), do: opts

  #def call(%Plug.Conn{request_path: path} = conn, _opts) do
  #  IO.inspect(path, label: "REQUEST")
  #  conn
    #conn
    #|> put_resp_header("cache-control", "max-age=3600")
    #|> send_file(200, "C:/Users/Razorz/Desktop/HomeAutomatonKit/app/HomeKit/plugins/backup_plugin/assets/js/app.js")
    #|> halt()
    # Match /plugins/:plugin/assets/<rest>
    #case Regex.run(~r"^/plugins/([^/]+)/assets/(.+)$", path) do
    #  [_, plugin_name_str, file_path] ->
    #    plugin_name = String.to_atom(plugin_name_str)
    #    case PluginRegistry.get(plugin_name) do
    #      %{static_path: static_path} when is_binary(static_path) ->
    #        full_file_path = Path.join(static_path, file_path)
    #
    #        if File.exists?(full_file_path) do
    #          conn
    #          |> put_resp_header("cache-control", "max-age=3600")
    #          |> send_file(200, "C:/Users/Razorz/Desktop/HomeAutomatonKit/app/HomeKit/plugins/backup_plugin/assets/js/app.js")
    #          |> halt()
    #        else
    #          conn
    #        end
    #
    #      _ -> conn
    #    end
    #  _ ->
    #    conn
    #end
  #end
end
