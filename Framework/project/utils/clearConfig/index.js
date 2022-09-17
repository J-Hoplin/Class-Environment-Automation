const path = require('path')
const fs = require('fs').promises
const splitString = "22/tcp ->"

const jsonpath = path.join(__dirname,'../../../config.json')

const getConfig = async() => {
    const file = await fs.readFile(jsonpath)
    return JSON.parse(file)
}

const saveConfig = async(config) => {
    fs.writeFile(jsonpath,JSON.stringify(config,null,4))
}

module.exports.clearConfig = async() => {
    const config = await getConfig()
    config.owner.ports = []
    const env = Object.entries(config.env).map(([key,value]) => {
        value.ports = []
        return [key,value]
    })
    config.env = Object.fromEntries(new Map(env))
    saveConfig(config)
}
