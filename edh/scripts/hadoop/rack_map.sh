#!/bin/sh

RACK_DATA=/etc/edh/conf/topology.data

while [ $# -gt 0 ] ; do
  nodeArg=$1
  result="" 
  if [ -f $RACK_DATA ]; then
    exec< ${RACK_DATA} 
    while read line ; do
      ar=( $line ) 
      if [ "${ar[0]}" = "$nodeArg" ] ; then
        result="${ar[1]}"
      fi
    done 
  fi

  if [ -z "$result" ] ; then
    echo -n "/default "
  else
    echo -n "$result "
  fi
  shift 
done 
