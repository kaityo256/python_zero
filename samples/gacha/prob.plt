set term pngcairo
set out "prob.png"
set xla "N"
set yla "Probability"

unset key
set yra [0:]
p "prob.dat" w linespoints pt 6 
