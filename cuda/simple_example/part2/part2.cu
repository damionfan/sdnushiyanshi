/*
 * 	对于寄存器的使用暂时还是属于模糊状态的
 * 	此文件用于复习学习共享内存、全局内存等
 * */


#include <stdio.h>
#include <time.h>

#define u32 unsigned int
#define NUM_ELEM 8

__host__ void cpu_sort(u32 * const data,
		const u32 num_elements){
	static u32 cpu_tmp_0[NUM_ELEM];
	static u32 cpu_tmp_1[NUM_ELEM];

	for(u32 bit = 0; bit<32;bit++){
		u32 base_cnt_0 = 0;
		u32 base_cnt_1 = 0;

		for(u32 i=0;i<num_elements;i++){
			const u32 d = data[i];
			const u32 bit_mask = (1<<bit);

			if((d & bit_mask) > 0){
				cpu_tmp_1[base_cnt_1]=d;
				base_cnt_1++;
			} else {
				cpu_tmp_0[base_cnt_0] = d;
				base_cnt_0++;
			}
		}
		//
		for(u32 i=0; i<base_cnt_0;i++){
			data[i] = cpu_tmp_0[i];
		}
		for(u32 i=0; i<base_cnt_1;i++){
			data[base_cnt_0+i] = cpu_tmp_1[i];
		}

	}
}


__global__ void radix_sort(u32 *const sort_tmp,
		const u32 num_lists, //1  //2
		const u32 num_elements, // 8 //4
		 u32 tid , //  0  4
		u32 * const sort_tmp_0,
		u32 * const sort_tmp_1){
	u32 idx = threadIdx.x;
	tid = idx * tid;
	printf("tid=%d\n",tid);
	for(u32 bit=0;bit<32;bit++){
		u32 base_cnt_0 = 0;
		u32 base_cnt_1 = 0;


		for(u32 i =0; i<num_elements;i++){
			const u32 elem = sort_tmp[i+tid];
			//printf("elem=%d\n",elem);
			const u32 bit_mask = (1<<bit);

			if((elem & bit_mask)>0){
				sort_tmp_1[base_cnt_1+tid]=elem;
				base_cnt_1+=num_lists;
			}else{
				sort_tmp_0[base_cnt_0+tid]=elem;
				base_cnt_0+=num_lists;
			}

			for(u32 i=0;i<base_cnt_0;i+=num_lists){
				sort_tmp[i+tid] = sort_tmp_0[i+tid];
			}
			for(u32 i=0;i<base_cnt_1;i+=num_lists){
				sort_tmp[i+base_cnt_0+tid]=sort_tmp_1[tid+i];
			}
		}
	}
	__syncthreads();
}
int main()
{
	u32 list[NUM_ELEM]={122,10,2,1,2,22,12,9};
	u32 gpu_list_cpu[8];
	clock_t start,stop;
	float costtime;
	u32 * sort_tmp_0;
	u32 * sort_tmp_1;
	u32 * gpu_list;
	cudaMalloc((void**)&sort_tmp_0,8*sizeof(u32));
	cudaMalloc((void**)&sort_tmp_1,8*sizeof(u32));
	cudaMalloc((void**)&gpu_list,8*sizeof(u32));
	cudaMemcpy(gpu_list,list,8*sizeof(u32),cudaMemcpyHostToDevice);
	start = clock();
	//cpu_sort(list,8);
	radix_sort<<<1,2>>>(gpu_list,2,4,4,sort_tmp_0,sort_tmp_1);
	stop=clock();
	costtime = (float)(stop-start)/CLOCKS_PER_SEC;
	printf("花费时间为：%f\n",costtime);
	cudaMemcpy(gpu_list_cpu,gpu_list,8*sizeof(u32),cudaMemcpyDeviceToHost);
	for(u32 i=0;i<8;i++)
		printf("%d\n",gpu_list_cpu[i]);
	return 0;
}
