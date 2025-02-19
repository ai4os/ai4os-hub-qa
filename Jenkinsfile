// vim: filetype=groovy

@Library([
    'github.com/indigo-dc/jenkins-pipeline-library@release/2.1.1',
]) _


def projectConfig

pipeline {
    agent {
        label 'docker'
    }

    environment {
        // Remove .git from the GIT_URL link
        REPO_URL = "${env.GIT_URL.endsWith(".git") ? env.GIT_URL[0..-5] : env.GIT_URL}"
        REPO_NAME = "${REPO_URL.tokenize('/')[-1]}"
        // Get list of AI4OS Hub repositories from "modules-catalog/.gitmodules"
        MODULES_CATALOG_URL = "https://raw.githubusercontent.com/ai4os-hub/modules-catalog/master/.gitmodules"
        MODULES = sh (returnStdout: true, script: "curl -s ${MODULES_CATALOG_URL}").trim()
        METADATA_FILE = "metadata.json"
    }

    stages {
        stage('Metadata tests') {
            parallel {
                stage('AI4OS Hub metadata V1 validation') {
                    when {
                        expression {env.MODULES.contains(env.REPO_URL)}
                        // all repos suppose to have ai4-metadata.yml,
                        // metadata.json is not mandatory vk@250219
                        expression {fileExists("metadata.json")}
                    }
                    agent {
                        docker {
                            image 'ai4oshub/ci-images:python3.12'
                        }
                    }
                    steps {
                        script {
                            env.METADATA_FILE = "metadata.json"
                            sh "ai4-metadata validate --metadata-version 1.0.0 metadata.json"
                        }
                    }
                }
                stage('AI4OS Hub metadata V2 validation (JSON)') {
                    when {
                        expression {env.MODULES.contains(env.REPO_URL)}
                        // Check if metadata.json is present in the repository
                        expression {fileExists("ai4-metadata.json")}
                    }
                    agent {                 
                        docker {
                            image 'ai4oshub/ci-images:python3.12'
                        }
                    }
                    steps {
                        script {
                            // Check if metadata files are present in the repository
                            if (!fileExists("ai4-metadata.json")) {
                                error("ai4-metadata.json file not found in the repository")
                            }
                            if (fileExists("ai4-metadata.yml")) {
                                error("Both ai4-metadata.json and ai4-metadata.yml files found in the repository")
                            }
                            env.METADATA_FILE = "ai4-metadata.json"
                        }
                        script {
                            sh "ai4-metadata validate --metadata-version 2.0.0 ai4-metadata.json"
                        }
                    }
                }
                stage('AI4OS Hub metadata V2 validation (YAML)') {
                    when {
                        expression {env.MODULES.contains(env.REPO_URL)}
                        // Check if metadata.json is present in the repository
                        expression {fileExists("ai4-metadata.yml")}
                    }
                    agent {                 
                        docker {
                            image 'ai4oshub/ci-images:python3.12'
                        }
                    }
                    steps {
                        script {
                            if (!fileExists("ai4-metadata.yml")) {
                                error("ai4-metadata.yml file not found in the repository")
                            }
                            if (fileExists("ai4-metadata.json")) {
                                error("Both ai4-metadata.json and ai4-metadata.yml files found in the repository")
                            }
                        }
                        script {
                            env.METADATA_FILE = "ai4-metadata.yml"
                            println("[INFO] Using ${env.METADATA_FILE} metadata file")
                            sh "ai4-metadata validate --metadata-version 2.0.0 ai4-metadata.yml"
                        }
                    }
                }
                stage("License validation") {
                    steps {
                        script {
                            // Check if LICENSE file is present in the repository
                            if (!fileExists("LICENSE")) {
                                error("LICENSE file not found in the repository")
                            }
                        }
                    }
                }
            }
        }

        stage("Check if only metadata files have changed") {
            steps {
                script {
                    // Check if only metadata files have been changed

                    // Get the list of changed files. We need to check if the
                    // change only affects metadata files but not only with
                    // previous commit, but with previos successful commit
                    // See https://github.com/ai4os/ai4os-hub-qa/issues/16
                    // If GIT_PREVIOUS_SUCCESSFUL_COMMIT fails
                    // (e.g. First time build, commits were rewritten by user),
                    // we fallback to last commit
                    try {
                        changed_files = sh (returnStdout: true, script: "git diff --name-only HEAD ${env.GIT_PREVIOUS_SUCCESSFUL_COMMIT}").trim()
                    } catch (err) {
                        println("[WARNING] Exception: ${err}")
                        println("[INFO] Considering changes only in the last commit..")
                        changed_files = sh (returnStdout: true, script: "git diff --name-only HEAD^ HEAD").trim()
                    }

                    // we need to check here if the change only affects any of the metadata files, but not the code
                    // we can't use "git diff --name-only HEAD^ HEAD" as it will return all files changed in the commit
                    // we need to check if the metadata files are present in the list of changed files

                    need_build = true

                    // Check if metadata files are present in the list of changed files
                    if (changed_files.contains("metadata.json") || changed_files.contains("ai4-metadata.json") || changed_files.contains("ai4-metadata.yml")) {
                        // Convert to an array and pop items
                        changed_files = changed_files.tokenize()
                        changed_files.removeAll(["metadata.json", "ai4-metadata.json", "ai4-metadata.yml"])
                        // now check if the list is empty
                        if (changed_files.size() == 0) {
                            need_build = false
                        }
                    }
                }
            }
        }

        // Let's run user tests for all repos
        stage("User-defined module pipeline job") {
            when {
                anyOf {
                    expression {need_build}
                    triggeredBy 'UserIdCause'
                }   
            }
            steps {
                //sh 'printenv'
                script {
                    build(job: "/AI4OS-HUB-TEST/" + env.JOB_NAME.drop(10))
                }
            }
        }

        stage("Docker build and delivery") {
            when {
                expression {env.MODULES.contains(env.REPO_URL)}

                anyOf {
                    branch 'cicd'
                    branch 'main'
                    branch 'master'
                    branch 'test'
                    branch 'dev'
                    branch 'release/*'
                }
                anyOf {
                    expression {need_build}
                    triggeredBy 'UserIdCause'
                }
            }

            stages {
                stage("Docker Variable initialization") {
                    environment {
                        AI4OS_REGISTRY_CREDENTIALS = credentials('AIOS-registry-credentials')
                    }
                    steps {
                        script {
                            withFolderProperties{
                                docker_registry = env.AI4OS_REGISTRY
                                docker_repository = env.AI4OS_REGISTRY_REPOSITORY
                            }
                            docker_ids = []
                            
                            docker_registry_credentials = env.AI4OS_REGISTRY_CREDENTIALS
        
                            // Check here if variables exist
                        }
                    }
                }

                stage('AI4OS Hub Docker images build') {
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

                            println("[INFO] (2) Using ${env.METADATA_FILE} metadata file")
                            image_name = env.REPO_NAME
                            // get docker image name from ai4-metadata.yml
                            //if (env.METADATA_FILE == "ai4-metadata.yml") {
                                //meta = readYAML file: env.METADATA_FILE
                                //image_name = meta["links"]["docker_image"].split("/")[1]
                            //}

                            // get docker image name from metadata.json
                            if (env.METADATA_FILE == "metadata.json" && fileExists("metadata.json")) {
                                meta = readJSON file: env.METADATA_FILE
                                image_name = meta["sources"]["docker_registry_repo"].split("/")[1]
                            }
                            // get docker image name from ai4-metadata.json
                            if (env.METADATA_FILE == "ai4-metadata.json" && fileExists("ai4-metadata.json")) {
                                meta = readJSON file: env.METADATA_FILE
                                image_name = meta["links"]["docker_image"].split("/")[1]
                            }

                            // use preconfigured in Jenkins docker_repository
                            // XXX may confuse users? (e.g. expect xyz/myimage, but we push to ai4hub/myimage)
                            image = docker_repository + "/" + image_name + ":" + docker_tag

                            // build docker images
                            // by default we expect Dockerfile name and location in the git repo root
                            def dockerfile = "Dockerfile"
                            def base_cpu_tag = ""
                            def base_gpu_tag = ""
                            def build_cpu_tag = false
                            def build_gpu_tag = false
                            // try to load constants if defined in user's repository ($jenkinsconstants_file has to be in the repo root)
                            jenkinsconstants_file = "JenkinsConstants.groovy"
                            try {
                                def constants = load jenkinsconstants_file
                                // $jenkinsconstants_file may have all constants or only "dockefile" or only both base_cpu|gpu_tag:
                                try {
                                    dockerfile = constants.dockerfile
                                } catch (e) {}
                                // let's define that if used, both "base_cpu_tag" && "base_gpu_tag" are required:
                                try {
                                    base_cpu_tag = constants.base_cpu_tag
                                } catch (e) {}
                                try {
                                    base_gpu_tag = constants.base_gpu_tag
                                } catch (e) {}
                                if (!base_cpu_tag && !base_gpu_tag) {
                                    throw new Exception("Neither \"base_cpu_tag\" nor \"base_gpu_tag\" is defined. Using default tag from ${dockerfile}")
                                }
                                if (!base_cpu_tag || !base_gpu_tag) {
                                    throw new Exception("Check ${jenkinsconstants_file}: If separate tags for CPU and GPU are needed, both \"base_cpu_tag\" and \"base_gpu_tag\" are required!")
                                }
                                // if no Exception so far, allow building "-cpu" and "-gpu" versions
                                build_cpu_tag = true
                                build_gpu_tag = true
                            } catch (err) {
                                // if $jenkinsconstants_file not found or one of base_cpu|gpu_tag is not defined or none of them, build docker image with default params
                                println("[WARNING] Exception: ${err}")
                                println("[INFO] Using default parameters for Docker image building. Using ${env.BRANCH_NAME} branch")
                                image_id = docker.build(image, 
                                                        "--no-cache --force-rm --build-arg branch=${env.BRANCH_NAME} -f ${dockerfile} .")
                            }
                            // build "-cpu" image, if configured
                            if (build_cpu_tag) {
                                image_id = docker.build(image, 
                                                        "--no-cache --force-rm --build-arg branch=${env.BRANCH_NAME} --build-arg tag=${base_cpu_tag} -f ${dockerfile} .")
                                // define additional docker_tag_cpu to mark it as "cpu" version
                                docker_tag_cpu = (docker_tag == "latest") ? "cpu" : (docker_tag + "-cpu")
                                image_cpu = docker_repository + "/" + image_name + ":" + docker_tag_cpu
                                sh "docker tag ${image} ${image_cpu}"
                                docker_ids.add(image_cpu)
                            }

                            // check that in the built image (cpu or default), DEEPaaS API starts as expected
                            // EXCLUDE "cicd" branch
                            // do it with only "cpu|default" image: 
                            // a) can stop before proceeding with "gpu" version b) "gpu" may fail without GPU hardware anyway
                            if (env.BRANCH_NAME != 'cicd') {
                                sh "rm -rf ai4os-hub-check-artifact"
                                sh "git clone https://github.com/ai4os/ai4os-hub-check-artifact"
                                sh "bash ai4os-hub-check-artifact/check-artifact ${image}"
                                sh "rm -rf ai4os-hub-check-artifact"
                            }

                            docker_ids.add(image)

                            // finally, build "-gpu" image, if configured
                            if (build_gpu_tag) {
                                // define additional docker_tag_gpu to mark "gpu" version
                                docker_tag_gpu = (docker_tag == "latest") ? "gpu" : (docker_tag + "-gpu")
                                image = docker_repository + "/" + image_name + ":" + docker_tag_gpu
                                image_id = docker.build(image,
                                                        "--no-cache --force-rm --build-arg branch=${env.BRANCH_NAME} --build-arg tag=${base_gpu_tag} -f ${dockerfile} .")
                                docker_ids.add(image)
                            }

                        }
                    }
                }
                stage('AI4OS Hub Docker delivery to registry') {
                    when {
                        expression {docker_ids.size() > 0}
                    }
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
            }
        }

        stage("Update Catalog page") {
            when {
                expression {env.MODULES.contains(env.REPO_URL)}
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'release/*'
                    triggeredBy 'UserIdCause'
                }
            }
            environment {
                // AI4OS-PAPI-refresh-secret has to be set in Jenkins
                AI4OS_PAPI_SECRET = credentials('AI4OS-PAPI-refresh-secret')
            }
            steps {
                script {
                    // extract REPO_NAME from REPO_URL (.git already removed from REPO_URL)
                    REPO_NAME = "${REPO_URL.tokenize('/')[-1]}"
                    // build PAPI route to refresh the module
                    withFolderProperties {
                        // retrieve PAPI_URL and remove trailing slash "/" (AI4OS_PAPI_URL is set in Jenkins)
                        AI4OS_PAPI_URL = "${env.AI4OS_PAPI_URL.endsWith("/") ? env.AI4OS_PAPI_URL[0..-2] : env.AI4OS_PAPI_URL}"
                    }
                    PAPI_REFRESH_URL = "${AI4OS_PAPI_URL}/v1/catalog/modules/${REPO_NAME}/refresh"
                    // have to use "'" to avoid injection of credentials
                    // see https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#handling-credentials
                    CURL_PAPI_CALL = "curl -si -X PUT ${PAPI_REFRESH_URL} -H 'accept: application/json' " + 
                        '-H "Authorization: Bearer $AI4OS_PAPI_SECRET"'
                    response = sh (returnStdout: true, script: CURL_PAPI_CALL).trim()
                    status_code = sh (returnStdout: true, script: "echo '${response}' |grep HTTP | awk '{print \$2}'").trim().toInteger()
                    if (status_code != 200 && status_code != 201) {
                        error("Returned status code = $status_code when calling $PAPI_REFRESH_URL")
                    }
                }
            }
        }
        stage('Update OSCAR services') {
            when {
                expression {env.MODULES.contains(env.REPO_URL)}
            }
            agent {                 
                docker {
                    image 'ai4oshub/ci-images:python3.12'
                }                
            }
            environment {
                OSCAR_SERVICE_TOKEN = credentials('oscar-service-token')
            }

            steps {
                withFolderProperties {
                    script {
                        dir("_ai4os-hub-qa") {
                            git branch: "master",
                            url: 'https://github.com/ai4os/ai4os-hub-qa'
                        }
    
                        sh "./_ai4os-hub-qa/scripts/oscar_update.py"
                    }
                }
            }
        }
    }
    post {
        // Clean after build
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])
        }
    }
}

