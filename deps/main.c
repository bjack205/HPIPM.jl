#include "hpipm_jll.h"
#include <hpipm_d_ocp_qp_dim.h>
#include <stdlib.h>

int main () {

  int N = 5;
  ocp_qp_dim dim = ocp_qp_dim_new(N);
  ocp_qp_dim_free(&dim);
	// hpipm_size_t dim_size = d_ocp_qp_dim_memsize(N);
	// void *dim_mem = malloc(dim_size);
  // create_ocp_qp_dim(&dim, 5, dim_mem);

  // set_dim_length(&dim, 5);
  // free(dim_mem);
  return 0;
}