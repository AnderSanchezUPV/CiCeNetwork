#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=2
#SBATCH --time=72:00:00
#SBATCH --partition=p_medium     
#SBATCH --mem-per-cpu=6GB
#SBATCH --hint=nomultithread
#SBATCH --nodelist=nagpu01
#SBATCH --gres=gpu:4g.40gb:4

# other gpures slection:  gpu:A100:4; gpu:4g.40gb:4
# Define the command line you will run
script="Parallel_Jobs"

# required input files for the software execution, separated by a space
files=" ${script}.m "

## Do not change below this line

. /home/users/slurm/etc/slurm_func.sh

HOST=$(hostname)
echo Job runing on $HOST

scr=/gscratch/$USER/$SLURM_JOB_ID
mkdir $scr

LDIR=$(pwd)
export LDIR

echo "cp ${files} to $scr/."
cp $0 ${files} ${scr}/.

cd $scr

# LOAD NOW REQUIERED MODULES
module purge
module load MATLAB

# CALL EXECUTABLE with SRUN
export MATLAB_LOG_DIR=$scr
/usr/bin/time -p matlab -timing -batch "${script}"  > output.log 2>&1

recover

