import json
import math
import sys

fname = sys.argv[1]
mode = sys.argv[2]
city_name = sys.argv[3]
city_center_lat = float(sys.argv[4])
city_center_lon = float(sys.argv[5])

batch_size = 5000

f = open(fname)
buildings = json.load(f)

n_batches = math.ceil(len(buildings["sources"])/batch_size)

city_center = [{'lat': city_center_lat, 'lon': city_center_lon}]

for batch in range(n_batches):
    buildings_new = buildings.copy()
    buildings_new["targets"] = city_center
    buildings_new["sources"] = buildings["sources"][batch*batch_size:(batch+1)*batch_size]
    buildings_new["costing"] = mode
    
    with open(city_name + '_city_center_batch_' + str(batch) + ".json", 'w') as f1:
        json.dump(buildings_new, f1)
        
print(n_batches)