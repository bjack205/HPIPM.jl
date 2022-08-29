#include "hpipm_jll.h"

#include <stdio.h>
#include <stdlib.h>
#include <hpipm_d_ocp_qp_utils.h>


ocp_qp_dim ocp_qp_dim_new(int N) {
	hpipm_size_t dim_size = d_ocp_qp_dim_memsize(N);
  hpipm_size_t str_size = d_ocp_qp_dim_strsize();
	char *mem = (char*)malloc(str_size + dim_size);
  struct d_ocp_qp_dim *dim = (struct d_ocp_qp_dim*)(mem);
  void *dim_mem = (void*)(mem + str_size);
  d_ocp_qp_dim_create(N, dim, dim_mem);
  ocp_qp_dim dim_wrapper = {
    .dim = dim,
    .mem = (void*)mem,
  };
  // p_dim_wrapper->dim = p_dim;
  // p_dim_wrapper->mem = (void*)mem;
  return dim_wrapper;
}

void ocp_qp_dim_free(ocp_qp_dim *dim) {
  free(dim->dim);
  dim->mem = NULL;
}

void greet() {
  puts("Hello from HPIPM_jll!");
}

void create_ocp_qp_dim(struct d_ocp_qp_dim *dim, int N, uint8_t *memory) {
  void *dim_mem = (void*)memory;
	d_ocp_qp_dim_create(N, dim, dim_mem);
  d_ocp_qp_dim_print(dim);
  // printf("mem = %p\n", memory + 1);
  // dim->nx = (int*) memory;
  // memory += (N+1)*sizeof(int);
  // dim->nu = (int*) memory;
  // memory += (N+1)*sizeof(int);

  printf("mem = %p\n", memory);
  // printf("nx  = %p\n", dim->nx);
}

void set_dim_length(struct d_ocp_qp_dim *dim, int N) {
  dim->N = N;
}