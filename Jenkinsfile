pipeline {
    agent any

    environment {
        appVersion = ""
        // Replace with your actual registry username and repository name
        REGISTRY_USER = 'sreenivaschitti'
        IMAGE_NAME    = 'Roboshop-catalog'
        IMAGE_TAG     = "${env.BUILD_NUMBER}" // Uses the unique Jenkins build number as a tag
    }

    
    stages{
        stage('gitcheckout'){

             steps {

                git branch: 'main',
                url: 'https://github.com/sreenivaschitti/catalogue-unit_test.git'


                    }   

        }

        stage('Read Version'){
             steps {
                        script {
                            // Read and parse the package.json file
                            def packageJson = readJSON file: 'package.json'
                            
                            // Extract the version property
                            appVersion = packageJson.version
                            
                            // Output or use the version
                            echo "The application version is: ${appVersion}"
                    
                            }
                 }
        }


        stage('install dependencies'){

                    steps {

                        script {

                            sh """

                                npm install

                                """

                        }   

                    }

        }

        stage('unitest'){

            steps{

                script {

                     sh """
                        npm test
                     """   

                }    

            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool name: 'sonar-8'

                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Builds the image using the Dockerfile in your workspace root
                    sh "docker build -t ${REGISTRY_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                    
                }
            }
        }

        

    }
    
}

    

   

   

    

       



