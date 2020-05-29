def xor_crypt_string(data, key='s0m3K3y', encode=False, decode=False):
from itertools import izip, cycle
import base64
if decode:
data = base64.decodestring(data)
xored = ''.join(chr(ord(x) ^ ord(y)) for (x,y) in izip(data, cycle(key)))
if encode:
return base64.encodestring(xored).strip()
return xored
 
 
secret_data = "111000101011111001010010000110110110000110100"
print xor_crypt_string(secret_data, encode=True)
print xor_crypt_string(xor_crypt_string(secret_data, encode=True), decode=True)
