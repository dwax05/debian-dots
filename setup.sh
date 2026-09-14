#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

die() {
  printf 'setup: %s\n' "$*" >&2
  exit 1
}

check() {
  bash -n "$repo_dir/setup.sh"
  for path in \
    dotfiles/nvim/init.lua \
    dotfiles/shell/aliases.zsh \
    dotfiles/shell/env.zsh \
    dotfiles/starship/starship.toml \
    dotfiles/tmux/tmux.conf \
    dotfiles/zsh/.zshrc
  do
    [[ -f "$repo_dir/$path" ]] || die "missing $path"
  done
  printf 'setup: checks passed\n'
}

case ${1:-} in
  --check) check; exit ;;
  '') ;;
  *) die "usage: $0 [--check]" ;;
esac

[[ $EUID -ne 0 ]] || die 'run this as your normal user, not root'
command -v sudo >/dev/null || die 'sudo is required'
[[ -r /etc/os-release ]] || die 'cannot identify this operating system'
setup_user=$(id -un)

# shellcheck source=/dev/null
. /etc/os-release
[[ ${ID:-} == debian ]] || die 'this script supports Debian only'
[[ -n ${VERSION_CODENAME:-} ]] || die 'Debian VERSION_CODENAME is missing'

sudo -v
sudo apt-get update
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-remove ca-certificates curl

key_file=$(mktemp)
source_file=$(mktemp)
nvim_dir=$(mktemp -d)
trap 'rm -f "$key_file" "$source_file"; rm -rf "$nvim_dir"' EXIT

curl -fsSL --retry 3 https://download.docker.com/linux/debian/gpg -o "$key_file"
printf '%s\n' \
  'Types: deb' \
  'URIs: https://download.docker.com/linux/debian' \
  "Suites: $VERSION_CODENAME" \
  'Components: stable' \
  "Architectures: $(dpkg --print-architecture)" \
  'Signed-By: /etc/apt/keyrings/docker.asc' > "$source_file"
sudo install -d -m 0755 /etc/apt/keyrings
sudo install -m 0644 "$key_file" /etc/apt/keyrings/docker.asc
sudo install -m 0644 "$source_file" /etc/apt/sources.list.d/docker.sources

packages=(
  bash-completion bat btop build-essential clang docker-buildx-plugin docker-ce
  docker-ce-cli docker-compose-plugin eza fastfetch fd-find fzf git golang htop
  lsof npm openssh-server ripgrep rsync starship tmux ufw unzip wget xclip zoxide
  zsh zsh-syntax-highlighting
)

sudo apt-get update
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-remove "${packages[@]}"
sudo usermod -aG docker "$setup_user"

case $(dpkg --print-architecture) in
  amd64) nvim_arch=x86_64 ;;
  arm64) nvim_arch=arm64 ;;
  *) die 'Neovim prebuilt archives support only amd64 and arm64 here' ;;
esac

nvim_version=${NVIM_VERSION:-v0.11.5}
[[ $nvim_version =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || die 'NVIM_VERSION must look like v0.11.5'
nvim_archive="nvim-linux-$nvim_arch.tar.gz"
curl -fL --retry 3 \
  "https://github.com/neovim/neovim/releases/download/$nvim_version/$nvim_archive" \
  -o "$nvim_dir/$nvim_archive"
tar -xzf "$nvim_dir/$nvim_archive" -C "$nvim_dir"
sudo install -d -m 0755 "/opt/nvim-${nvim_version#v}-$nvim_arch"
sudo cp -a "$nvim_dir/nvim-linux-$nvim_arch/." "/opt/nvim-${nvim_version#v}-$nvim_arch/"
sudo ln -sfnT "/opt/nvim-${nvim_version#v}-$nvim_arch" /opt/nvim

link_file() {
  local source=$1 destination=$2
  mkdir -p "$(dirname -- "$destination")"
  if [[ -e $destination && ! -L $destination ]]; then
    die "refusing to replace existing $destination"
  fi
  ln -sfnT "$source" "$destination"
}

mkdir -p "$HOME/.config/tmux/plugins" "$HOME/.local/bin" "$HOME/.local/state/zsh"
link_file "$repo_dir/dotfiles/nvim" "$HOME/.config/nvim"
link_file "$repo_dir/dotfiles/shell" "$HOME/.config/shell"
link_file "$repo_dir/dotfiles/starship" "$HOME/.config/starship"
link_file "$repo_dir/dotfiles/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
link_file "$repo_dir/dotfiles/zsh" "$HOME/.config/zsh"
link_file "$repo_dir/dotfiles/zsh/.zshrc" "$HOME/.zshrc"
link_file /usr/bin/batcat "$HOME/.local/bin/bat"
link_file /usr/bin/fdfind "$HOME/.local/bin/fd"

if [[ ! -d $HOME/.config/tmux/plugins/tpm/.git ]]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
fi
"$HOME/.config/tmux/plugins/tpm/bin/install_plugins"

sudo chsh -s /usr/bin/zsh "$setup_user"

printf '\nsetup: complete; log out and back in to pick up Zsh and Docker group membership, then open nvim once\n'
