#!/usr/bin/env python3

import argparse
import configparser
import requests
import sys
import time
import urllib3

# comment this in production
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def parse():

    parser = argparse.ArgumentParser()
    parser.add_argument("--verbosity", help="increase output verbosity")
    args = parser.parse_args()
    if args.verbosity:
        print("verbosity turned on")

def config():
    config = configparser.ConfigParser()
    config.read('config.ini')
    print(config['DEFAULT']['src'])

def backup():
    hostname = 'ptfe-demo.jacobm.hashidemos.io'
    print("Starting backup")
    t1 = time.time()
    headers = {'Authorization': 'Bearer XXX'}
    body = { "password": "befit-brakeman-footstep-unclasp" }
    response = requests.post('https://%s/_backup/api/v1/backup' % hostname, 
                             json=body, 
                             headers=headers, 
                             stream=True, 
                             verify=False)

    # Throw an error for bad status codes
    response.raise_for_status()
    
    MBcount = 0
    with open('backup.bin', 'wb') as handle:
        for block in response.iter_content(1024):
            handle.write(block)
            MBcount += 1
            if MBcount % 50000 == 0:
                print("%s MB" % int(MBcount / 1000))
                pass
    delta = int(time.time() - t1)
    print("%s MB complete in %s seconds" % (int(MBcount / 1024), delta))

if __name__ == '__main__':
    parse()
    backup()
