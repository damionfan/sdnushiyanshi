/*
 * 共享内存与同步
 * 点积运算
 * 范胜玉
 * */

#include <stdio.h>


#define ismin(a,b) (a<b?a:b)

const int N =  4096;
const int threadPerBlock = 256;
const int blocksPerGrid = ismin(32,(N+threadPerBlock-1)/threadPerBlock);

__global__ void dot(float *a, float *b, float *c){

	 float cache[threadPerBlock];
	int tid = threadIdx.x + blockIdx.x*blockDim.x;
	//printf("tid = %d\n a[tid]=%d\n",tid,a[tid]);
	int cacheIndex  = threadIdx.x;
	 float temp ;
	temp= 0;
	while(tid < N){
		temp += a[tid] * b[tid];
		tid += blockDim.x*gridDim.x;
	}
	cache[cacheIndex] = temp;

	//线程同步
	__syncthreads();

	//归约
	int i = blockDim.x/2;
	while(i!=0){
		if(cacheIndex<i)
			cache[cacheIndex] += cache[cacheIndex+i];
		__syncthreads();
		i/=2;
	}

	if(cacheIndex == 0)
		c[blockIdx.x] = cache[0];
}

int main(){
	float *a,*b,c,*partial_c;
	float *dev_a,*dev_b,*dev_partial_c;
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start,0);
	//cpu
	a = (float*)malloc(N*sizeof(float));
	b = (float*)malloc(N*sizeof(float));
	partial_c = (float*)malloc(blocksPerGrid*sizeof(float));

	//gpu malloc
	cudaMalloc((void**)&dev_a,N*sizeof(float));
	cudaMalloc((void**)&dev_b,N*sizeof(float));
	cudaMalloc((void**)&dev_partial_c,blocksPerGrid*sizeof(float));

	//host insert
	for(int i=0;i<N;i++){
		a[i] = i;
		b[i] = i*2;
	}

	cudaMemcpy(dev_a,a,N*sizeof(float),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b,b,N*sizeof(float),cudaMemcpyHostToDevice);
	dot<<<blocksPerGrid,threadPerBlock>>>(dev_a,dev_b,dev_partial_c);

	cudaMemcpy(partial_c,dev_partial_c,blocksPerGrid*sizeof(float),cudaMemcpyDeviceToHost);

	c = 0;
	for(int i=0;i<blocksPerGrid;i++)
		c += partial_c[i];

	float elapsedTime;
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedTime,start,stop);
	printf("Time to generate: %3.1f ms \n",elapsedTime);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
#define sum_squares(x) (x*(x+1)*(2*x+1)/6)
	printf("Does GPU value %.6g = %.6g?\n",c,
			2*sum_squares((float)(N-1)));

	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_partial_c);

	free(a);
	free(b);
	free(partial_c);



}












