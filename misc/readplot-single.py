#coding:utf-8
# K-means

import numpy as np
import sys
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from matplotlib.ticker import MaxNLocator

argvs = sys.argv

if __name__ == "__main__":

    argc = len(argvs) 
    
    #if (argc != 4):  
    #    print 'Usage:'
    #    quit() 
        
    data = np.genfromtxt(argvs[1], delimiter=",")
    #data2 = np.genfromtxt(argvs[2], delimiter=",")
    
    fig, ax = plt.subplots()
    ax.get_xaxis().get_major_formatter().set_useOffset(False)
    ax.get_xaxis().set_major_locator(ticker.MaxNLocator(integer=True))
    ax.set_xticklabels(data[:,0], rotation=60)
    fig.subplots_adjust(bottom=0.2)

    plt.title("Graph Title")
    plt.xlabel("# of data (randomly generated)")
    plt.ylabel("elapsed time")
    
    ax.plot(data[:,1], label = "")
    #ax.plot(data2[:,1], label= "CUDA")
    plt.legend()
    
    #plt.title(argvs[3])
    plt.show()  
            
    #filename = argvs[1] + ".png"
    #plt.savefig(filename)

