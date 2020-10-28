exec 9<> /dev/tcp/10.55.2.194/2000  # 找不到端口会阻塞
echo 123456 >&9
cat <&9
exec 9>& -
exec 9<& -

exec 10<> /dev/udp/10.55.2.54/8081  # 找不到端口不会阻塞
echo 123456 >&10
cat <&10
exec 10>& -
exec 10<& -