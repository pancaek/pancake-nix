{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.modules.firefox;
  isNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
in
{
  options.modules.firefox = {
    enable = lib.mkEnableOption "Enable firefox with extra compatibility tweaks";
  };

  config = lib.mkIf cfg.enable {

    programs.firefox = {
      enable = true;
      preferences = lib.mkIf isNvidia {
        # NVIDIA VA-API
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "gfx.x11-egl.force-enabled" = true;
        "widget.dmabuf.force-enabled" = true;
      };
    };

    environment.sessionVariables = lib.mkIf isNvidia {
      MOZ_DISABLE_RDD_SANDBOX = 1;
      LIBVA_DRIVER_NAME = "nvidia";
    };
  };
}