import re
from scapy.packet import Packet, bind_layers
from scapy.fields import StrField
from scapy.layers.inet import TCP

class HTTPv1(Packet):
    name = "HTTPv1"
    fields_desc = [StrField("HTTP-payload", None, fmt="H")]


class HTTP(Packet):
    """
    Generic HTTP packet. Contains specific version of HTTP protocol
    """
    name = "HTTP"
    def guess_payload_class(self, payload):
        """
        Guess the version of HTTP protocol
        """
        try:
            #Only check if headers can be decoded as utf-8, since some HTTPv1 packets may contain binary data in the body
            payload.split(b'\r\n\r\n', 1)[0].decode('utf-8')
            return HTTPv1
        except:
            return None


#Bind to port 80
bind_layers(TCP, HTTP, dport=80)
bind_layers(TCP, HTTP, sport=80)


#For Proxy
bind_layers(TCP, HTTP, sport=8080)
bind_layers(TCP, HTTP, dport=8080)