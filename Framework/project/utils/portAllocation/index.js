const path = require('path')
const fs = require('fs').promises
const splitString = "22/tcp ->"

// ports type : 22/tcp -> 0.0.0.0:5500922/tcp -> 0.0.0.0:5501022/tcp -> 0.0.0.0:55011
module.exports.portAllocater = async (className,ports) => {
    const portList = ports
    .split(splitString)
    .filter(x => {
        return x
    })
    .map(x => {
        const [_,port] = x.split(':')
        return port
    })
    const jsonpath = path.join(__dirname,'../../../config.json')
    let config = await fs.readFile(jsonpath)
    config = JSON.parse(config)
    config.env[className].ports = portList
    fs.writeFile(jsonpath,JSON.stringify(config,null,4))
}