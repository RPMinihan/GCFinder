require 'socket'
require 'ipaddr'
require 'timeout'

MULTICAST_ADDR = "239.255.250.250" 
PORT = 9131
ip =  IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new("0.0.0.0").hton

sock = UDPSocket.new
sock.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip)
sock.bind(Socket::INADDR_ANY, PORT)

ipregex = /([0-9]{1,3}\.){3}[0-9]{1,3}/
macregex = /00\w+/
makeregex = /<-Model\w+/

begin
  timeout(60) do
    msg, info = sock.recvfrom(1024)
    mymsg = msg.split('<')
    found_ip =  mymsg[7].match(ipregex)[0]
    if mymsg[4] =~ /(\w+)\>$/ then found_model =  $1 end
    found_mac =  mymsg[1].match(macregex)[0]
    if mymsg[5] =~ /(\w+-\w+-\w+)\>$/ then found_revision = $1 end
    puts "IP Address: #{found_ip}"
    puts "Configuration URL: http://#{found_ip}"
    puts "Model: #{found_model}"
    puts "Mac Address: #{found_mac}"
    puts "Firmware Version: #{found_revision}"
  end
rescue Timeout::Error
  puts "No Global Cache` units detected."
end
gets
