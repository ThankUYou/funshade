import numpy as np
cimport numpy as np

from libc.stdint cimport int64_t, int64_t, uint8_t


cdef extern from "c/fss.h" nogil:
    ctypedef int R_t
    const size_t KEY_LEN
    const size_t SEED_LEN

    ## FUNSHADE (batch evaluation)
    void funshade_setup_batch(size_t K, size_t l, R_t theta,
        R_t d_x0[], R_t d_x1[], R_t d_y0[], R_t d_y1[], R_t d_xy0[], R_t d_xy1[],
        R_t r_in_0[],R_t r_in_1[], uint8_t k0[], uint8_t k1[])
    void funshade_share_batch(size_t K, size_t l, const R_t v[], const R_t d_v[],R_t D_v[])
    void funshade_eval_dist_batch(size_t K, size_t l, bint j,
        const R_t r_in_j[], const R_t D_x[], const R_t D_y[],
        const R_t d_xj[], const R_t d_yj[], const R_t d_xyj[], R_t z_hat[])
    void funshade_eval_sign_batch(size_t K, bint j, const uint8_t kj[],
        const R_t z_hat_0[], const R_t z_hat_1[], R_t o_j[])
    R_t funshade_eval_sign_batch_collapse(size_t K, bint j, const uint8_t kj[],
        const R_t z_hat_0[], const R_t z_hat_1[])


# build the corresponding numpy dtype for R_t (ring type)
cdef R_t tmp
DTYPE = np.asarray(<R_t[:1]>(&tmp)).dtype


#------------------------------------------------------------------------------#
def setup( size_t K, size_t l, R_t theta):
    """Setup for the FunShade protocol.
    
    Generates the beaver triples, input masks and function keys.

    Args:
        K (int): Number of vectors.
        l (int): Number of elements per vector.
        theta (int): Upscaled threshold.
    
    Returns:
        d_x0, d_x1, d_y0, d_y1, d_xy0, d_xy1 (np.ndarray): beaver triples for x and y.
        r_in0, r_in1 (np.ndarray): input masks.
        k0, k1 (np.ndarray): function keys.
    """
    cdef np.ndarray[R_t, ndim=1] d_x0  =\
                np.empty((K*l), DTYPE), d_x1  = np.empty((K*l), DTYPE),\
        d_y0  = np.empty((K*l), DTYPE), d_y1  = np.empty((K*l), DTYPE),\
        d_xy0 = np.empty((K*l), DTYPE), d_xy1 = np.empty((K*l), DTYPE),\
        r_in0 = np.empty((K),   DTYPE), r_in1 = np.empty((K),   DTYPE)
        
    cdef np.ndarray[uint8_t, ndim=1] k0 = np.empty((K), np.uint8), k1 = np.empty((K), np.uint8)
    
    funshade_setup_batch(K, l, theta, 
           &d_x0[0], &d_x1[0], &d_y0[0], &d_y1[0], &d_xy0[0], &d_xy1[0], &r_in0[0], &r_in1[0], &k0[0], &k1[0])
    return d_x0, d_x1, d_y0, d_y1, d_xy0, d_xy1, r_in0, r_in1, k0, k1

def share(size_t K, size_t l, R_t[::1] v, R_t[::1] d_v):
    """Generate Delta share of a vector v (Pi secret sharing)
    
    Args:
        K (int): Number of vectors.
        l (int): Number of elements per vector.
        v (np.ndarray): Vector to be shared.
        d_v (np.ndarray): Beaver triple input shares for v.
    
    Returns:
        D_v (np.ndarray): Delta share of v.
    """
    cdef np.ndarray[R_t, ndim=1] D_v = np.empty((K*l), DTYPE)
    funshade_share_batch(K, l, &v[0], &d_v[0], &D_v[0])
    return D_v

def eval_dist(size_t K, size_t l, bint j, R_t[::1] r_in_j, R_t[::1] D_x, R_t[::1] D_y, 
              R_t[::1] d_xj, R_t[::1] d_yj, R_t[::1] d_xyj):
    """Compute the distance function (scalar prod.) on the Delta shares of x and y.

    Args:
        K (int): Number of vectors.
        l (int): Number of elements per vector.
        j (bint): Input mask bit.
        r_in_j (np.ndarray): Input mask share.
        D_x (np.ndarray): Delta shares of x.
        D_y (np.ndarray): Delta shares of y.
        d_xj (np.ndarray): Beaver triple input shares for x.
        d_yj (np.ndarray): Beaver triple input shares for y.
        d_xyj (np.ndarray): Beaver triple shares for products xy.
    
    Returns:
        z_hat_j (np.ndarray): shares of the distance function evaluation result.
    """
    cdef np.ndarray[R_t, ndim=1] z_hat_j = np.empty((K), DTYPE)
    funshade_eval_dist_batch(K, l, j, &r_in_j[0], &D_x[0], &D_y[0], &d_xj[0], &d_yj[0], &d_xyj[0], &z_hat_j[0])
    return z_hat_j

def eval_sign(size_t K, bint j, uint8_t[::1] k_j, R_t[::1] z_hat_0, R_t[::1] z_hat_1):
    """Compute the sign function (with FSS) given the shares of a public value z_hat.

    Args:
        K (int): Number of vectors.
        j (bint): Input mask bit.
        k_j (np.ndarray): Function key share.
        z_hat_0 (np.ndarray): Shares of z_hat from P0.
        z_hat_1 (np.ndarray): Shares of z_hat from P1.
    
    Returns:
        o_j (np.ndarray): shares of the sign function evaluation result.
    """
    cdef np.ndarray[R_t, ndim=1] o_j = np.empty((K), DTYPE)
    funshade_eval_sign_batch(K, j, &k_j[0], &z_hat_0[0], &z_hat_1[0], &o_j[0])
    return o_j

def eval_sign_collapse(size_t K, bint j, uint8_t[::1] k_j, R_t[::1] z_hat_0, R_t[::1] z_hat_1):
    """Compute the sign function (with FSS) given the shares of a public value z_hat.

    Returns a single value (sum of results), using less memory.

    Args:
        K (int): Number of vectors.
        j (bint): Input mask bit.
        k_j (np.ndarray): Function key share.
        z_hat_0 (np.ndarray): Shares of z_hat from P0.
        z_hat_1 (np.ndarray): Shares of z_hat from P1.
    
    Returns:
        o_j (np.ndarray): shares of the sign function evaluation result.
    """
    return funshade_eval_sign_batch_collapse(K, j, &k_j[0], &z_hat_0[0], &z_hat_1[0])