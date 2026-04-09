pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = "true"
        AWS_REGION       = "ap-south-1"
        TF_VERSION       = "1.5.0"
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Select the action to perform'
        )
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Skip terraform validation and formatting checks'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git log --oneline -5'
            }
        }

        stage('Pre-Checks') {
            steps {
                script {
                    echo "✓ Checking Terraform version..."
                    sh 'terraform version'
                    
                    echo "✓ Checking AWS credentials..."
                    sh 'aws sts get-caller-identity'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                    echo "Initializing Terraform..."
                    terraform init -reconfigure
                '''
            }
        }

        stage('Terraform Format & Validation') {
            when {
                expression { !params.SKIP_TESTS }
            }
            steps {
                sh '''
                    echo "Checking Terraform formatting..."
                    terraform fmt -recursive -check
                    
                    echo "Validating Terraform configuration..."
                    terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    if (params.ACTION == 'destroy') {
                        echo '📋 Planning Destroy...'
                        sh 'terraform plan -destroy -out=tfplan-destroy -lock-timeout=5m'
                    } else {
                        echo '📋 Planning Apply...'
                        sh 'terraform plan -out=tfplan -lock-timeout=5m'
                    }
                }
            }
        }

        stage('Review & Approve') {
            when {
                expression { params.ACTION != 'destroy' }
            }
            steps {
                script {
                    echo '''
                    ========================================
                    Review the terraform plan above
                    ========================================
                    '''
                    
                    timeout(time: 1, unit: 'HOURS') {
                        input message: 'Approve Terraform Apply?', ok: 'Deploy'
                    }
                }
            }
        }

        stage('Terraform Apply / Destroy') {
            steps {
                script {
                    if (params.ACTION == 'destroy') {
                        echo '🗑️ Executing Destroy...'
                        sh '''
                            echo "WARNING: This will destroy EKS cluster!"
                            terraform apply -auto-approve tfplan-destroy
                        '''
                    } else {
                        echo '🚀 Executing Apply...'
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }

        stage('Post-Deployment') {
            when {
                expression { params.ACTION != 'destroy' }
            }
            steps {
                script {
                    echo "✓ Cluster deployment successful!"
                    sh '''
                        echo "EKS Cluster Information:"
                        terraform output -json
                        
                        echo ""
                        echo "To configure kubectl, run:"
                        terraform output -raw configure_kubectl
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed!"
            cleanWs()
        }
        failure {
            echo "❌ Pipeline failed! Check logs above."
        }
        success {
            echo "✅ Pipeline completed successfully!"
        }
    }
}