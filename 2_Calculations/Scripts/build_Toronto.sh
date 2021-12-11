
#!/bin/bash

# build docker container and edit config file
timeout 5m docker-compose up --build
docker ps -a
sudo mv valhalla.json custom_files/valhalla.json
docker restart $(docker ps -a -q)
docker ps -a

# run python script for batching
for j in 0 1 2;
    do
    n_batches=$(python3 create_data_batches.py ontario_input_$j.json)

    # process data in batches
    for ((i=0;i<n_batches;i++));
        do
            curl http://localhost:8002/sources_to_targets --data @ontario_city_center_batch_$i.json \
            >> output_city_center_instance_$1.json
        done
    done

# copy over results to s3
aws s3 cp output_city_center_instance_$1.json s3://bl-buildings/Outputs/output_city_center_instance_$1

# run python script for biking and walking modes
for k in auto bicycle pedestrian;
    do
    for j in 0 1 2;
        do
        n_batches=$(python3 create_data_batches_other_modes.py ontario_input_$j.json $k)

        # process data in batches
        for ((i=0;i<n_batches;i++));
            do
                curl http://localhost:8002/sources_to_targets --data @ontario_city_center_batch_$i.json \
                >> output_city_center_instance_$1_$k.json
            done
        done

    # copy over results to s3
    aws s3 cp output_city_center_instance_$1_$k.json s3://bl-buildings/Outputs/ontario_city_center_instance_$1_$k
    
    done

# copy over input for public transit
aws s3 cp s3://bl-buildings/Inputs/Ontario_public_transit_batch_$1 Ontario_public_transit_batch.json

input="Ontario_public_transit_batch.json"
while IFS= read -r line
do
  echo "$line"
  curl http://localhost:8002/route? -d "$line" | jq -r .trip.summary >> public_transit_output_$1.json
done < "$input"
aws s3 cp public_transit_output_$1.json s3://bl-buildings/Outputs/Ontario_public_transit_$1

echo All done

