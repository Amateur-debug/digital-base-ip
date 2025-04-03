
all: run_synth
	
run_synth:
	bsub < ./run_dc_syn.sh

clean: 
	rm -rf ./build
	rm -rf ./log
	rm -rf ./report
	rm -rf ./svf
	rm -rf ./alib
	rm -f ./*.log
	rm -f ./*.svf