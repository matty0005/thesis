onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+clk_master  -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.clk_master xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {clk_master.udo}

run 1000ns

endsim

quit -force
