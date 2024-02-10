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
        // stage("User pipeline job") {
        //     steps {
        //         script {
        //             build(job: "/AI4OS-HUB-TEST/" + env.JOB_NAME.drop(10))
        //         }
        //     }
        // }
        stage('AI4OS Hub SQA baseline dynamic stages') {
            steps {
                sh 'mkdir -p _ai4os-hub-qa'
                dir("_ai4os-hub-qa") {
                    git branch: "master",
                    url: 'https://github.com/ai4os/ai4os-hub-qa'
                }
                script {
                    projectConfig = pipelineConfig(
                        configFile: "_ai4os-hub-qa/.sqa/ai4eosc.yml"
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
                    // load constants defined in user's repository
                    def constants = load 'JenkinsConstants.groovy'
                    env.base_cpu_tag = constants.base_cpu_tag
                    env.base_gpu_tag = constants.base_gpu_tag
                    def dockerfile = "Dockerfile"
                    if (constants.dockerfile) {
                        dockerfile = constants.dockerfile
                    }
                    // define docker tag
                    if ( env.BRANCH_NAME.startsWith("release/") ) {
                        docker_tag = env.BRANCH_NAME.drop(8)
                    }
                    else if ( env.BRANCH_NAME in ['master', 'main'] ) {
                        docker_tag = "latest"
                    }
                    else {
                        docker_tag = env.BRANCH_NAME
                    }
                    docker_tag = docker_tag.toLowerCase()
            
                    // FIXME(aloga): this needs to be improved
                    echo env.base_cpu_tag
                    echo env.base_gpu_tag
                    echo "${env.base_cpu_tag}"
                    echo "${env.base_gpu_tag}"
                    echo dockerfile
                    // get docker repository name
                    meta = readJSON file: "metadata.json"
                    image_repo = meta["sources"]["docker_registry_repo"].split("/")[1]

                    image_name = docker_repository + "/" + image_repo + ":" + docker_tag
                    if (env.base_cpu_tag) {
                        image = docker.build(image_name, "--no-cache --force-rm --build-arg tag=${env.base_cpu_tag} -f ${dockerfile} .")
                        // if (docker_tag == "latest") {
                        //     image_cpu = docker.image(image_name).tag["latest","cpu"]
                        // }
                        // else {
                        //     image_cpu = docker.image(image_name).tag["latest",("cpu-" + docker_tag)]
                        // }
                        // docker_ids.add(image_cpu)
                    }
                    else {
                        image = docker.build(image_name, "--no-cache --force-rm -f ${dockerfile} .")
                    }
                    docker_ids.add(image)
                    
                    // check built image for DEEPaaS API reponse
                    sh "git clone https://github.com/ai4os/ai4os-hub-check-artifact"
                    sh "bash ai4os-hub-check-artifact/check-artifact ${image_name}"
                    sh "rm -rf ai4os-hub-check-artifact"

                    if (env.base_gpu_tag) {
                        docker_tag = (docker_tag == "latest") ? "gpu" : ("gpu-" + docker_tag)
                        image_name = docker_repository + "/" + image_repo + ":" + docker_tag
                        image_gpu = docker.build(image_name, "--no-cache --force-rm --build-arg tag=${env.base_gpu_tag}  -f ${dockerfile} .")
                        docker_ids.add(image_gpu)
                    }

                }
            }
        }
        stage('AI4OS Hub Docker delivery to registry') {
            steps {
                script {
                    echo "${env.base_cpu_tag}"
                    echo "${env.base_gpu_tag}"
                    docker.withRegistry(docker_registry, docker_registry_credentials) {
                        docker_ids.each {
                            echo "${it}"
                            it.push()
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

