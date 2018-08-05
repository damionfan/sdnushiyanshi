#include "../include/active.h"

__global__ void ReluForward(const float n, const unsigned float *in, const unsigned float *out, const unsigned float negative_slope){
	for(int i = blockIdx.x * blockDim.x + threadIdx.x;i<n;i+=blockIdx.x*dlockDim.x){
		out[i] = in[i]>0 ? in[i]:in[i]*negative_slope;
	}
}

void ReluLayer_Forward(const unsigned float *in,const unsigned float *out,const unsigned float *negative_slope){
	unsigned float *data_gpu,*out_gpu;
	unsigned float *n_gpu,*negative_slope_gpu;
	unsigned float n = sizeof(in)/sieof(in[0]);

	cudaMalloc((void**)&data_gpu,n*sizeof(float));
	cudaMalloc((void**)&out_gpu,n*sizeof(float));
	cudaMalloc((void**)&n_gpu,sizeof(float));
	cudaMalloc((void**)&negative_slope_gpu,sizeof(float));

	cudaMemcpy(data_gpu,in,n*sizeof(float),cudaMemcpyHostToDevice);
	cudaMemcpy(n_gpu,n,sizeof(float),cudaMemcpyHostToDevice);
	cudaMemcpy(negative_slope_gpu,negative_slope,sizeof(float),cudaMemcpyHostToDevice);

	ReluForward<<<GETBLOCK(n),THREADMAXPERBLOCK>>>(n_gpu,data_gpu,out_gpu,negative_slope_gpu);

	cudaMemcpy(out,out_gpu,n*sizeof(float),cudaMemcpyDeviceToHost);

	cudaFree(data_gpu);
	cudaFree(out_gpu);
	cudaFree(n_gpu);
	cudaFree(negative_slope_gpu);

}

__global__ void ReluBackward(const float n, const unsigned float *in_diff, const unsigned float *in, const unsigned float *out, const unsigned float negative_slope){
	for(int i = blockIdx.x * blockDim.x + threadIdx.x;i<n;i+=blockIdx.x*dlockDim.x){
		out[i] = in_diff[i] * (in[i]>0) + (in[i]<=0)*negative_slope;
	}
}

void ReluLayer_Backward(const unsigned float *in,const unsigned float data_diff,const unsigned float *out,const unsigned float *negative_slope){
	unsigned float *data_gpu,*out_gpu;
	unsigned float *n_gpu,*negative_slope_gpu;
	unsigned float *data_diff_gpu;
	unsigned float n = sizeof(in)/sieof(in[0]);


	cudaMalloc((void**)&data_gpu,n*sizeof(float));
	cudaMalloc((void**)&out_gpu,n*sizeof(float));
	cudaMalloc((void**)&n_gpu,sizeof(float));
	cudaMalloc((void**)&negative_slope_gpu,sizeof(float));
	cudaMalloc((void**)&data_diff_gpu,n*sizeof(float));


	cudaMemcpy(data_gpu,in,n*sizeof(float),cudaMemcpyHostToDevice);
	cudaMemcpy(data_diff_gpu,in,n*sizeof(float),cudaMemcpyHostToDevice);
	cudaMemcpy(n_gpu,n,sizeof(float),cudaMemcpyHostToDevice);
	cudaMemcpy(negative_slope_gpu,negative_slope,sizeof(float),cudaMemcpyHostToDevice);

	ReluForward<<<GETBLOCK(n),THREADMAXPERBLOCK>>>(n_gpu,data_diff_gpu,data_gpu,out_gpu,negative_slope_gpu);

	cudaMemcpy(out,out_gpu,n*sizeof(float),cudaMemcpyDeviceToHost);

	cudaFree(data_gpu);
	cudaFree(out_gpu);
	cudaFree(n_gpu);
	cudaFree(data_diff_gpu);
	cudaFree(negative_slope_gpu);

}
