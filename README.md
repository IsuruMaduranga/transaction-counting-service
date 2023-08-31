### Generate server cert
openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout serverpvtkey.key -out serverpubliccert.crt

### Add to APIM trust store
keytool -import -trustcacerts -alias servercert -file server.crt -keystore client-truststore.jks -storepass wso2carbon
