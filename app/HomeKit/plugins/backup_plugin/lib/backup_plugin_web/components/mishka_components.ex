defmodule BackupPluginWeb.Components.MishkaComponents do
  defmacro __using__(_) do
    quote do
      import BackupPluginWeb.Components.Accordion, only: [accordion: 1]
      import BackupPluginWeb.Components.Alert, only: [flash: 1, flash_group: 1, alert: 1]
      import BackupPluginWeb.Components.Avatar, only: [avatar: 1, avatar_group: 1]
      import BackupPluginWeb.Components.Badge, only: [badge: 1]
      import BackupPluginWeb.Components.Banner, only: [banner: 1]
      import BackupPluginWeb.Components.Blockquote, only: [blockquote: 1]
      import BackupPluginWeb.Components.Breadcrumb, only: [breadcrumb: 1]

      import BackupPluginWeb.Components.Button,
        only: [button_group: 1, button: 1, input_button: 1, button_link: 1, back: 1]

      import BackupPluginWeb.Components.Card,
        only: [card: 1, card_title: 1, card_media: 1, card_content: 1, card_footer: 1]

      import BackupPluginWeb.Components.Carousel, only: [carousel: 1]
      import BackupPluginWeb.Components.Chat, only: [chat: 1, chat_section: 1]
      import BackupPluginWeb.Components.CheckboxCard, only: [checkbox_card: 1]

      import BackupPluginWeb.Components.CheckboxField,
        only: [checkbox_field: 1, group_checkbox: 1]

      import BackupPluginWeb.Components.Clipboard, only: [clipboard: 1]
      import BackupPluginWeb.Components.Collapse, only: [collapse: 1]
      import BackupPluginWeb.Components.ColorField, only: [color_field: 1]
      import BackupPluginWeb.Components.Combobox, only: [combobox: 1]
      import BackupPluginWeb.Components.DateTimeField, only: [date_time_field: 1]
      import BackupPluginWeb.Components.DeviceMockup, only: [device_mockup: 1]
      import BackupPluginWeb.Components.Divider, only: [divider: 1, hr: 1]
      import BackupPluginWeb.Components.Drawer, only: [drawer: 1]

      import BackupPluginWeb.Components.Dropdown,
        only: [dropdown: 1, dropdown_trigger: 1, dropdown_content: 1]

      import BackupPluginWeb.Components.EmailField, only: [email_field: 1]
      import BackupPluginWeb.Components.Fieldset, only: [fieldset: 1]
      import BackupPluginWeb.Components.FileField, only: [file_field: 1]
      import BackupPluginWeb.Components.Footer, only: [footer: 1, footer_section: 1]
      import BackupPluginWeb.Components.FormWrapper, only: [form_wrapper: 1, simple_form: 1]

      import BackupPluginWeb.Components.Gallery,
        only: [gallery: 1, gallery_media: 1, filterable_gallery: 1]

      import BackupPluginWeb.Components.Icon, only: [icon: 1]
      import BackupPluginWeb.Components.Image, only: [image: 1]
      import BackupPluginWeb.Components.Indicator, only: [indicator: 1]
      import BackupPluginWeb.Components.InputField, only: [input: 1, error: 1]
      import BackupPluginWeb.Components.Jumbotron, only: [jumbotron: 1]
      import BackupPluginWeb.Components.Keyboard, only: [keyboard: 1]
      import BackupPluginWeb.Components.Layout, only: [flex: 1, grid: 1]
      import BackupPluginWeb.Components.List, only: [list: 1, li: 1, ul: 1, ol: 1, list_group: 1]
      import BackupPluginWeb.Components.MegaMenu, only: [mega_menu: 1]
      import BackupPluginWeb.Components.Menu, only: [menu: 1]
      import BackupPluginWeb.Components.Modal, only: [modal: 1]

      import BackupPluginWeb.Components.NativeSelect,
        only: [native_select: 1, select_option_group: 1]

      import BackupPluginWeb.Components.Navbar, only: [navbar: 1, header: 1]
      import BackupPluginWeb.Components.NumberField, only: [number_field: 1]
      import BackupPluginWeb.Components.Overlay, only: [overlay: 1]
      import BackupPluginWeb.Components.Pagination, only: [pagination: 1]
      import BackupPluginWeb.Components.PasswordField, only: [password_field: 1]
      import BackupPluginWeb.Components.Popover, only: [popover: 1]

      import BackupPluginWeb.Components.Progress,
        only: [progress: 1, progress_section: 1, semi_circle_progress: 1, ring_progress: 1]

      import BackupPluginWeb.Components.RadioCard, only: [radio_card: 1]
      import BackupPluginWeb.Components.RadioField, only: [radio_field: 1, group_radio: 1]
      import BackupPluginWeb.Components.RangeField, only: [range_field: 1]
      import BackupPluginWeb.Components.Rating, only: [rating: 1]
      import BackupPluginWeb.Components.ScrollArea, only: [scroll_area: 1]
      import BackupPluginWeb.Components.SearchField, only: [search_field: 1]
      import BackupPluginWeb.Components.Sidebar, only: [sidebar: 1]
      import BackupPluginWeb.Components.Skeleton, only: [skeleton: 1]
      import BackupPluginWeb.Components.SpeedDial, only: [speed_dial: 1]
      import BackupPluginWeb.Components.Spinner, only: [spinner: 1]
      import BackupPluginWeb.Components.Stepper, only: [stepper: 1, stepper_section: 1]
      import BackupPluginWeb.Components.Table, only: [table: 1, th: 1, tr: 1, td: 1]

      import BackupPluginWeb.Components.TableContent,
        only: [table_content: 1, content_wrapper: 1, content_item: 1]

      import BackupPluginWeb.Components.Tabs, only: [tabs: 1]
      import BackupPluginWeb.Components.TelField, only: [tel_field: 1]
      import BackupPluginWeb.Components.TextField, only: [text_field: 1]
      import BackupPluginWeb.Components.TextareaField, only: [textarea_field: 1]
      import BackupPluginWeb.Components.Timeline, only: [timeline: 1, timeline_section: 1]
      import BackupPluginWeb.Components.Toast, only: [toast: 1, toast_group: 1]
      import BackupPluginWeb.Components.ToggleField, only: [toggle_field: 1]
      import BackupPluginWeb.Components.Tooltip, only: [tooltip: 1]

      import BackupPluginWeb.Components.Typography,
        only: [
          h1: 1,
          h2: 1,
          h3: 1,
          h4: 1,
          h5: 1,
          h6: 1,
          p: 1,
          strong: 1,
          em: 1,
          dl: 1,
          dt: 1,
          dd: 1,
          figure: 1,
          figcaption: 1,
          abbr: 1,
          mark: 1,
          small: 1,
          s: 1,
          u: 1,
          cite: 1,
          del: 1
        ]

      import BackupPluginWeb.Components.UrlField, only: [url_field: 1]
      import BackupPluginWeb.Components.Video, only: [video: 1]
    end
  end
end
