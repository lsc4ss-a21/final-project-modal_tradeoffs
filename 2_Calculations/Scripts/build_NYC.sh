
#!/bin/bash

# build docker container and edit config file
# timeout 5m docker-compose up --build
docker ps -a
sudo mv valhalla.json custom_files/valhalla.json
docker restart $(docker ps -a -q)
docker ps -a

# run python script for auto, biking, and walking modes
for k in auto bicycle pedestrian;
    do
    n_batches=$(python3 create_data_batches_general.py NYC_input_$1.json $k NYC 40.7527 -73.9772)

    # process data in batches
    for ((i=0;i<n_batches;i++));
        do
            curl http://localhost:8002/sources_to_targets --data @NYC_city_center_batch_$1.json \
                >> NYC_city_center_instance_$1_$k.json
        done

    # copy over results to s3
    aws s3 cp NYC_city_center_instance_$1_$k.json s3://bl-buildings/Outputs/NYC_city_center_instance_$1_$k
    
    done

# copy over input for public transit
aws s3 cp s3://bl-buildings/Inputs/NYC_public_transit_batch_$1 NYC_public_transit_batch.json

input="NYC_public_transit_batch.json"
while IFS= read -r line
do
  echo "$line"
  curl http://localhost:8002/route? -d "$line" | jq -r .trip.summary >> NYC_public_transit_output_$1.json
done < "$input"
aws s3 cp NYC_public_transit_output_$1.json s3://bl-buildings/Outputs/NYC_public_transit_$1

echo All done

