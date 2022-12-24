#!/bin/bash

echo "Good Morning!"
cal

if [ -f ~/TODO ]; then
	cat ~/TODO
else
	echo "THERE IS NO SUCH FILE"
fi
