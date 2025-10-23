defmodule AppWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """

  use Phoenix.Component

  # Example HEEx function component
  attr :class, :string, default: ""
  slot :inner_block

  def container(assigns) do
    ~H"""
    <div class={["container", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
