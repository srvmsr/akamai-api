node {

stage ('Parameter') {

  properties([
    parameters([
        string(name: 'DEPLOY_ENV', defaultValue: 'TESTING', description: 'The target environment', )
           ])
    ])

  properties([
    parameters([
        choice(choices: 'AkamaiList1\nAkamaiList2\nAkamaiList3', 
        description: '', name: 'networkList')]), disableConcurrentBuilds(), pipelineTriggers([])
        ])

}

stage ('echo') {
  echo "$networkList"
}


}

