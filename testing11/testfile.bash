
#!/bin/bash

echo "testing begins.."
echo "cleaning.."
 rm ./tests/*.result
 rm ./*.result	

for filename in ./tests/*.mlang
do
  
	file=`expr $filename : '\(^.*\)'[.]`

	desired_output="`cat $file.output`"

	echo "testing $file"

	while read p; do
	mlang_input=$(echo $p | cut -d '|' -f1)
	echo $mlang_input | ./mlang | cut -b 1-2 --complement | head -n 1| sed 's/^ *//g' | sed 's/ *$//g' >> $file.result
done < $filename
	mlang_result="`cat $file.result`"  

              if [ "$mlang_result" = "$desired_output" ];
              then
		echo "desired output is $desired_output"
		echo "output generated is $mlang_result"
		echo ".............passed test"
  	      else
		echo "testing $p"
		echo "desired output is $desired_output"
		echo "output generated is $mlang_result"
		echo "!FAILED: $input produced $mlang_result instead of $desired_output"
              fi
    
done
for filename in ./*.read
do
  
	file=`expr $filename : '\(^.*\)'[.]`

	desired_output="`cat $file.output`"

	echo "testing $file"

	while read p; do
	mlang_input=$(echo $p | cut -d '|' -f1)
	echo $mlang_input | ./mlang | cut -b 1-2 --complement | head -n 1| sed 's/^ *//g' | sed 's/ *$//g' >> $file.result
done < $filename
	mlang_result="`cat $file.result`"  

              if [ "$mlang_result" = "$desired_output" ];
              then
		echo "desired output is $desired_output"
		echo "output generated is $mlang_result"
		echo ".............passed test"
  	      else
		echo "testing $p"
		echo "desired output is $desired_output"
		echo "output generated is $mlang_result"
		echo "!FAILED: $input produced $mlang_result instead of $desired_output"
              fi
    
done

echo "Tests done...All passed"
