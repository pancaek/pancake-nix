# no wayland, sad
issues:
- praat is themed wrong, rollback to 6.4.12 for now 
﻿
pending: 
- [reaper's "show resource path in explorer" button doesn't launch a file explorer](https://github.com/NixOS/nixpkgs/issues/341752)
  - fixed by me, just waiting on upstream to incorporate my package that fixes it
﻿
tracking
- [better qt integrations](https://github.com/NixOS/nixpkgs/issues/260696)
- [broken location services](https://github.com/NixOS/nixpkgs/issues/321121) 
  - manually set location for now with `gsettings set org.gnome.settings-daemon.plugins.color night-light-last-coordinates "(x, y)"`
  - I could set this declaratively (`location.provider="manual"`) but, I would like it to be automatic again someday for convenience
