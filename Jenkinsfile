node {
    def app

    stage('Clone repository') {

        checkout scm
    }

    ['stretch', 'bionic', 'jessie'].each {

        stage( "${it} | Build image" ) {
            app = docker.build("koha/koha-testing", "--no-cache --rm dists/${it}")
        }

        // stage( "${it} | Push image" ) {
        //     docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
        //         app.push( "master-${it}" );
        //     }
        // }
    }
}