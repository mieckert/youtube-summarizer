#!/bin/bash

rsync -avz -e "ssh -i <path_to_key>" ./audio-summary <user>@<host>:<full_path>
