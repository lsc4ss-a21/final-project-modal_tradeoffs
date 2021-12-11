
#!/bin/bash
sudo apt update
yes | sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
yes | sudo apt install docker-ce
sudo usermod -aG docker ${USER}
yes | sudo apt install docker-compose
yes | sudo apt install jq
yes | sudo apt install awscli
aws s3 cp 's3://bl-buildings/Setup scripts/docker-compose-NYC.yml' docker-compose.yml
aws s3 cp 's3://bl-buildings/Setup scripts/valhalla.json' valhalla.json
aws s3 cp 's3://bl-buildings/Setup scripts/build_NYC.sh' build.sh
aws s3 cp 's3://bl-buildings/Setup scripts/create_data_batches_general.py' create_data_batches_general.py
for i in 0 1 2 3;
    do
        aws s3 cp s3://bl-buildings/Inputs/NYC_$i NYC_input_$i.json
    done