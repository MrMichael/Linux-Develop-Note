# -*-coding:utf-8-*-
import sys

def is_contain(data):
    if len(data) <= 1:
        return

    # transfer to python format
    data = "".join(data[1:]).replace("true", "True").replace("false", "False").replace("null", "None")

    data_list = eval(data)
    for data in data_list:
        if 'Config' in data and 'Labels' in data['Config']:
            labels = data['Config']['Labels']
            if 'service_id' in labels or ('owner' in labels and labels['owner'] == 'adm-agent'):
                print("True")
                return
    print("False")


is_contain(sys.argv)

