pipeline {
  agent any
     tools {
       maven 'M2_HOME'
           }
 
  stages {
    stage('Git Checkout') {
      steps {
        echo 'This stage is to clone the repo from github'
        git branch: 'main', url: 'https://github.com/vinod-reddy-1998/star-agile-health-care'
                        }
            }
    stage('Create Package') {
      steps {
        echo 'This stage will compile, test, package my application'
        sh 'mvn package'
                          }
            }
    stage('Generate Test Report') {
      steps {
        echo 'This stage generate Test report using TestNG'
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '/var/lib/jenkins/workspace/CICD_JOB/target/surefire-reports', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                          }
            }
    stage('Create-Image') {
      steps {
        echo 'This stage will create a image of my application'
        sh 'docker build -t cbabu85/banking-apps:1.0 .'
                          }
            }
    stage('Docker-Login') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'Docker-Login-ID', passwordVariable: 'dockerpass', usernameVariable: 'dockerlogin')]) {
        sh 'docker login -u ${dockerlogin} -p ${dockerpass}'
              }
                          }
            }
    stage('Docker Push-Image') {
      steps {
        echo 'This stage will push my new image to the dockerhub'
        sh 'docker push cbabu85/banking-apps:1.0'
            }
                              }
    stage('CreateNew Server then configure and Deploy') {
      steps {
        withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'awscredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          dir('terraform-files') {
          sh 'sudo chmod 600 newkeypairaws.pem'
          sh 'terraform init'
          sh 'terraform validate'
          sh 'terraform apply --auto-approve'
                                        }            
                                   }
      
                               }
                   }
       }
}
  
