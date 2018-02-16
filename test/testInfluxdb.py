# -*- coding: utf-8 -*-
"""Tutorial on using the InfluxDB client."""
# Taken from http://influxdb-python.readthedocs.io/en/latest/examples.html

import argparse

from influxdb import InfluxDBClient


def main(host='localhost', port=80):
    """Instantiate a connection to the InfluxDB."""
    user = 'root'
    password = 'root'
    dbname = 'cloudtrust-test'
    dbuser = 'test'
    dbuser_password = 'jdr'
    query = 'select * from cpu_load_short;'
    json_body = [
        {
            "measurement": "cpu_load_short",
            "tags": {
                "host": "server01",
                "region": "us-west"
            },
            "time": "2017-10-08T12:00:00Z",
            "fields": {
                "Float_value": 0.64,
                "Int_value": 3,
                "String_value": "Text",
                "Bool_value": True
            }
        }
    ]
    client = InfluxDBClient(host, port, user, password, dbname)

    print("Create database: " + dbname)
    client.create_database(dbname)

#    print("Create a retention policy")
#    client.create_retention_policy('awesome_policy', '3d', 3, default=True)

    print("Switch user: " + dbuser)
    client.switch_user(dbuser, dbuser_password)

    print("Write points: {0}".format(json_body))
    client.write_points(json_body)

    print("Querying data: " + query)
    result = client.query(query)

    print("Result: {0}".format(result))

    print("Switch user: " + user)
    client.switch_user(user, password)

    print("Drop database: " + dbname)
    client.drop_database(dbname)

def parse_args():
    """Parse the args."""
    parser = argparse.ArgumentParser(
        description='example code to play with InfluxDB')
    parser.add_argument('--host', type=str, required=False,
                        default='172.17.0.2',
                        help='hostname of InfluxDB http API')
    parser.add_argument('--port', type=int, required=False, default=80,
                        help='port of InfluxDB http API')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    main(host=args.host, port=args.port)
