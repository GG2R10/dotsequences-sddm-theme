# Dotsequences SDDM Theme

A single-config, single-wallpaper SDDM theme for Qt6, maintained by [GG2R10](https://github.com/GG2R10).

Built on top of [sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme) by [Keyitdev](https://github.com/Keyitdev), stripped down from its original multi-theme/multi-wallpaper setup into one fixed look: one background, one profile picture, one config file.

## Preview

<video src="https://github.com/user-attachments/assets/2d3f732b-e154-4136-8ad3-8c53f3de8872" controls width="100%">
  Your browser/renderer can't play the embedded video — see <a href="preview.mp4">preview.mp4</a> directly.
</video>

## Installation

Works on Arch, Fedora and Ubuntu (untested on Void and openSUSE). Installs `sddm` + the required Qt6 dependencies, clones this repo, copies the theme into `/usr/share/sddm/themes/`, registers its fonts system-wide, and sets it as SDDM's current theme via a drop-in in `/etc/sddm.conf.d/`.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/GG2R10/dotsequences-sddm-theme/master/install.sh)"
```

The script tells you exactly what it's about to do before asking for confirmation, and every step that needs root uses `sudo` explicitly — nothing runs silently.

## Making it yours

This theme ships with my own background, profile picture and config as *placeholders*. Before using it, you'll probably want to swap:

- **`background.jpg`** — the login screen wallpaper. Replace it with your own image (PNG, JPG/JPEG or GIF).
- **`pfp.png`** — the profile picture shown above the login form.
- **`theme.conf`** — colors, fonts, blur, form position, and general behavior (auto-fill last user, password visibility, etc). It's commented inline, so open it and tweak what you want.
- **`phrases.js`** — the rotating phrases the clock types out on the login screen. It's a plain JS array, one phrase per entry — no need to touch any `.qml` file:
  ```js
  .pragma library

  var list = [
      "Your phrase here",
      "Another one"
  ];
  ```
  Edit the list, save, and it picks up the change on the next SDDM start.

If you installed via the script above, edit the copies under `/usr/share/sddm/themes/dotsequences-sddm-theme/` (you'll need `sudo` to write there), then restart SDDM (or reboot) to see the changes.

## License

Theme code is licensed under [GPL-3.0-or-later](LICENSE), consistent with the project it's based on. The bundled Open Sans font is licensed separately under [Apache License 2.0](Fonts/OpenSans/LICENSE.txt).
