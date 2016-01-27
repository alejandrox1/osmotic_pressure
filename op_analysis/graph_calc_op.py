#!/usr/bin/python -W ignore::DeprecationWarning

''' Script to be run by call_calc_op.sh.'''

import sys
import numpy
#from matplotlib.backends.backend_pdf import PdfPages
#import matplotlib.pyplot as plt

Nmg=int(sys.argv[1])     # Number of solute molecules
L=float(sys.argv[2])     # Lenght of box in nm
Nwat=int(sys.argv[3])    # Number of water molecules in the central chamber
fname=str(sys.argv[4])   # OUTPUT file
pullf=str(sys.argv[5])   # Output pullf.xvg 
skip=int(sys.argv[6])  # number of ns skipped      (10 for polypeptides 20 for proteins)
#graph=str(sys.argv[7])

Nav=6.023*10**23        #Avogadro's number
densW= 1.005            #(kg/l)
W_mm=0.018015           #kg
H_mm=1.00794            #a.m.u or gm
O_mm=15.9994            #a.m.u or gm
R=8.314*10**(-2)        #l bar/K/mol
T=300                   # K

def molality(n_solute, N_wat):
	'''Molality (m) is the moles of solute over the mass in Kg of solvent.'''
	
	# Molar mass of water in kg
	W_mm= 0.018015
	
	m= n_solute/(N_wat * W_mm)
	return m

def molarity(n_solute, L):
	'''Molarity (M) is defined as moles of solute over the volume of solution.'''
	
	# Avogadro's Number
	Nav=6.023*10**23
	# Volume (Lenght in nm/ 1 liter= 10**(-3) m**3)
	Vol= (L**3) * ( 10**(-24))

	M= n_solute/ (Nav * Vol)
	return M

def ideal_osmotic_p(Nmg,L):
	'''The ideal osmotic pressure is given by Van't Hoff equation.'''
	
	R= (8.3144621)*(10**(-2))        # L bar K**-1 mol**-1
	T=300                            # K
	
	# Ideal osmotic pressure in bars
	op_ideal= molarity(Nmg,L)*R*T
	return op_ideal

def readxvg(r):
	'''Reads and processes .xvg file.'''

	data = [line.split() for line in open(r).readlines() if line[0] not in ['#','@'] ]
	data = [ [float(x) for x in line] for line in data]
	return numpy.array(data)

def osmotic_p(pullfname, L, skip):
	'''Calculates the osmotic pressure from pullf.xvg files generated from gromacs.'''
	
	# Cross sectional area
	area= (L*L)

	# Read pullf.xvg
        a= readxvg(pullfname)
        
	# take the absolute value of all the forces (column 2) and put them in a new list (wall)
	wall = []
	for i in range(len(a)):
		f=0
		for j in range(1, len(a[i])):
			if (i >= skip ):
				f+= abs(a[i][j])
		wall.append(f)	

	# Erase the local list "wall", stop setting f=0, thus f can replace "fwall" by "f/2.0" for it is the sum of all the elements in the array
						
	#numpy.savetxt("array.dat", a)		
	# Total force durinng the ismulation (force was calculated from both ends (walls) of the simulation box)
	fwall= (sum(wall))/2.0

	# average force per area 
	osmk = fwall/(area*len(wall[skip:]))
        return osmk

def graph_f(pullfname, L, skip):
	area= (L*L)
	a= readxvg(pullfname)
	wall =[]
	wall_time =[]
	for i in range(len(a)):
		f=0
		t=a[i][0]
		for j in range(1, len(a[i])):
			f+= ((abs(a[i][j]))/2.0)
		wall.append(f)
		wall_time.append(t)
	return (wall, wall_time)

def plot_routine( graph_handle, skip ):
        forces, time = graph_f(pullf,L,skip)

        pdf_pages = PdfPages( graph_handle )
        plt.rc('text', usetex=False)
        fig = plt.figure(figsize=(8,6))
        plt.plot(time[skip:], forces[skip:],)
        plt.title("Convergence of forces")
        plt.xlabel("Time (ps)")
        plt.ylabel("Force (KJ/mol/nm)")
        pdf_pages.savefig(fig)
        pdf_pages.close()

        return graph_handle


if __name__== "__main__":

	if (len(sys.argv) != 7):
		print "Error: not enough arguments given."
		print "1) Solute molecules\n2) Lenght of box\n3) Number of water molecules in the central chamber\n4) Output file name\n5) .xvg file\n6) Number of ns to be skipped for analysis\n"
		sys.exit (1)

	print "m = %s" %(molality(Nmg,Nwat))
	print "M = %s" %(molarity(Nmg,L))
	print "The ideal osmotic pressure is %s" %(ideal_osmotic_p(Nmg,L))
	print "The osmotic pressure is = %s" %(osmotic_p(pullf, L, skip) * 16.6054) 
	with open(fname, 'a') as myfile:
                myfile.write("%f\t%f\t%f\t%f\n" % (molality(Nmg,Nwat), molarity(Nmg,L), ideal_osmotic_p(Nmg,L), (osmotic_p(pullf,L, skip) * 16.6054)))

#	plot_routine('graph.pdf', 0)
#	plot_routine('graph_skip.pdf', 1000)

