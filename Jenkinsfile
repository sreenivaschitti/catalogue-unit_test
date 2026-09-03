pipeline {
    agent any

    environment {
        appVersion = ""
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
    }
    
}

    

   

   

    

       



