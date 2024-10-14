pipeline {
  agent any
     tools {
       maven 'M2_HOME'
           }
 
  stages {
    stage('Git Checkout') {
      steps {
        echo 'This stage is to clone the repo from GitHub'
        git branch: 'master', url: 'https://github.com/vinod-reddy-1998/star-agile-health-care'
      }
    }
    
    stage('Create Package') {
      steps {
        echo 'This stage will compile, test, and package the application'
        sh 'mvn package'
      }
    }
    
    stage('Generate Test Report') {
      steps {
        echo 'This stage generates a Test report using TestNG'
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, 
                     reportDir: '/var/lib/jenkins/workspace/health_care/target/surefire-reports', 
                     reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: '', 
                     useWrapperFileDirectly: true])
      }
    }
    
    stage('Create-Image') {
      steps {
        echo 'This stage will create a Docker image of the application'
        sh 'docker build -t vinod179179/healthcare:1.0 .'
      }
    }
    
    stage('Docker-Login') {
    steps {
      echo 'This stage will login to docker hub'
      withDockerRegistry(credentialsId: '363a4878-c6db-4762-9d5e-c03d79fdea7f', url: 'https://registry.hub.docker.com/') {
        //withCredentials([usernamePassword(credentialsId: '0c9ebfff-840b-44d7-9519-28050e3a12a9', passwordVariable: 'docker-password', usernameVariable: 'docker-login')]) {
            //sh 'docker login -u ${docker-login} -p ${docker-pass}'
          //sh "echo \$docker-password | docker login --username \$docker-login --password-stdin"
  
        }
    }
}
 
    stage('Docker Push-Image') {
      steps {
        echo 'This stage will push the new Docker image to Docker Hub'
        sh 'docker push vinod179179/healthcare:1.0'
      }
    }
    stage('Provision Servers with Terraform') {
            steps {
                script {
                    echo 'Provisioning servers with Terraform'
                  //sh 'kubectl apply -f rbac.yaml' //check                   this             line
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    stage('Terraform destroy & apply for test workspace') {
      steps {
        sh 'terraform apply -auto-approve'
      }
    }
    stage('get kubeconfig') {
      steps {
        sh 'aws eks update-kubeconfig --region us-east-1 --name test-cluster'
        sh 'kubectl get nodes'
      }
    }
    stage('Deploying the application') {
      steps {
        sh 'kubectl apply -f app-deploy.yml'
        sh 'kubectl get svc'
      }
    }
    stage('Terraform Operations for Production workspace') {
      when {
        expression {
          return currentBuild.currentResult == 'SUCCESS'
        }
      }
      steps {
        script {
          sh '''
            terraform workspace select prod || terraform workspace new prod
            terraform init
            terraform plan
            terraform destroy -auto-approve
          '''
        }
      }
    }
    stage('Terraform destroy & apply for production workspace') {
      steps {
        sh 'terraform apply -auto-approve'
      }
    }
    stage('get kubeconfig for production') {
      steps {
      //  sh 'kubectl apply -f rbac.yaml'
        sh 'aws eks update-kubeconfig --region us-east-1 --name prod-cluster'
        sh 'kubectl get nodes'
      }
    }
    stage('Deploying the application to production') {
      steps {
        sh 'kubectl apply -f app-deploy.yml'
        sh 'kubectl get svc'
      }
    }
  }
}
