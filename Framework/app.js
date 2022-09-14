const fs = require('fs').promises
const { v1 } = require('uuid')
const path = require('path')
const util = require('util')
const exec = require('child_process').exec

const commandExecuter = async(cmd) => {
    const progress = exec(cmd)
    progress.stdout.on('data',(data) => {
        console.log(data)
    })
    progress.stdin.on('data',(data) => {
        console.log(data)
    })
    progress.on('exit',(code) => {
        console.log(`Process(PID : ${process.pid}) exit with code ${code}`)
    })
}

const command = async (args) => {
    const option = process.argv[2] || args[0]
    let config = await fs.readFile('./config.json')
    config = JSON.parse(config)
    const {
        img:imageName,
        mem:memoryLimit,
        env
    } = config
    switch(option){
        case 'buildenv':
            Object.entries(env).map(async([containerName,{ attendee }]) => {
                commandExecuter(`cd project/script && bash envinit.sh -i ${imageName} -n ${containerName} -c ${ attendee } -m ${ memoryLimit }`)
            })
            break
        case 'clearenv':
            Object.entries(env).map(async([containerName,_]) => {
                commandExecuter(`cd project/script && bash envclear.sh -n ${containerName}`)
            })
            break
        case 'clearimg':
            commandExecuter(`docker rmi ${imageName}`)
            break
        default:
            console.log("Not supported type of command")
    }
}

command()