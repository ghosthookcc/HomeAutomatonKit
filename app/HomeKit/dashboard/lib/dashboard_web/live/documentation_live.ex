defmodule DashboardWeb.DocumentationLive do
  use DashboardWeb, :live_view

  alias Dashboard.Docs

  def mount(_params, _session, socket) do
    docs = Docs.load_docs()
         |> Enum.flat_map(fn
              %{sections: sections} -> sections
              doc -> [doc] end)

    {:ok,
     socket
     |> assign(:docs, docs)
     |> assign(:filtered_docs, docs)
     |> assign(:query, "")}
  end

  def handle_event("search", %{"query" => query}, socket) do
    docs =
      socket.assigns.docs
      |> Enum.filter(fn doc ->
        String.contains?(
          String.downcase(doc["title"]),
          String.downcase(query)
        )
      end)

    {:noreply,
     socket
     |> assign(:filtered_docs, docs)
     |> assign(:query, query)}
  end
end
