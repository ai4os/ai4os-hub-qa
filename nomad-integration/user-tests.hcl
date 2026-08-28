# This job has no access to the host docker socket for security reasons, since it is running user code

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
      # Repo checkout + tox virtualenvs + coverage/bandit reports.
      size = 1000
    }

    task "jenkins-worker" {
      driver = "docker"

      config {
        image = "jenkins/inbound-agent"
      }

      env {
        JENKINS_URL        = "https://jenkins.cloud.ai4eosc.eu/"
        JENKINS_AGENT_NAME = "%WORKER_NAME%"
        JENKINS_SECRET     = "%WORKER_SECRET%"
        JENKINS_WEB_SOCKET = "true"
      }

      resources {
        # Lightweight validation only: tox, flake8/ruff, bandit, pytest.
        cpu    = 1000
        memory = 2048
      }
    }
  }
}