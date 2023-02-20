#include "fss.h"

void init_insecure_rand(){
    srand((unsigned int)time(NULL));   // Initialization, should only be called once.
}

void init_secure_rand(){
    if (sodium_init() < 0) {
        /* panic! the library couldn't be initialized, it is not safe to use */
        printf("<Funshade Error>: libsodium init failed in init_secure_rand\n");
        exit(1);
    }
}

void inline init_states(uint8_t *s0, uint8_t *s1, size_t s_len){
    assert(s_len == G_IN_LEN);

    s0 = (uint8_t *) malloc(G_IN_LEN);
    s1 = (uint8_t *) malloc(G_IN_LEN);
    if (s0==NULL || s1==NULL)
    {
        printf("<Funshade Error>: s0|s1 init failed in DCF_gen\n");
        exit(1);
    }
    
    // Initialize s0 and s1 to random values SECURELY if libsodium is available
    #ifdef USE_LIBSODIUM
    init_secure_rand();
    randombytes_buf(s0, G_IN_LEN);
    randombytes_buf(s1, G_IN_LEN);

    // Initialize s0 and s1 to random values INSECURELY otherwise
    #else
    init_insecure_rand();
    for (size_t i = 0; i < AES_BLOCKLEN; i++)
    {
        s0[i] = rand() % 256;
        s1[i] = rand() % 256;
    }
    #endif
}

void inline xor(uint8_t *a, uint8_t *b, uint8_t *res, size_t s_len){
    for (size_t i = 0; i < s_len; i++)
    {
        res[i] = a[i] ^ b[i];
    }
}

void DCF_gen(DTYPE_t alpha, uint8_t *s0, uint8_t *s1, size_t s_len, fss_key_t *k0, fss_key_t *k1){
    // Inputs and outputs to G
    uint8_t s0_i[S_LEN] = {0},  g_out_0[G_OUT_LEN]= {0},
            s1_i[S_LEN] = {0},  g_out_1[G_OUT_LEN]= {0};
    // Pointers to the various parts of the output of G
    uint8_t *s0_keep, *s0_lose, *v0_keep, *v0_lose, *t0_keep, *t0_lose,
            *s1_keep, *s1_lose, *v1_keep, *v1_lose, *t1_keep, *t1_lose;
    // Temporary variables
    uint8_t CW_chain[CW_CHAIN_LEN] = {0};
    uint8_t s_cw[S_LEN] = {0};
    DTYPE_t V_cw, V_alpha=0;    bool t0=0, t1=1;                                // L3
    bool t_cw_L, t_cw_R, t0_L, t0_R, t1_L, t1_R;

    // Decompose alpha into an array of bits                                    // L1
    bool alpha_bits[N_BITS] = {0};
    for (size_t i = 0; i < N_BITS; i++){
        alpha_bits[i] = (alpha >> i) & 1;
    }

    // Initialize s0 and s1 randomly if they are NULL                           // L2
    assert(s_len == S_LEN);
    init_states(s0, s1, s_len);
    memcpy(s0_i, s0, S_LEN);
    memcpy(s1_i, s1, S_LEN);

    // Main loop
    for (size_t i = 0; i < N_BITS; i++)                                         // L4
    {
        G_ni(s0_i, g_out_0, G_IN_LEN, G_OUT_LEN);                             // L5
        G_ni(s1_i, g_out_1, G_IN_LEN, G_OUT_LEN);                             // L6
        t0_L = TO_BOOL(g_out_0 + T_L_PTR);   t0_R = TO_BOOL(g_out_0 + T_R_PTR);
        t1_L = TO_BOOL(g_out_1 + T_L_PTR);   t1_R = TO_BOOL(g_out_1 + T_R_PTR);

        if (alpha_bits[i])  // keep = R; lose = L;                              // L7
        {
            s0_keep = g_out_0 + S_R_PTR;    s0_lose = g_out_0 + S_L_PTR;
            v0_keep = g_out_0 + V_R_PTR;    v0_lose = g_out_0 + V_L_PTR;
            t0_keep = g_out_0 + T_R_PTR;    t0_lose = g_out_0 + T_L_PTR;
            s1_keep = g_out_1 + S_R_PTR;    s1_lose = g_out_1 + S_L_PTR;
            v1_keep = g_out_1 + V_R_PTR;    v1_lose = g_out_1 + V_L_PTR;
            t1_keep = g_out_1 + T_R_PTR;    t1_lose = g_out_1 + T_L_PTR;
            V_cw = (t1?-1:1) * BETA;                                            // L12
        }
        else                // keep = L; lose = R;                              // L8
        {
            s0_keep = g_out_0 + S_L_PTR;    s0_lose = g_out_0 + S_R_PTR;
            v0_keep = g_out_0 + V_L_PTR;    v0_lose = g_out_0 + V_R_PTR;
            t0_keep = g_out_0 + T_L_PTR;    t0_lose = g_out_0 + T_R_PTR;
            s1_keep = g_out_1 + S_L_PTR;    s1_lose = g_out_1 + S_R_PTR;
            v1_keep = g_out_1 + V_L_PTR;    v1_lose = g_out_1 + V_R_PTR;
            t1_keep = g_out_1 + T_L_PTR;    t1_lose = g_out_1 + T_R_PTR;
            V_cw = 0;                                                           // L12
        }

        xor(s0_lose, s1_lose, s_cw, S_LEN);                                     // L10
        V_cw = (t1?-1:1) * (TO_DTYPE(v1_lose) - TO_DTYPE(v0_lose) - V_alpha);   // L11

        V_alpha += - TO_DTYPE(v1_keep) + TO_DTYPE(v0_keep) + (t1?-1:1)*V_cw;    // L14
        t_cw_L = t0_L ^ t1_L ^ alpha_bits[i] ^ 1;                               // L15
        t_cw_R = t0_R ^ t1_R ^ alpha_bits[i];
        memcpy(CW_chain + S_CW_PTR(i), s_cw, S_LEN);                            // L16
        memcpy(CW_chain + V_CW_PTR(i), &V_cw, V_LEN);
        CW_chain[T_CW_L_PTR(i)]     = t_cw_L;
        CW_chain[T_CW_R_PTR(i)]     = t_cw_R;
        if (t0)
        {
            xor(s0_keep, s_cw, s0_i, S_LEN);                                    // L18
            t0 = TO_BOOL(t0_keep) ^ (alpha_bits[i]?t_cw_R:t_cw_L);              // L19
        }
        else
        {
            memcpy(s0_keep, s_cw, S_LEN);
            t0 = TO_BOOL(t0_keep);
        }
        if (t1)
        {
            xor(s1_keep, s_cw, s1_i, S_LEN);                                    
            t1 = TO_BOOL(t1_keep) ^ (alpha_bits[i]?t_cw_L:t_cw_R);              
        }
        else
        {
            memcpy(s1_keep, s_cw, S_LEN);
            t1 = TO_BOOL(t1_keep);
        }
    }
    *(DTYPE_t*)(&CW_chain[LAST_CW_PTR]) = (t1?-1:1) * (TO_DTYPE(s1_i) - TO_DTYPE(s0_i) - V_alpha); // L20

    // Prepare the resulting keys                                               // L21
    memcpy(*k0->s, s0_i, S_LEN);
    memcpy(*k1->s, s1_i, S_LEN);
    memcpy(*k0->CW_chain, CW_chain, CW_CHAIN_LEN);
    memcpy(*k1->CW_chain, CW_chain, CW_CHAIN_LEN);
}


DTYPE_t DCF_eval(bool b, fss_key_t *kb, DTYPE_t x){
    DTYPE_t V = 0;                                                              // L1
    bool t = 0;
    uint8_t s[S_LEN];               memcpy(s, *kb->s, S_LEN);
    uint8_t g_out[G_OUT_LEN];
    uint8_t CW_chain[CW_CHAIN_LEN]; memcpy(CW_chain, *kb->CW_chain, CW_CHAIN_LEN);
    // Decompose x into an array of bits
    bool x_bits[N_BITS];
    for (size_t i = 0; i < N_BITS; i++)
    {
        x_bits[i] = (x >> i) & 1;
    }

    // Main loop
    for (size_t i = 0; i < N_BITS; i++)                                         // L2
    {
        G_ni(s, g_out, G_IN_LEN, G_OUT_LEN);                                    // L4
        if (x_bits[i])  // Pick the right branch
        {
            V += (b?-1:1) * (  TO_DTYPE(g_out + V_R_PTR) +                      // L9
                             t*TO_DTYPE(CW_chain + V_CW_PTR(i)) );
            if (t)                                                              // L10
            {
                xor(g_out + S_R_PTR, CW_chain + S_CW_PTR(i), s, S_LEN);
            }
            else
            {
                memcpy(s, g_out + S_R_PTR, S_LEN);
            }
            t = TO_BOOL(g_out + T_R_PTR) ^ (t & TO_BOOL(CW_chain + T_CW_R_PTR(i)));
        }
        else            // Pick the left branch
        {
            V += (b?-1:1) * (  TO_DTYPE(g_out + V_L_PTR) +                      // L7
                             t*TO_DTYPE(CW_chain + V_CW_PTR(i)));
            if (t)                                                              // L8
            {
                xor(g_out + S_L_PTR, CW_chain + S_CW_PTR(i), s, S_LEN);
            }
            else
            {
                memcpy(s, g_out + S_L_PTR, S_LEN);
            }
            t = TO_BOOL(g_out + T_L_PTR) ^ (t & TO_BOOL(CW_chain + T_CW_L_PTR(i)));
            
        }
        
    }
    V += (b?-1:1) * (TO_DTYPE(s) + t*TO_DTYPE(CW_chain + LAST_CW_PTR));         // L13
    return V;
}