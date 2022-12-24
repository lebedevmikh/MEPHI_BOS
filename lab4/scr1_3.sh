#!/bin/bash

echo $(env) | tr ":" "\n" | sort
