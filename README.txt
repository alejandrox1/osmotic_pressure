
##- MD simulations

op_setup.sh			// Runs a sequence of MD simulations



	run_op.sh		// Runs a given MD simulation
		
		fudge.sh
		combine2gro.sh
		make_pull_mpd*

		Need to change a couple hardcode options with respect to the topologis being used

	run_simul.sh		// Runs production run for a given MD simulation

		
##- MD analysis

analyze_simulations.sh
		
	call_calc_op.sh
	graph_calc_op.py
	stat.py


Notes:
	combine2gro.sh has has hardcoded values for the box size (as of Sat Jan 30 19:47:19 EST 2016 we still need to fix this).
