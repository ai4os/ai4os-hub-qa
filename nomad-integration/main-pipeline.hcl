# This job has ACCESS to the host docker socket (needed to build images).
# It must only run trusted pipeline code, never user-defined code:
# socket access is effectively root on the Nomad client host.

job "%WORKER_NAME%" {
  region = "global"
  type   = "batch"

  constraint {
    attribute = "${meta.status}"
    operator  = "regexp"
    value     = "ready"
  }

  constraint {
    attribute = "${meta.type}"
    operator  = "="
    value     = "compute"
  }

  group "jenkins-worker-taskgroup" {
    count = 1

    restart {
      attempts = 0
      interval = "10s"
      delay    = "1s"
      mode     = "fail"
    }

    ephemeral_disk {
      # Docker builds happen on the host daemon, but the workspace holds
      # the checked-out repo, build context and cloned helper repos.
      size = 5000
    }

    task "jenkins-worker" {
      driver = "docker"

      config {
        # Custom inbound-agent image that includes the docker CLI.
        # IMPORTANT: the image must end with 'USER root' (the stock
        # inbound-agent image uses 'USER jenkins'), otherwise the mounted
        # docker socket (owned by root:docker on the host) is not accessible.
        image = "ignacioheredia/jenkins-nomad-agent"
        # Mount the host docker socket (DooD): builds/runs become sibling
        # containers on the host daemon. This is effectively root on the
        # host, hence the warning above.
        #
        # Identity-mount a host workspace dir at the SAME path used as the
        # Jenkins agent's remote root (-workDir below). Jenkins' docker
        # pipeline steps (reuseNode/docker.build/...) run sibling containers
        # via the host daemon and bind-mount workspace paths verbatim: for
        # the files to exist on the host side, the agent workspace must live
        # in a real host directory mounted at the identical path. The Nomad
        # alloc dir can't be used for this because its host path differs
        # from the container path and is already mounted at /alloc.
        # This dir must exist on every compute node: mkdir -p /var/jenkins-workspace
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
          "/var/jenkins-workspace:/var/jenkins-workspace"
        ]
        # Place the Jenkins remote root on the identity-mounted host dir.
        # The Jenkins Nomad plugin replaces %WORKER_NAME%.
        args = [
          "-workDir",
          "/var/jenkins-workspace/%WORKER_NAME%"
        ]
      }

      env {
        JENKINS_URL        = "https://jenkins.cloud.ai4eosc.eu/"
        JENKINS_AGENT_NAME = "%WORKER_NAME%"
        JENKINS_SECRET     = "%WORKER_SECRET%"
        JENKINS_WEB_SOCKET = "true"
      }

      resources {
        # Sized for docker image builds (docker.build + check-artifact).
        # CPU shares are soft in Nomad; memory is the hard limit.
        cpu    = 2000
        memory = 4096
      }
    }
  }
}