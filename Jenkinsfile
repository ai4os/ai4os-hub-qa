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
                    // define docker tag depending on the branch/release
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

                    // get docker repository name from metadata.json
                    meta = readJSON file: "metadata.json"
                    image_name = meta["sources"]["docker_registry_repo"].split("/")[1]

                    image = docker_repository + "/" + image_name + ":" + docker_tag

                    // build docker images
                    // by default we expect Dockerfile name and location in the git repo root
                    def dockerfile = "Dockerfile"
                    def base_cpu_tag = ""
                    def base_gpu_tag = ""
                    def build_cpu_tag = false
                    def build_gpu_tag = false
                    // try to load constants if defined in user's repository
                    try {
                        def constants = load 'JenkinsConstants.groovy'
                        base_cpu_tag = constants.base_cpu_tag
                        base_gpu_tag = constants.base_gpu_tag
                        if (constants.dockerfile) {
                            dockerfile = constants.dockerfile
                        }
                        // let's require that either both "base_cpu_tag" && "base_gpu_tag" are defined or none
                        if (!base_cpu_tag || !base_gpu_tag) {
                            throw new Exception("Check JenkinsConstants.groovy: Either both \"base_cpu_tag\" and \"base_gpu_tag\" are defined or none")
                        }
                        // if no Exception so far, allow building "-cpu" and "-gpu" versions
                        build_cpu_tag = true
                        build_gpu_tag = true
                    } catch (err) {
                        // if JenkinsConstants.groovy not found or one of base_cpu|gpu_tag not defined, build docker image with default params
                        println("[WARNING] Exception: ${err}")
                        println("[INFO] Using default parameters for Docker image building")
                        image_id = docker.build(image, "--no-cache --force-rm -f ${dockerfile} .")
                    }
                    // build "-cpu" image, if configured
                    if (build_cpu_tag) {
                        image_id = docker.build(image, "--no-cache --force-rm --build-arg tag=${base_cpu_tag} -f ${dockerfile} .")
                        // define additional docker_tag_cpu to mark it as "cpu" version
                        docker_tag_cpu = (docker_tag == "latest") ? "cpu" : (docker_tag + "-cpu")
                        image_cpu = docker_repository + "/" + image_name + ":" + docker_tag_cpu
                        sh "docker tag ${image} ${image_cpu}"
                        docker_ids.add(image_cpu)
                    }

                    // check that in the built (cpu or default) image, DEEPaaS API starts as expected
                    sh "git clone https://github.com/ai4os/ai4os-hub-check-artifact"
                    sh "bash ai4os-hub-check-artifact/check-artifact ${image}"
                    sh "rm -rf ai4os-hub-check-artifact"

                    docker_ids.add(image)

                    // finally, let's build "-gpu" image, if configured
                    if (build_gpu_tag) {
                        // define additional docker_tag_gpu to mark "gpu" version
                        docker_tag_gpu = (docker_tag == "latest") ? "gpu" : (docker_tag + "-gpu")
                        image = docker_repository + "/" + image_name + ":" + docker_tag_gpu
                        image_id = docker.build(image, "--no-cache --force-rm --build-arg tag=${base_gpu_tag}  -f ${dockerfile} .")
                        docker_ids.add(image)
                    }

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

