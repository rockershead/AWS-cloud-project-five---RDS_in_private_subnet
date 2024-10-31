
# AWS-cloud-project-five---RDS_in_private_subnet
This project is an extension of AWS-cloud-project-four---RDS.
This project aims to create 2 lambda functions triggered by API_GATEWAY which will interact with a RDS table(mysql) hosted in AWS but this time the RDS database is in a private_subnet within a vpc that can be accessed by lambdas that are also within the same private subnet.



Architecture diagram is as follows:

![rds_in_private_subnet-without proxy drawio](https://github.com/user-attachments/assets/c28eaf09-2d13-4d6f-9127-d6047e0efa50)



# Steps to deploy in aws
- in my case I am using a linux terminal
- make sure access_keys and secret key are all configured in the terminal 
- cd to each of the lambda folders, create_user and get_users
- npm install
- Under create_user folder, command:zip -r create_user.zip .
- Under get_users folder, command:zip -r get_user.zip .
- cd into terraform folder
- ./run_script.sh
