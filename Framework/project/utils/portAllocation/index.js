const path = require('path')
const fs = require('fs').promises
const splitString = "22/tcp ->"

const jsonpath = path.join(__dirname,'../../../config.json')

const portParser = async(ports) => {
    return ports
    .split(splitString)
    .filter(x => {
        return x
    })
    .map(x => {
        const [_,port] = x.split(':')
        return port
    })
}

const getConfig = async() => {
    const file = await fs.readFile(jsonpath)
    return JSON.parse(file)
}

const saveConfig = async(config) => {
    fs.writeFile(jsonpath,JSON.stringify(config,null,4))
}

// ports type : 22/tcp -> 0.0.0.0:5500922/tcp -> 0.0.0.0:5501022/tcp -> 0.0.0.0:55011
module.exports.portAllocater = async (className,ports) => {
    const portList = await portParser(ports)
    const config = await getConfig()
    config.env[className].ports = [...config.env[className].ports,...ports]
    saveConfig(config)
}

module.exports.portAllocaterOwner = async (ports) => {
    const portList = await portParser(ports)
    const config = await getConfig()
    config.owner.ports = [ ...config.owner.ports, ...portList]
    saveConfig(config)
}