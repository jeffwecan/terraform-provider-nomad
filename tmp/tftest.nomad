job "tftest" {
  datacenters = ["dc1"]
  type        = "batch"

  parameterized {
    meta_optional = [
      "provider_branch",
      "consul_version",
      "nomad_version",
      "terraform_version",
      "vault_version"
    ]
  }

  meta {
    provider_branch   = "master"
    consul_version    = "1.9.0"
    nomad_version     = "0.12.9"
    terraform_version = "0.14.0"
    vault_version     = "1.6.0"
  }

  group "foo" {
    network {
      port "nomad" {
        to = 4646
      }

      port "consul" {
        to = 8500
      }
    }

    task "cluster" {
      driver = "docker"

      config {
        image = "tftest:0.0.1"
        args  = ["/bin/bash", "-c", "./scripts/start-nomad.sh && export NOMAD_TOKEN=$(cat /tmp/nomad-test.token) && make testacc"]

        cap_add = [
          "SYS_ADMIN",
        ]

        ports = ["nomad", "consul"]

        volumes = [
          "local/opt:/opt/hashicorp",
          "local/provider:/root/provider",
          "local/bin:/usr/local/bin",
        ]
      }

      resources {
        cpu    = 2000
        memory = 1024
      }

      artifact {
        source      = "https://releases.hashicorp.com/consul/${NOMAD_META_consul_version}/consul_${NOMAD_META_consul_version}_linux_amd64.zip"
        destination = "local/bin"
      }

      artifact {
        source      = "https://releases.hashicorp.com/nomad/${NOMAD_META_nomad_version}/nomad_${NOMAD_META_nomad_version}_linux_amd64.zip"
        destination = "local/bin"
      }

      artifact {
        source      = "https://releases.hashicorp.com/terraform/${NOMAD_META_terraform_version}/terraform_${NOMAD_META_terraform_version}_linux_amd64.zip"
        destination = "local/bin"
      }

      artifact {
        source      = "https://releases.hashicorp.com/vault/${NOMAD_META_vault_version}/vault_${NOMAD_META_vault_version}_linux_amd64.zip"
        destination = "local/bin"
      }

      artifact {
        source      = "git::https://github.com/hashicorp/terraform-provider-nomad?ref=${NOMAD_META_provider_branch}"
        destination = "local/provider"
      }
    }
  }
}
