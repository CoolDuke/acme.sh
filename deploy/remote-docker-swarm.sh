#!/usr/bin/env sh

#Here is a script to deploy cert to remote docker swarm.

#returns 0 means success, otherwise error.

#DEPLOY_REMOTE_DOCKER_SWARM_SCP_TARGET="acme@host:/etc/acme.sh/remote-docker-swarm"
#DEPLOY_REMOTE_DOCKER_SWARM_RELOAD="ssh letsencrypt@host sudo /usr/bin/docker service update --force my-nginx-service"

########  Public functions #####################

#domain keyfile certfile cafile fullchain
remote-docker-swarm_deploy() {
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

  DEFAULT_REMOTE_DOCKER_SWARM_SCP_TARGET="acme@host:/etc/acme.sh/remote-docker-swarm"
  _scp_target="${DEPLOY_REMOTE_DOCKER_SWARM_SCP_TARGET:-$DEFAULT_REMOTE_DOCKER_SWARM_SCP_TARGET}"

  _remote_login=$(echo $_scp_target | cut -d: -f1)
  _ssl_path=$(echo $_scp_target | cut -d: -f2)
  if ! ssh $_remote_login mkdir -p "$_ssl_path"; then
    _err "Can not create folder at $_remote_login:$_ssl_path"
    return 1
  fi

  _info "Copying key and cert"
  _real_key="$_ssl_path/${_cdomain}.key"
  if ! scp -Cp "$_ckey" "$_remote_login:$_real_key"; then
    _err "Error: write key file to: $_remote_login:$_real_key"
    return 1
  fi
  if ! ssh $_remote_login chmod 600 "$_real_key"; then
    _err "Error: set mode 600 on: $_remote_login:$_real_key"
    return 1
  fi
  _real_cert="$_ssl_path/${_cdomain}.pem"
  if ! scp -Cp "$_cfullchain" "$_remote_login:$_real_cert"; then
    _err "Error: write fullchain file to: $_remote_login:$_real_cert"
    return 1
  fi

  DEFAULT_REMOTE_DOCKER_SWARM_RELOAD="ssh letsencrypt@host sudo /usr/bin/docker service update --force my-nginx-service"
  _reload="${DEPLOY_REMOTE_DOCKER_SWARM_RELOAD:-$DEFAULT_REMOTE_DOCKER_SWARM_RELOAD}"

  _info "Run reload: $_reload"
  if eval "$_reload"; then
    _info "Reload success!"

    if [ "$DEPLOY_REMOTE_DOCKER_SWARM_RELOAD" ]; then
      _savedomainconf DEPLOY_REMOTE_DOCKER_SWARM_RELOAD "$DEPLOY_REMOTE_DOCKER_SWARM_RELOAD"
    else
      _cleardomainconf DEPLOY_REMOTE_DOCKER_SWARM_RELOAD
    fi

    if [ "$DEPLOY_REMOTE_DOCKER_SWARM_SCP_TARGET" ]; then
      _savedomainconf DEPLOY_REMOTE_DOCKER_SWARM_SCP_TARGET "$DEPLOY_REMOTE_DOCKER_SWARM_SCP_TARGET"
    else
      _cleardomainconf DEPLOY_REMOTE_DOCKER_SWARM_SCP_TARGET
    fi

    return 0
  else
    _err "Reload error"
    return 1
  fi
  return 0

}
