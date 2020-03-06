package=${1}
export LC_ALL="C.UTF-8"

pip3 install -i http://pypi.jiangxingai.com/simple/ --trusted-host pypi.jiangxingai.com --upgrade edge_box_${package}
supervisorctl restart ${package}