defmodule AppWeb.Index do
  # https://fly.io/phoenix-files/phoenix-liveview-zipped-uploads/
  use AppWeb, :live_view

  alias AppWeb.Components.Table, as: Mishka

  @upload_dir Path.expand("priv/static/uploads")

  def mount(_params, _session, socket) do
    File.mkdir_p!(@upload_dir)

    {:ok,
      socket
      |> assign(:status, nil)
      |> assign(:uploaded_entries, [])
      |> allow_upload(:uploader, 
                      max_entries: 10000, 
                      max_file_size: 50_000_000,
                      auto_upload: false, 
                      accept: :any)}
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
        IO.inspect(meta)
        IO.inspect(entry)

        destination = Path.join([@upload_dir, entry.client_relative_path || entry.client_name])

        File.mkdir_p!(Path.dirname(destination))
        File.cp!(meta.path, destination)

        {:ok, ~p"/uploads/#{Path.basename(destination)}"}
      end)
    {:noreply, 
      socket 
      |> update(:uploaded_entries, &(&1 ++ uploaded_entries))}
  end

  #def handle_progress(:uploader, entry, socket) do 
  #  if entry.done? do
  #    File.mkdir_p!(@upload_dir)
  #
  #    [{destination, _paths}] = 
  #       consume_uploaded_entries(socket, :uploader, fn %{path: path}, _entry ->
  #        {:ok, [{:zip_comment, []}, {:zip_file, first, _, _, _, _} | _]} = :zip.list_dir(~c"#{path}")
  #
  #          destination_path = Path.join(@upload_dir, Path.basename(to_string(first)))
  #        {:ok, paths} = :zip.unzip(~c"#{path}", cwd: ~c"#{@upload_dir}")
  #        {:ok, {destination_path, paths}}
  #      end)
  #    {:noreply, assign(socket, status: "[+] \"#{Path.basename(destination)}\" uploaded . . .")}
  #  else
  #    {:noreply, assign(socket, status: "[/] Uploading . . .")}
  #  end
  #end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
