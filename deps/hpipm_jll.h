#include <hpipm_d_ocp_qp.h>
#include <hpipm_d_ocp_qp_ipm.h>
#include <inttypes.h>

// typedef struct ocp_qp_dim *ocp_qp_dim;
typedef struct ocp_qp_dim {
  struct d_ocp_qp_dim *dim;
  void *mem;
} ocp_qp_dim;

ocp_qp_dim ocp_qp_dim_new(int N);
// void ocp_qp_dim_set_all()
void ocp_qp_dim_free(ocp_qp_dim *dim);

void greet();

void create_ocp_qp_dim(struct d_ocp_qp_dim *dim, int N, uint8_t *memory);

void set_dim_length(struct d_ocp_qp_dim *dim, int N);

void set_memsize(struct d_ocp_qp_ipm_ws *ws);