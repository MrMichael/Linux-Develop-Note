# 将当前目录下所有c文件进行UTF-8转码
find ./ -name *.c  -exec iconv -f GBK -t UTF-8 {} -o {} \;