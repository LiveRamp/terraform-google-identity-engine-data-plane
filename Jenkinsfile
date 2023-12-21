#!groovy
@Library("liveramp-base@master") _

JENKINS_GITHUB_CREDENTIALS = 'ops-github--github.com'
JENKINS_GITHUB_API_TOKEN_SECRET_ID = 'ops-github-api-token'

JENKINS_GITHUB_API_TOKEN = string(credentialsId: JENKINS_GITHUB_API_TOKEN_SECRET_ID, variable: 'GIT_ACCESS_TOKEN')

agentLabel = 'ubuntu-2004'

pipeline {

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '50', daysToKeepStr: '30'))
    }


    triggers {
        githubPush()
    }

    agent {
        label agentLabel
    }

    stages {

        stage('Generate Terraform Docs') {
            when {
                expression { env.GIT_BRANCH == 'main' }
            }
            steps {
                // TODO
            }
        }
    }
}