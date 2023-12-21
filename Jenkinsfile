#!groovy
@Library("liveramp-base@v2") _

JENKINS_GITHUB_CREDENTIALS = 'ops-github--github.com'
JENKINS_COMMIT_MESSAGE = "[CI/Automation] Update README.md"

pipeline {

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '50', daysToKeepStr: '30'))
    }

    triggers {
        githubPush()
    }

    agent {
        label 'ubuntu-2004'
    }

    stages {
        stage('Generate Terraform Docs') {
            when {
                expression { env.GIT_BRANCH != 'main' && !jenkinsCommit() }
            }
            steps {
                script {
                    sh 'docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.17.0 markdown /terraform-docs > "README.md"'
                    testCommit()
                }
            }
        }
    }
}

boolean jenkinsCommit() {
    return getLastGitLog().startsWith(JENKINS_COMMIT_MESSAGE)
}

String getLastGitLog() {
    return sh(returnStdout: true, script: "git log -1 --pretty=%B")
}

void gitCommitAndPush() {
    sshagent(credentials: [JENKINS_GITHUB_CREDENTIALS]) {
        sh "git stash"
        sh "git fetch origin main:refs/remotes/origin/main"
        sh "git checkout main"
        sh "git pull origin main"
        sh "git stash pop"
        sh "git status"
        sh "git add ."
        sh "git commit -m \"" + JENKINS_COMMIT_MESSAGE + "\""
        sh "git push -u origin main"
    }
}

void testCommit() {
    sshagent(credentials: [JENKINS_GITHUB_CREDENTIALS]) {
        sh "git remote remove origin"
        sh "git remote add origin git@github.com:LiveRamp/terraform-google-portrait-engine-data-plane.git"
        sh "git config user.email \"jenkins@liveramp.com\""
        sh "git config user.name \"svc-jenkins\""

        sh "git stash"
        sh "git fetch origin minor/jenkinsfile:refs/remotes/origin/jenkinsfile"
        sh "git checkout jenkinsfile"
        sh "git pull origin jenkinsfile"
        sh "git stash pop"
        sh "git status"
        sh "git add ."
        sh "git commit -m \"" + JENKINS_COMMIT_MESSAGE + "\""
        sh "git push -u origin jenkinsfile"
    }
}