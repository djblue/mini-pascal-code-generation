#!/bin/bash

# options
# -f show only fails # -p show only pass
# -v show diff (verbose)
# -g <pattern> only run tests that match pattern
# -s show source for errors
# -m always show make output
# -d specify test directory (default is tests)

# colors
green () { echo -e "\033[0;32m$1\033[0;0m"; }
red   () { echo -e "\033[0;31m$1\033[0;0m"; }

# stats
fail=0
pass=0

showpass=1
showfail=1
showerrors=0
showsource=0
showmake=0
grepstr=''
dieonefail=0

TESTDIR='tests'
TIMEOUT=1s

# parse flags
while getopts fpvsmg:d:tl opt; do
  case "$opt" in
    f) showpass=0 ;;
    p) showfail=0 ;;
    v) showerrors=1 ;;
    s) showsource=1 ;;
    m) showmake=1 ;;
    g) grepstr=$OPTARG ;;
    d) TESTDIR=$OPTARG ;;
    t) TIMEOUT=$OPTARGS ;;
    l) dieonefail=1 ;;
  esac
done

# only show make output if there is a problem
makeoutput=$(make)
if [ "$?" != "0" ]; then
  echo $makeoutput
  exit 2
elif [ "$showmake" == "1" ]; then
  echo $makeoutput
fi

TEMP_FILE=temp.mips

for f in $(ls $TESTDIR/*.p | grep "$grepstr"); do
  node pascal.js $f > $TEMP_FILE
  # tail to get rid of annoying header
  output=$(timeout $TIMEOUT spim -file $TEMP_FILE 2> /dev/null | tail -n +6 | diff --context $f.out -)

  if [ $? == 0 ]; then
    pass=$((pass+1))
    if [ "$showpass" == "1" ]; then
      echo "$(green PASS): $f.out"
    fi
  else
    fail=$((fail+1))
    if [ "$showfail" == "1" ]; then
      echo "$(red FAIL): $f"
      if [ "$showerrors" == "1" ]; then
        echo "$output"
      fi
      if [ "$showsource" == "1" ]; then
        # show line numbers
        cat -n "$f"
      fi
    fi
    if [ "$dieonefail" == "1" ]; then
      exit 1
    fi

  fi

  if [ -f $f.js ]; then
    node pascal.js $f --classes > output.json
    node $f.js
    rm output.json
  fi

done

rm $TEMP_FILE

echo "=== Totals =============================="
echo "$(green PASS): $pass"
echo "$(red FAIL): $fail"
echo "========================================="

# non zero exit code for failure
if [ "$fail" != "0" ]; then
  exit 2
fi
