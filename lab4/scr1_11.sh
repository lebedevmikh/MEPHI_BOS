#!/bin/bash

echo "Catalogs:"
ls -l | grep ^d
echo "Usual files:"
ls -l | grep ^-
echo "Sym links:"
ls -l | grep ^l
echo "Sym devices:"
ls -l | grep ^c
echo "block devices:"
ls -l | grep ^b
