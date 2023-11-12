from datetime import datetime
from functools import lru_cache

import matplotlib.pyplot as plt
import numpy as np

import argparse



class ShowData:
    def __init__(
        self, size: int,
    ):

        self.size = size


    def read_input( self, file ):
        _array_re = np.zeros( 2048 )
        for ii in range(self.size):
            line = file.readline()
            print( line )
            #re = line.split()
            #print( re )
            #_array_re[ii]= [float(line)] # [float(x) for x in line.split()] 
            
            fields = line.split()
            _array_re[ii]= int(fields[0]);

        return _array_re


    def plot_result(self, data: np.ndarray, save_fig: bool = False):
        _ = plt.figure("Input data", figsize=(16, 12))
        plt.subplot(1, 1, 1)

        plt.plot(data.real, linewidth=1.15, color="C2")
        plt.grid(True)
        plt.xlim([0, self.size - 1])

        plt.tight_layout()
        if save_fig:
            plt.savefig(f"figure_{datetime.now()}"[:-7])
        plt.show()


if __name__ == "__main__":

    parser = argparse.ArgumentParser();

    file_i = open( "data.txt", "r")


    _show = ShowData( 2048 )

    _input = _show.read_input( file_i )
    _show.plot_result(_input, save_fig=False)


    file_i.close()
