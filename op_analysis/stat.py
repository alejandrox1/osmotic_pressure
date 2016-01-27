#!/usr/bin/python
''' This script goes through the sumarize tables of measurements and returns the mean and standard deviation.'''
import sys

dat_file = str(sys.argv[1])
out_dat = "statistics.dat"

def osmk(dat_file):
	'''Returns the mean and standard deviation.'''

	molality=[]
	molarity=[]
	ideal=[]
	osmotic=[]

	myfile = open(dat_file, 'r')
        for line in myfile:
                if (line.find('#')==-1):
			m, M, ip, op = line.split()
			molality.append(m)
			molarity.append(M)
			ideal.append(ip)
			osmotic.append(op)
	myfile.close()
	
	for x in molality:
		if molality[0] == x:
			continue
		else:
			print "Check the dat file."
			break

	mean = sum( float(x) for x in osmotic)/ (len(osmotic))

	diff = []
	for x in osmotic:
		n = ( float(x) - mean)**2
		diff.append(n)
	std = (sum(diff) / (len(osmotic) -1 ))** 0.5

	return (molality[0], molarity[0], ideal[0], mean,std)

if __name__ == "__main__":
	
	m, M, pi, mean, std =  osmk(dat_file)
	print m,'\t', M,'\t', pi,'\t', mean, '\t', std		
	with open(out_dat, "a") as myfile:
		myfile.write("%s\t%s\t%s\t%s\t%s\n" %(m, M, pi, mean, std))	
					
			
