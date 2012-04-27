
#!/bin/bash

filename=$1

repl_test()
{


    failed=0
    echo "Begin tests"
file=`expr $filename : '\(^.*\)'[.]`
 
mlang_input1=$(head -n 1 $filename)
echo "input 1 $mlang_input1"
        mlang_output1=$(echo $mlang_input1 | ./mlang | cut -b 1-2 --complement | head -n 1| sed 's/^ *//g' | sed 's/ *$//g')
echo "output 1 $mlang_output1"

mlang_input2=$(head -n 2 $filename | tail -1)
echo "input 2 $mlang_input2"
        mlang_output2=$(./mlang| echo $mlang_input2 | cut -b 1-2 --complement | head -n 1| sed 's/^ *//g' | sed 's/ *$//g')
echo "output 2 $mlang_output2"

exit $failed
    
}

repl_test $filename




