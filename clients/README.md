## Clients

This directory is where you drop your PKCS11 client packages for use by Dockerfiles and unitainer the CLI

## Adding DPoD Clients

To add DPoD Client simply go to your DPoD portal, create a Client Config, and extract the zip file to the `clients` director.  i.e. `cd clients ; unzip ~/Downloads/partition1.zip` 

Note that the name of your extracted client will need to be reflected in the `docker/Dockerfile` ADD commands.