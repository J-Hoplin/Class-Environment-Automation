const portparse = {...require('./portAllocation')}
const configclear = {...require('./clearConfig')}

const commandutils = async() => {
    const option = process.argv[2]
    switch(option){
        case 'port':
            portparse.portAllocater(process.argv[3],process.argv[4])
            break
        case 'port-owner':
            portparse.portAllocaterOwner(process.argv[3])
            break
        case 'clear-config':
            configclear.clearConfig()
            break  
    }
}

commandutils()