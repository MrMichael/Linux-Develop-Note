#! /bin/bash

if [ "${UID}" -ne 0 ]
then
  echo -e "\033[31m please use root privilege to run this script \033[0m"
  exit 1
fi

export LC_ALL="en_US.UTF-8"

file_path=(/app/init /etc/supervisor/conf.d/worker/ /app/platform/pkg/settings/worker/)

# rm conf
for p in ${file_path[@]}; do
    rm -r ${p}
done

# rm containers

#find all containers id
index=0
for id in `docker container ls | awk 'NR>1{print $1}'`
do
    container_list[$index]="$id"
    ((index++))
done

#rm container which include service_id, adm-agent
for container in ${container_list[*]}
do
        data=`docker inspect $container`
        if [ `python3 scripts/is_platform_container.py $data` = "True" ]
           then
		docker rm -f $container
                echo "rm $container"
        fi

done


supervisorctl reread
supervisorctl update

