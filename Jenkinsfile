pipeline {
  agent any
 parameters {
        string(name: 'name_container', defaultValue: 'proyecto-dev', description: 'nombre del docker')
        string(name: 'name_imagen', defaultValue: 'iproyecto-dev', description: 'nombre de la imagen')
        string(name: 'tag_imagen', defaultValue: 'latest', description: 'etiqueta de la imagen')
        string(name: 'puerto_imagen', defaultValue: '9000', description: 'puerto a publicar')
    }
    environment {
        name_final = "${name_container}${tag_imagen}${puerto_imagen}"
    }
    tools {
        nodejs "NodeJS"
    }
    stages {
        stage('test') {
            steps {
                script {
                    sh "npm -v"
                    sh "node -v"
                    sh "npm i && npm cache clean --force"
                    sh "npm run test:unit"
                }
            }
        }
          stage('stop/rm') {

            when {
                expression { 
                    DOCKER_EXIST = sh(returnStdout: true, script: 'echo "$(docker ps -q --filter name=${name_final})"').trim()
                    return  DOCKER_EXIST != '' 
                }
            }
            steps {
                script{
                    sh ''' 
                         docker stop ${name_final}
                    '''
                    sh ''' 
                         docker rm -f ${name_final}
                    '''
                    }
                }                                  
            }
        stage('build') {
            steps {
                script{
                    sh ''' 
                    docker build    -t ${name_imagen}:${tag_imagen} .
                    '''
                    }
                    
                }                                  
            }
            stage('run') {
            steps {
                script{
                    sh ''' 
                        docker run -dp ${puerto_imagen}:80 --name ${name_final} ${name_imagen}:${tag_imagen}
                    '''
                    }
                    
                }                                  
            }          
            stage('generar build') {
                steps {
                    script {
                        sh "npm run build"
                    }
                }
            }
            stage('guardando artefacto') {
                steps {
                    dir("vue-docker-example"){
                        sh 'aws s3 cp --recursive dist/ s3://devexamplevue/dist/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers'
                    }
                }
            }
        }   
    }
