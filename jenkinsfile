pipeline {
    agent any
    stages{
        stage('Build Maven'){
            steps{
                git url:'https://github.com/vinod-reddy-1998/cicd/', branch: "master"
               sh 'mvn clean install'
            }
        }
        stage('Build docker image'){
            steps{
                script{
                    sh 'docker build -t vinod179179/healthcare:1.0 .'
                }
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
          stage('Docker login') {
            steps {
                //withCredentials([usernamePassword(credentialsId: 'dockerhub-pwd', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                withDockerRegistry(credentialsId: '363a4878-c6db-4762-9d5e-c03d79fdea7f', url: 'https://registry.hub.docker.com/') {
          
                }
            }
        }
        
         stage('Docker Push-Image') {
      steps {
        echo 'This stage will push the new Docker image to Docker Hub'
        sh 'docker push vinod179179/healthcare:1.0'
      }
    }
        stage('Deploy to k8s'){
            when{ expression {env.GIT_BRANCH == 'master'}}
            steps{
                script{
                     kubernetesDeploy (configs: 'deploymentservice.yaml' ,kubeconfigId: 'k8sconfigpwd')
                   
                }
            }
        }
    }
}
