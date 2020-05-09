BIN='../../../build/bin/gmx'

cd experiment
for i in `seq 1 5`; do
  filename="output{$i}.cvs"
  /usr/bin/time $BIN mdrun -v -deffnm em >> $filename
done
#cut -d " " -f 5 output.txt > $FILE_NAME
