const fs = require('fs').promises
const { v1 } = require('uuid')
const path = require('path')
const util = require('util')
const projectUtil = require('./project/utils')
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
    const ownerContainerName = `${imageName}owner`
    switch(option){
        case 'buildowner':
            await commandExecuter(`cd project/script && bash imageBuild.sh -i ${imageName} && bash ownerBuild.sh -i ${imageName} -n ${ownerContainerName} -m ${memoryLimit}`)
            break
        case 'buildenv':
            Object.entries(env).map(async([containerName,{ attendee }]) => {
                commandExecuter(`cd project/script && bash attendeeBuild.sh -i ${imageName} -n ${containerName} -c ${ attendee } -a ${ownerContainerName} -m ${ memoryLimit }`)
            })
            break
        case 'clearowner':
            commandExecuter(`docker stop ${ownerContainerName} && docker rm ${ownerContainerName}`)
            commandExecuter(`cd .. && rm -rf ${ownerContainerName}`)
            break
        case 'clearenv':
            Object.entries(env).map(async([containerName,_]) => {
                commandExecuter(`cd project/script && bash envclear.sh -n ${containerName}`)
            })
            commandExecuter(`node project/utils clear-config`)
            break
        case 'clearimg':
            commandExecuter(`docker rmi ${imageName}`)
            break
        default:
            console.log("Not supported type of command")
    }
}

command()