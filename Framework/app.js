const fs = require('fs').promises
const { v1 } = require('uuid')
const path = require('path')
const util = require('util')
const exec = util.promisify(require('child_process').exec)

const command = async () => {
    const option = process.argv[2]
    let config = await fs.readFile('./config.json')
    config = JSON.parse(config)
    const {
        img:imageName,
        mem:memoryLimit,
        env
    } = config
    switch(option){
        case 'build':
            Object.entries(env).map(async([containerName,{ attendee }]) => {
                const { stdout,stderr } = await exec(`cd project/script && bash envinit.sh -i ${imageName} -n ${containerName} -c ${ attendee } -m ${ memoryLimit }`)
                stderr?console.error(stderr):console.log(stdout)
            })
            break
        case 'clear':
            Object.entries(env).map(async([containerName,_]) => {
                const { stdout,stderr} = await exec(`cd project/script && bash envclear.sh -n ${containerName}`)
                stderr?console.error(stderr):console.log(stdout)
            })
            break
        default:
            console.log("Not supported type of command")
    }
}

command()