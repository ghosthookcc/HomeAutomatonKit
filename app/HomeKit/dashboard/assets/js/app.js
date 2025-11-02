// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

import {hooks as colocatedHooks} from "phoenix-colocated/dashboard"
import topbar from "../vendor/topbar"

import { hookRegistry } from "./hooks/hooks_registry.js";
import { loadPlugin } from "./hooks/plugin_loader.js";

const DefaultHooks = 
{
    ...colocatedHooks
}
for (const [name, definition] of Object.entries(DefaultHooks))
{
    hookRegistry.register(name, definition);
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, 
{
    longPollFallbackMs: 2500,
    params: {_csrf_token: csrfToken},
    hooks: hookRegistry.getHooks()
});

liveSocket.connect();
window.liveSocket = liveSocket;
window.hookRegistry = hookRegistry;
window.loadPlugin = loadPlugin;

document.addEventListener("DOMContentLoaded", async () => 
{
    await loadPlugin("backup_plugin");
});

topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => 
{
    topbar.hide();
    setTimeout(() => 
    {
        document.querySelectorAll("[phx-flash]").forEach((element) => element.remove());
    }, 4000);
});

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

