const fs = require('fs').promises
const { get } = require('http')
const { exec } = require('node:child_process')  

class CommandParser{
    constructor(){

    }

    async getConfig(){
        const config = await fs.readFile('./config.json', 'utf-8', (err, json) => {
            if (err) {
                console.error(err)
            }
        })
        return JSON.parse(config)
    }

    async dynamicPortHandler(){
        const { env } = await this.getConfig()
        const requiredPortCount = Object.entries(env).reduce((acc,[_,v],idx) => {
            return acc += v.attendee
        },0)
        console.log(requiredPortCount)
    }

    async build(){
        
    }
    async remove(){

    }
}   


const cmd = new CommandParser()
cmd.dynamicPortHandler()