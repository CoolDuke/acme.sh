#!/usr/bin/env sh

#Here is a script to deploy cert to apache http server.

#returns 0 means success, otherwise error.

#DEPLOY_APACHE_RELOAD="systemctl restart apache2"

########  Public functions #####################

#domain keyfile certfile cafile fullchain
apache_deploy() {
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

  _ssl_path="/etc/acme.sh/apache2"
  if ! mkdir -p "$_ssl_path"; then
    _err "Can not create folder:$_ssl_path"
    return 1
  fi

  _info "Copying key and cert"
  _real_key="$_ssl_path/${_cdomain}.key"
  if ! cp "$_ckey" "$_real_key"; then
    _err "Error: write key file to: $_real_key"
    return 1
  fi
  if ! chmod 600 "$_real_key"; then
    _err "Error: set mode 600 on: $_real_key"
    return 1
  fi
  _real_cert="$_ssl_path/${_cdomain}.crt"
  if ! cat "$_ccert" >"$_real_cert"; then
    _err "Error: write cert file to: $_real_cert"
    return 1
  fi
  _real_cacert="$_ssl_path/${_cdomain}.ca.crt"
  if ! cat "$_cca" >"$_real_cacert"; then
    _err "Error: write ca cert file to: $_real_cacert"
    return 1
  fi

  DEFAULT_APACHE_RELOAD="systemctl reload apache2"
  _reload="${DEPLOY_APACHE_RELOAD:-$DEFAULT_APACHE_RELOAD}"

  _info "Run reload: $_reload"
  if eval "$_reload"; then
    _info "Reload success!"
    return 0
  else
    _err "Reload error"
    return 1
  fi
  return 0

}
