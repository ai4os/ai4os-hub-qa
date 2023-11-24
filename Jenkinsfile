// vim: filetype=groovy

@Library([
    'github.com/indigo-dc/jenkins-pipeline-library@release/2.1.1',
]) _


def projectConfig

pipeline {
    agent {
        label 'docker'
    }
    
    stages {

        stage("User Jenkinsfile") {
            steps {
                script {
                    build(job: "/AI4OS-HUB-TEST/" + env.JOB_NAME.drop(10))
                }
            }
        }
        stage('AI4OS Hub SQA baseline dynamic stages') {
            steps {
                script {
                    projectConfig = pipelineConfig(
                        configFile: ".sqa/ai4eosc.yml"
                    )
                    buildStages(projectConfig)
                }
            }
            post {
                cleanup {
                    cleanWs()
                }
            }
        }
    

        stage("Variable initialization") {
            steps {
                script {
                    withFolderProperties{
                        docker_registry = env.AI4OS_REGISTRY
                        docker_registry_credentials = env.AI4OS_REGISTRY_CREDENTIALS
                        docker_repository = env.AI4OS_REGISTRY_REPOSITORY
                    }
                    docker_ids = []

                    // Check here if variables exist
                }
            }
        }


        stage('AI4OS Hub Docker image build') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'test'
                    branch 'dev'
                    branch 'release/*'
                }
            }
            steps {
                checkout scm

                script {
                    if ( env.BRANCH_NAME.startsWith("release/") ) {
                        docker_tag = env.BRANCH_NAME.drop(8)
                    }
                    else if ( env.BRANCH_NAME in ['master', 'main'] ) {
                        docker_tag = latest
                    }
                    else {
                        docker_tag = env.BRANCH_NAME
                    }
            
                    // FIXME(aloga): this needs to be improved

                    meta = readJSON file: "metadata.json"
                    image_name = meta["sources"]["docker_registry_repo"].split("/")[1]

                    image_name = docker_repository + "/" + image_name + ":" + docker_tag

                    image = docker.build(image_name, "--no-cache --force-rm .")
                    docker_ids.add(image_name)
                }
            }
        }
        stage('AI4OS Hub Docker delivery to registry') {
            steps {
                script {
                    docker.withRegistry(docker_registry, docker_registry_credentials) {
                        docker_ids.each {
                            docker.image(it).push()
                        }
                    }
                }
            }
        }
        stage('Cleanup') {
            steps { 
                script {
                    echo "Cleaning workspace"
                }
            }
            post {
                always {
                    cleanWs()
                }
            }
        }
    }
}

