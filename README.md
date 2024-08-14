# demoSetups

   This project houses a few regularly used install scripts for tests and demos. 
   This script sets up docker and docker-compose and deploys nginx with certs as a front end for the swagger pet store image. 
   
   Below, you will also be shown how to install the deep packet inspection certificate from the firewall on the perimeter, to secure the traffic to ad from the internet.
   
   More about the swagger image here: https://petstore.swagger.io/

## Setup Instructions for petstore.io

### Follow these steps to get started:

### 1. Download the setup script using curl:
   ```bash 
   curl -L -o petstore.sh "https://github.com/ldjohn/demoSetups/raw/main/petstore.sh"
   ```
### 2. Download the setup script using wget:
   ```bash
   wget "https://github.com/ldjohn/demoSetups/raw/main/petstore.sh" -O petstore.sh
   ```
### 3. Make the script executable
   ```bash
   chmod +x petstore.sh
   ```
### 4. Please review the script before running it, especially with elevated privileges, then run the setup script:
   ```bash
   ./petstore.sh petstore.thisismydomain.com
   ```
### 5. All in one:
   ```bash
   curl -L -o petstore.sh "https://github.com/ldjohn/demoSetups/raw/main/petstore.sh" && chmod +x petstore.sh && ./petstore.sh petstore.thisismydomain.com
   ```


### 6. View your docker image information.
   To view the information about the various docker images running, use these commands: 
   For all docker images:
   ```bash
   sudo docker ps -a
   ```
   For the nginx image:
   ```bash
   sudo docker ps --filter name=nginx
   ```
   For the pet store image:
   ```bash
   sudo docker ps --filter name=petstore
   ```
   The output should be as follows: 
   ```bash
   CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS          PORTS                                                                      NAMES
   2081ad2df4d0   nginx:latest   "/docker-entrypoint.…"   15 hours ago   Up 15 minutes   0.0.0.0:80->80/tcp, :::80->80/tcp,       0.0.0.0:443->443/tcp, :::443->443/tcp   config_nginx_1
   ```
   This will provide you with the container ID, port info, and status for the image that it's running on.
   Ports inside or outside mapping, 0.0.0.0:80->80/tcp, are shown, as well as the listening IP. 
   The nginx proxies the requests sent to these ports towards the docker container running the swagger.io pet store image.

### 7. To view the logs on the nginx docker
   Paste the container ID in the following command:
   ```bash
   sudo docker logs --follow <Container ID>   <--- the nginx Container ID
   sudo docker logs --follow 2081ad2df4d0
   ```
   This can be done in one command:
   ```bash
   sudo docker logs --follow $(sudo docker ps --filter name=petstore --format "{{.ID}}")
   ```
   This provides you with a "tail" of the logs. You should then see similar logs for the requests you received. 
   Note the x-forwarded-for data in the xf field. No data results in a "-" being shown:

   ```bash
   44.193.52.244 - xf 169.137.110.235 - - [08/Jul/2024:18:20:40 +0000] "GET /api/v3/pet/findByStatus?status=available HTTP/1.1" 500 110 "-" "ML-Requester"
   52.54.207.214 - xf - - - [08/Jul/2024:18:23:29 +0000] "GET / HTTP/1.1" 200 3726 "-" "python-requests/2.27.1"
   44.222.240.237 - xf - - - [08/Jul/2024:18:28:10 +0000] "GET / HTTP/1.1" 200 3726 "-" "python-requests/2.27.1"
   54.196.233.2 - xf - - - [08/Jul/2024:18:33:14 +0000] "GET / HTTP/1.1" 200 3726 "-" "python-requests/2.27.1"
   35.175.107.134 - xf - - - [08/Jul/2024:18:38:07 +0000] "GET / HTTP/1.1" 200 3726 "-" "python-requests/2.27.1"
   141.98.83.197 - xf - - - [08/Jul/2024:18:41:26 +0000] "GET / HTTP/1.1" 200 3726 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.85 Safari/537.36 Edg/90.0.818.46"
   /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
   /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
   10-listen-on-ipv6-by-default.sh: info: IPv6 listen already enabled
   /docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
   /docker-entrypoint.sh: Configuration complete; ready for start up
   ```

### 8. Install the Fortigate Deep Packet Inspection certificate on the Ubutu server

Installing the FortiGate Deep Packet Inspection (DPI) certificate on your device is crucial to enable the firewall to inspect encrypted traffic, and detect and block compromised repository pulls or host traffic. This ensures enhanced security by intercepting potential threats that might bypass standard inspections.

**Steps:**
1. **Download the FortiGate CA SSL Certificate:**
   Log in to your FortiGate (or get from the Administrator), navigate to **System > Certificates** and download the CA certificate.
   It will probably be called `Fortinet_CA_SSL.cer`.
2. **Create a Directory and Move the Certificate:**
   On your Ubuntu machine, create a directory in your local root certificate store e.g., `/usr/local/share/ca-certificates/fortigate`.

   Move the downloaded certificate into this directory, ensuring the file extension is changed to `.crt`.

   It will also be a handy known location for systems to update the certs should the environment have automation like Ansible.

   ```
   sudo mkdir /usr/local/share/ca-certificates/fortigate
   sudo cp ~/Downloads/Fortinet_CA_SSL.cer /usr/local/share/ca-certificates/fortigate/Fortinet_CA_SSL.crt
   ```
   
4. **Update Certstore:**
   Run the following to install the certificate.
   ```
   sudo update-ca-certificates
   ```
   You should see this information:
   ```
   Updating certificates in /etc/ssl/certs...
   rehash: warning: skipping ca-certificates.crt, it does not contain exactly one certificate or CRL
   1 added, 0 removed; done.
   Running hooks in /etc/ca-certificates/update.d...
   done.
   ```

5. **Check your work:**
   Verify the installation by checking `/etc/ssl/certs/` or `/usr/local/share/ca-certificates/` for the Fortinet_CA_SSL.pem file, if that is what you called it.
   ```
   sudo ls /etc/ssl/certs/F*
   ```
   showing:
   ```
   /etc/ssl/certs/Fortinet_CA_SSL.pem
   ```
   You should be good to go when they enable DPI on your traffic and should have full protocol visibility for security purposes.
