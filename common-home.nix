{...}:

let pkgs = import ./nixpkgs {};
in

{
  home.packages = with pkgs; [
    # CLI
    ranger
    arandr scrot bashmount
    xsel xclip
    imagemagick pdftk ncdu
    htop tree units ascii

    nload siege

    zip unzip man man-db

    file dos2unix findutils coreutils
    watch graphviz rsync parallel openssl
    inotify-tools

    zsh
    oh-my-zsh

    entr xdotool

    lastpass-cli gnupg keybase

    # i3
    i3 i3status i3lock feh dmenu rxvt_unicode unclutter
    networkmanagerapplet parcellite
    lxappearance xfontsel ubuntu_font_family

    # Desktop
    firefox-beta-bin

    # Media
    qiv  zathura
    pasystray pavucontrol
    smplayer mplayer audacity gimp

    spotify

    # Utils
    libreoffice dia chromium

    # Programming
    neovim
    (kubernetes.override { components = [ "cmd/kubectl" ]; })

    gitAndTools.hub
    haskellPackages.darcs

    pv jq ripgrep tree fasd
    ncdu htop cloc units
    haskellPackages.lentil
    haskellPackages.pandoc
    curl wget

    hexedit docker_compose

    mtr nmap

    cmatrix

    awscli

    cabal2nix stack
    gcc gnumake openjdk8 nodejs
    (sbt.override { jre = jre8; })
    haskellPackages.ShellCheck
    python2 python3
    python3Packages.virtualenv

    nix-repl nix-prefetch-scripts
    (let src = pkgs.fetchFromGitHub {
      owner = "expipiplus1"; repo = "update-nix-fetchgit";
      rev = "c820f7bfad87ba9dc54fdcb61ad0ca19ce355c94";
      sha256 = "1f7d7ldw3awgp8q1dqb36l9v0clyygx0vffcsf49w4pq9n1z5z89"; };
     in haskell.lib.doJailbreak (haskellPackages.callPackage "${src}/default.nix" {})
    )

    autorandr
  ];

  programs.git = {
    enable = true;
    userName = "Utku Demir";
    userEmail = "me@utdemir.com";
  xsession = {
    enable = true;
    windowManager = "${pkgs.i3}/bin/i3";
  };

  home.file.".stack/config.yaml".source = ./dotfiles/stack;
  
  home.file.".config/i3/config".source = ./dotfiles/i3/config;
  home.file.".config/i3/autostart.sh".source = ./dotfiles/i3/autostart.sh;
  home.file.".config/i3status/config".source = ./dotfiles/i3/i3status;
  home.file.".config/i3/wallpaper.png".source = ./dotfiles/i3/wallpaper.png;

  home.file.".Xdefaults".source = ./dotfiles/Xdefaults;
  
  home.file.".zshrc".source = ./dotfiles/zshrc;
  home.file.".zsh_custom/utdemir.zsh-theme".source = ./dotfiles/zsh_custom/utdemir.zsh-theme;

  home.file.".emacs.el".source = ./dotfiles/emacs.el;
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      company
      counsel
      counsel-projectile
      doom-themes
      git-gutter
      haskell-mode
      highlight-symbol
      hindent
      magit
      multiple-cursors
      nix-mode
      nix-mode
      projectile
      protobuf-mode
      restclient
      rg
      rich-minority
      sbt-mode
      scala-mode
      smart-mode-line
      undo-tree
      ws-butler
      yaml-mode
    ];
  };
  home.file.".config/.autorandr/postswitch" = {
    mode = "755";
    text = ''
      #!/usr/bin/env sh
      feh --bg-fill ~/.config/i3/wallpaper.png
    '';
  };
}
