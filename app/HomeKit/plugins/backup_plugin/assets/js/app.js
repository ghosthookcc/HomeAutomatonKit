// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"
// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";

import topbar from "../vendor/topbar";
import MishkaComponents from "../vendor/mishka_components.js";
import DropzoneHooks from "./hooks/dropzone.js";

const Hooks = {
  Dropzone: DropzoneHooks.Dropzone,
  DropzoneZipped: DropzoneHooks.DropzoneZipped,
  ...DropzoneHooks,
  ...MishkaComponents,
};

const register = () => 
{
    if (window.registerPluginHooks) 
    {
        window.registerPluginHooks(Hooks);
        console.log("[+][Backup Plugin] Hooks registered successfully . . .");
    }
    else 
    {
        console.warn("[/][Backup Plugin] Not ready yet, retrying...");
        setTimeout(register, 300);
    }
};

document.addEventListener("DOMContentLoaded", () => {
  /*
  let csrfToken = document
    .querySelector("meta[name='csrf-token']")
    .getAttribute("content");
  let liveSocket = new LiveSocket("/live", Socket, {
    longPollFallbackMs: 2500,
    params: {
      _csrf_token: csrfToken,
    },
    hooks: {
      ...Hooks,
      ...MishkaComponents,
    },
    dom: {
      onBeforeElUpdated(from, to) {
        if (from.id === "file-dropzone") {
          return false;
        }
      },
    },
  });
  liveSocket.connect();
  liveSocket.enableDebug();
  window.liveSocket = liveSocket;
  */
    register();
});
topbar.config({
  barColors: {
    0: "#29d",
  },
  shadowColor: "rgba(0, 0, 0, .3)",
});
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide()); // connect if there are any LiveViews on the page

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
