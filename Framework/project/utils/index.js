const portparse = {...require('./portAllocation')}

const commandutils = async() => {
    const option = process.argv[2]
    switch(option){
        case 'port':
            portparse.portAllocater(process.argv[3],process.argv[4])
            break
    }
}

commandutils()