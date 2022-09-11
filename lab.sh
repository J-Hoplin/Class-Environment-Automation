ex="osclasss"
state=1

for i in $(docker images | grep os | awk '{print $1}')
do
    echo ${i}
    if [[ ${i}=${ex} ]]
    then
        state=0
        break
    fi
done

echo ${state}