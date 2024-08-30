#!/bin/sh
# Copyright (C) 2017  https://github.com/undergroundwires

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as
#  published by the Free Software Foundation, either version 3 of the
#  License, or (at your option) any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.

#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.

# source https://github.com/undergroundwires/privacy.sexy/blob/0.13.6/.github/actions/force-ipv4/force-ipv4.sh

main() {
  if is_linux; then
    echo 'Configuring Linux...'

    configure_warp_with_doh_and_ipv6_exclusion_on_linux # [WORKS] Resolves the issue when run independently on GitHub runners lacking IPv6 support.
    prefer_ipv4_on_linux # [DOES NOT WORK] It does not resolve the issue when run independently on GitHub runners without IPv6 support.

    # Considered alternatives:
    # - `sysctl` commands, and direct changes to `/proc/sys/net/` and `/etc/sysctl.conf` led to silent
    #   Node 18 exits (code: 13) when using `fetch`.
  elif is_macos; then
    echo 'Configuring macOS...'

    configure_warp_with_doh_and_ipv6_exclusion_on_macos # [WORKS] Resolves the issue when run independently on GitHub runners lacking IPv6 support.
    disable_ipv6_on_macos # [WORKS INCONSISTENTLY] Resolves the issue inconsistently when run independently on GitHub runners without IPv6 support.
  fi
  echo "IPv4: $(curl --ipv4 --silent --max-time 15 --retry 3 --user-agent Mozilla https://api.ip.sb/geoip)"
  echo "IPv6: $(curl --ipv6 --silent --max-time 15 --retry 3 --user-agent Mozilla https://api.ip.sb/geoip)"
}

is_linux() {
  [[ "$(uname -s)" == "Linux" ]]
}

is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

configure_warp_with_doh_and_ipv6_exclusion_on_linux() {
  install_warp_on_debian
  configure_warp_doh_and_exclude_ipv6
}

configure_warp_with_doh_and_ipv6_exclusion_on_macos() {
  brew install cloudflare-warp
  configure_warp_doh_and_exclude_ipv6
}

configure_warp_doh_and_exclude_ipv6() {
  echo 'Beginning configuration of the Cloudflare WARP client with DNS-over-HTTPS and IPv6 exclusion...'
  echo 'Initiating client registration with Cloudflare...'
  warp-cli --accept-tos registration new
  echo 'Configuring WARP to operate in DNS-over-HTTPS mode (warp+doh)...'
  warp-cli --accept-tos mode warp+doh
  echo 'Excluding IPv6 traffic from WARP by configuring it as a split tunnel...'
  warp-cli --accept-tos add-excluded-route '::/0' # Exclude IPv6, forcing IPv4 resolution
  # `tunnel ip add` does not work with IP ranges, see https://community.cloudflare.com/t/cant-cidr-for-split-tunnling/630834
  echo 'Establishing WARP connection...'
  warp-cli --accept-tos connect
}

install_warp_on_debian() {
  curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
  sudo apt-get update
  sudo apt-get install -y cloudflare-warp
}

disable_ipv6_on_macos() {
  networksetup -listallnetworkservices \
    | tail -n +2 \
    | while IFS= read -r interface; do
        echo "Disabling IPv6 on: $interface..."
        networksetup -setv6off "$interface"
      done
}

prefer_ipv4_on_linux() {
  local -r gai_config_file_path='/etc/gai.conf'
  if [ ! -f "$gai_config_file_path" ]; then
      echo "Creating $gai_config_file_path since it doesn't exist..."
      touch "$gai_config_file_path"
  fi
  echo "precedence ::ffff:0:0/96  100" | sudo tee -a "$gai_config_file_path" > /dev/null
  echo "Configuration complete."
}

main
