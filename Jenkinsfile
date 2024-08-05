pipeline {
    agent any
    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose whether to apply or destroy the infrastructure')
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-2"
        TERRAFORM_DIR = "redis-terra-tool"
    }
    stages {
        stage('Checkout SCM') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/komalthakur853/redis-eval.git']])
            }
        }
        stage('Diagnostic Information') {
            steps {
                sh 'pwd'
                sh 'id'
                sh 'terraform version'
                sh 'ls -R'
            }
        }
        stage('Navigate to Terraform Directory') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh 'pwd'
                    sh 'ls -la'
                    sh 'cat main.tf || echo "main.tf not found"'
                }
            }
        }
        stage('Initializing Terraform') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh 'terraform init'
                }
            }
        }
        stage('Formatting Terraform Code') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh 'terraform fmt -check || true'
                }
            }
        }
        stage('Validating Terraform') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh 'terraform validate'
                }
            }
        }
        stage('Previewing the Infra using Terraform') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh 'terraform plan -out=tfplan'
                }
                input(message: "Are you sure to proceed with applying the changes?", ok: "Apply")
            }
        }
        stage('Applying Terraform Configuration') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
        stage('Destroy Terraform Infrastructure') {
            steps {
                script {
                    if (params.ACTION == 'destroy') {
                        input(message: "Do you want to destroy the infrastructure?", ok: "Destroy")
                        dir(env.TERRAFORM_DIR) {
                            sh 'terraform destroy -auto-approve'
                        }
                    } else {
                        echo 'Skipping destroy as per user choice.'
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        failure {
            echo 'The Pipeline failed :('
        }
    }
}
