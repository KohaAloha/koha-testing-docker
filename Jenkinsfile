
def stringsToEcho =  [ 'jessie','stretch-mojo7','bullseye','buster-kc','buster-mojo8','stretch']


def stepsForParallel = stringsToEcho.collectEntries {
    ["echoing ${it}" : transformIntoStep(it)]
}


parallel stepsForParallel


def transformIntoStep(it) {

    return {

//--------------------
node {
    def app

    stage('Clone repository') {

        checkout scm
    }

        stage( "${it} | Build image" ) {
            app = docker.build("kohaaloha/koha-testing-par", "--no-cache --rm -f dists/${it}/Dockerfile .")
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

//--------------------

    }
}

