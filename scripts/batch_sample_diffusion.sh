TOTAL_TASKS=100
BATCH_SIZE=50

if [ $# != 5 ]; then
    echo "Error: 5 arguments required."
    exit 1
fi

CONFIG_FILE=$1
RESULT_PATH=$2
NODE_ALL=$3
NODE_THIS=$4
START_IDX=$5

# CUDA_VISIBLE_DEVICES=1 bash scripts/batch_sample_diffusion.sh configs/sampling.yml outputs 4 0 0
# CUDA_VISIBLE_DEVICES=2 bash scripts/batch_sample_diffusion.sh configs/sampling.yml outputs 4 1 0
# CUDA_VISIBLE_DEVICES=3 bash scripts/batch_sample_diffusion.sh configs/sampling.yml outputs 4 2 0
# CUDA_VISIBLE_DEVICES=4 bash scripts/batch_sample_diffusion.sh configs/sampling.yml outputs 4 3 0

for ((i=$START_IDX;i<$TOTAL_TASKS;i++)); do
    NODE_TARGET=$(($i % $NODE_ALL))
    if [ $NODE_TARGET == $NODE_THIS ]; then
        echo "Task ${i} assigned to this worker (${NODE_THIS})"
        python -m scripts.sample_diffusion ${CONFIG_FILE} -i ${i} --batch_size ${BATCH_SIZE} --result_path ${RESULT_PATH}
    fi
done
