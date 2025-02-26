# no wayland, sad
issues:
- suspend nonsense
  - possible fix here: <https://bbs.archlinux.org/viewtopic.php?pid=2044189#p2044189>
- praat is themed wrong, rollback to 6.4.12 for now 
﻿
pending: 
- [reaper's "show resource path in explorer" button doesn't launch a file explorer](https://github.com/NixOS/nixpkgs/issues/341752)
  - fixed by me, just waiting on upstream to incorporate my package that fixes it
﻿
tracking
- [better qt integrations](https://github.com/NixOS/nixpkgs/issues/260696)
- [reaper sws extension](https://github.com/NixOS/nixpkgs/pull/285832)
- reapack (I've written this package, just thinking to see if there's a clever way to package the compiled file so it's more ergonomic
- [broken location services](https://github.com/NixOS/nixpkgs/issues/321121) 
  - manually set location for now with `gsettings set org.gnome.settings-daemon.plugins.color night-light-last-coordinates "(x, y)"`
  - I could set this declaratively (`location.provider="manual"`) but, I would like it to be automatic again someday for convenience
