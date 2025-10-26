# Inspiration: https://fly.io/phoenix-files/phoenix-liveview-zipped-uploads/
defmodule BackupPluginWeb.Index do
  use Phoenix.LiveView

  alias BackupPluginWeb.Components.Table, as: Mishka

  @upload_dir Path.expand("priv/static/uploads/mount")

  def mount(_params, _session, socket) do
    File.mkdir_p!(@upload_dir)

    {:ok,
      socket
      |> assign(:status, "Idle")
      |> assign(:uploaded_entries, [])
      |> allow_upload(:uploader, 
                      max_entries: 10000, 
                      max_file_size: 50_000_000,
                      auto_upload: false, 
                      accept: :any)}
  end

  def handle_event("run_backup", _value, socket) do
    Task.start(fn -> BackupPlugin.Worker.perform_backup() end)
    {:noreply, assign(socket, status: "Running")}
  end

  def handle_event("validate", _params, socket) do 
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :uploader, ref)}
  end

  def handle_event("save", _params, socket) do
    uploaded_entries = 
      consume_uploaded_entries(socket, :uploader, fn meta, entry ->
        destination = Path.join([@upload_dir, entry.client_relative_path || entry.client_name])

        File.mkdir_p!(Path.dirname(destination))
        File.cp!(meta.path, destination)

        upload_path = "/uploads/#{Path.basename(destination)}"
        {:ok, upload_path}
      end)
    {:noreply, 
      socket 
      |> update(:uploaded_entries, &(&1 ++ uploaded_entries))}
  end 

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
