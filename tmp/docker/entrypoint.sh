#!/usr/bin/env bash

set -e

ln -s /opt/hashicorp/terraform /usr/bin/terraform
ln -s /opt/hashicorp/nomad /usr/bin/nomad
ln -s /opt/hashicorp/consul /usr/bin/consul
ln -s /opt/hashicorp/vault /usr/bin/vault

terraform --version
nomad --version
consul --version
vault --version

exec "$@"
