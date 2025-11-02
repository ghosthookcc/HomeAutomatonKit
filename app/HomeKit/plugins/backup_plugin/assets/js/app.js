import "phoenix_html";

import topbar from "../vendor/topbar";
import MishkaComponents from "../vendor/mishka_components.js";
import DropzoneHooks from "./hooks/dropzone.js";

const hooks = {
  Dropzone: DropzoneHooks.Dropzone,
  DropzoneZipped: DropzoneHooks.DropzoneZipped,
  ...DropzoneHooks,
  ...MishkaComponents,
};

topbar.config({
  barColors: {
    0: "#29d",
  },
  shadowColor: "rgba(0, 0, 0, .3)",
});

window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide()); // connect if there are any LiveViews on the page

export { hooks };
