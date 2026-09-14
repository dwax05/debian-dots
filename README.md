# Debian setup

Turns a basic Debian install into this machine's developer environment: Zsh,
Starship, tmux, Neovim 0.11.5, Docker, Go/Node/C tooling, SSH, and the everyday
CLI utilities in `setup.sh`.

```sh
git clone <this-repository> ~/dev/setupscript
cd ~/dev/setupscript
./setup.sh --check
./setup.sh
```

Run it as your normal sudo-enabled user. Existing managed config files are not
overwritten; move them aside first if you want this repo to own them. Set
`NVIM_VERSION=v0.11.5` to select another compatible Neovim release.

It intentionally does not copy credentials, SSH keys, Git identity, histories,
GNOME preferences, or account-bound tools and services such as Tailscale,
Playit, Claude, and Codex.

Open `nvim` once after setup to install its plugins. This intentionally runs in
an interactive editor session, not as part of the system bootstrap.
