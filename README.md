# demoSetups

This project houses a few regularly used install scripts for tests and demos

## Setup Instructions for petstore

### Follow these steps to get started:

 1. Download the setup script using curl:
   ```bash 
   curl -L -o petstore.sh "https://github.com/ldjohn/demoSetups/raw/main/petstore.sh"
   ```
 2. Download the setup script using wget:
   ```bash
   wget "https://github.com/ldjohn/demoSetups/raw/main/petstore.sh" -O petstore.sh
   ```
 3. Make the script executable
   ```bash
   chmod +x petstore.sh
   ```
 4. Please review the script before running it, especially with elevated privileges, then run the setup script:
   ```bash
   ./petstore.sh
   ```
 5. All in one:
   ```bash
   curl -L -o petstore.sh "https://github.com/ldjohn/demoSetups/raw/main/petstore.sh" && chmod +x petstore.sh && ./petstore.sh
   ```
