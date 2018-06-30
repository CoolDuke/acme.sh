#!/usr/bin/env sh

#Here is a script to deploy cert to courier imap/pop3 server.

#returns 0 means success, otherwise error.

########  Public functions #####################

#domain keyfile certfile cafile fullchain
courier_deploy() {
  _cdomain="$1"
  _ckey="$2"
  _ccert="$3"
  _cca="$4"
  _cfullchain="$5"

  _debug _cdomain "$_cdomain"
  _debug _ckey "$_ckey"
  _debug _ccert "$_ccert"
  _debug _cca "$_cca"
  _debug _cfullchain "$_cfullchain"

  _ssl_path="/etc/acme.sh/courier"
  if ! mkdir -p "$_ssl_path"; then
    _err "Can not create folder:$_ssl_path"
    return 1
  fi

  _info "Copying key and certs"
  _real_cert="$_ssl_path/${_cdomain}.pem"
  if ! cat "$_ckey" "$_cfullchain" > "$_real_cert"; then
    _err "Error: write key/cert files to: $_real_cert"
    return 1
  fi
  if ! chmod 640 "$_real_cert"; then
    _err "Error: set mode 640 on: $_real_cert"
    return 1
  fi

  return 0
}
