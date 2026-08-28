# Custom image for the Nomad main worker
# Currently hosted in ignacioheredia/jenkins-nomad-agent

FROM jenkins/inbound-agent
USER root
RUN apt-get update && apt-get install -y docker.io jq curl && rm -rf /var/lib/apt/lists/*
USER root