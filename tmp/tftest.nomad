job "tftest" {
  datacenters = ["dc1"]
  type        = "batch"

  parameterized {
    meta_required = ["provider_branch", "terraform_version", "nomad_version"]
  }

  group "foo" {
    network {
      port "nomad" {
        to = 4646
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

        ports = ["nomad"]

        volumes = [
          "local/opt:/opt/hashicorp",
          "local/provider:/root/provider",
        ]
      }

      resources {
        cpu    = 2000
        memory = 1024
      }

      artifact {
        source      = "https://releases.hashicorp.com/nomad/${NOMAD_META_nomad_version}/nomad_${NOMAD_META_nomad_version}_linux_amd64.zip"
        destination = "local/opt"
      }

      artifact {
        source      = "https://releases.hashicorp.com/consul/1.8.6/consul_1.8.6_linux_amd64.zip"
        destination = "local/opt"
      }

      artifact {
        source      = "https://releases.hashicorp.com/vault/1.6.0/vault_1.6.0_linux_amd64.zip"
        destination = "local/opt"
      }

      artifact {
        source      = "https://releases.hashicorp.com/terraform/${NOMAD_META_terraform_version}/terraform_${NOMAD_META_terraform_version}_linux_amd64.zip"
        destination = "local/opt"
      }

      artifact {
        source      = "git::https://github.com/hashicorp/terraform-provider-nomad?ref=${NOMAD_META_provider_branch}"
        destination = "local/provider"
      }
    }
  }
}
