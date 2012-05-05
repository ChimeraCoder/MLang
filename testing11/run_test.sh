#! /bin/sh

#A very basic, very hacky unit testing framework

filename=$1

repl_test()
{
    failed=0
    echo "Begin tests"
    while read p; do
        mlang_input=$(echo $p | cut -d '|' -f1)
        mlang_output=$(echo $mlang_input | ./mlang  | cut -b 1-2 --complement | head -n 1| sed 's/^ *//g' | sed 's/ *$//g')
        desired_ouput=$(echo $p | cut -d '|' -f2 | sed 's/^ *//g' | sed 's/ *$//g')
        if [ "$mlang_output" = "$desired_ouput" ]
        then
            echo ".............passed $p"
        else
            echo "!FAILED: $mlang_input produced $mlang_output instead of $desired_ouput"
            failed=`expr $failed + 1`
        fi
    done < $filename
    exit $failed
    
}

repl_test $filename
