node {
    def app

    stage('Clone repository') {

        checkout scm
    }

    ['buster'].each {

        stage( "${it} | Build image" ) {
            app = docker.build("koha/koha-testing", "--no-cache --rm -f dists/${it}/Dockerfile .")
        }

        if ( it == 'stretch' ) {
            stage( "${it} | Push image" ) {
                docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                    app.push( "master" );
                }
            }
        } else {
            stage( "${it} | Push image" ) {
                docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                    app.push( "master-${it}" );
                }
            }
        }
    }
}
