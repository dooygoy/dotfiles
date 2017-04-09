{ pkgs 
}:

with import ./lib.nix { inherit pkgs; };

let
   emacsPackages = pkgs.emacsPackagesNg.override (super: self: {
     emacs = pkgs.emacs25Macport;
     
     kubernetes = self.melpaBuild {
       pname = "kubernetes";
       version = "0.0.1";
       src = pkgs.fetchFromGitHub {
         owner = "chrisbarrett";
         repo = "kubernetes-el";
         rev = "f53ce6f6ddda5efef165c2642dd13518025543c7";
         sha256 = "1ljp7yllx6g5iyj17y2dqx0k4zbfa7qy54fj1j32kz4ka9j228z4";
       };
       packageRequires = [ self.dash self.magit ];
     };

     intero = self.melpaBuild {
       pname = "intero";
       version = "0.0.1";
       src =
         let repo = pkgs.fetchFromGitHub {
           owner = "commercialhaskell";
           repo = "intero";
           rev = "04265e68647bbf27772df7b71c9927d451e6256f";
           sha256 = "0zax01dmrk1zbqw8j8css1w6qynbavfdjfgfxs34pb37gp4v8mgg";
         };
	 in pkgs.runCommand "intero" {} "ln -s ${repo}/elisp $out";
       packageRequires = [ self.flycheck self.company self.haskell-mode ];
     };
   });

   mySnippets = mkYaSnippetsDir {
     haskell-mode = {
       fun = ''
         ''\${1:function-name} :: ''\${2:type}
         $1 = $0error "Not implemented: $1"
         '';
     };
   };
in mkEmacs emacsPackages {
  config = ''
    (setq inhibit-startup-screen t)
    (tool-bar-mode -1)
    (menu-bar-mode -1)
    (winner-mode 1)
    (windmove-default-keybindings)
    (global-font-lock-mode 1)
    (show-paren-mode 1)
    (scroll-bar-mode -1)
  '';
  packages = 
    (map (i: { package = i; }) [
      "scala-mode"
      "nix-mode"
      "magit"
      "restclient"
      "ag"
    ]) ++ [
      {
        package = "sbt-mode";
        init    = ''
          (global-set-key (kbd "C-c C-l") (lambda() (interactive) (sbt-command "compile")))
          (global-set-key (kbd "C-c C-t") (lambda() (interactive) (sbt-command "test")))
          (global-set-key (kbd "C-c C-z") (lambda() (interactive) (sbt-command "!!")))
          '';
      }
      {
        package = "undo-tree";
        init    = "(setq undo-tree-visualizer-timestamps t)";
        config  = "(global-undo-tree-mode)";
      }
      {
        package = "monokai-theme";
        config  = "(load-theme 'monokai t)";
      }
      {
        package = "counsel";
        init    = "(ivy-mode 1)";
      }
      {
        package = "counsel-projectile";
        init    = "(counsel-projectile-on)";
        bind    = "(\"C-c p f\" . counsel-projectile-find-file)";
      }
      {
        package = "projectile";
        config  = "(projectile-mode 1)";
      }
      {
        package = "flycheck";
        config  = "(global-flycheck-mode)";
      }
      {
        package = "ace-jump-mode";
        bind    = "(\"C-c SPC\" . ace-jump-mode)";
      }
      {
        package = "ws-butler";
        config  = "(ws-butler-global-mode)";
      }
      {
        package = "yasnippet";
        init    = "(setq yas-snippet-dirs '(\"${mySnippets}\"))";
        config  = "(yas-global-mode 1)";
      }
      {
        package  = "kubernetes";
	commands = "kubernetes-overview";
      }
      {
        package = "intero";
        config  = "(add-hook 'haskell-mode-hook 'intero-mode)";
      }
    ];
}
