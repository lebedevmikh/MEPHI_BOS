#!/bin/bash

echo "dir:"
ls -l "$1" | grep ^d
echo "Usual files:"
ls -l "$1" | grep ^-
echo "Sym links:"
ls -l "$1" | grep ^l
echo "Sym devices:"
ls -l "$1" | grep ^c
echo "Block devices:"
ls -l "$1" | grep ^b
