/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.DNET$SC_POSSIBLE_PROBLEMS
IS
    -- Author  : BOGDAN
    -- Created : 02.10.2024 11:46:36
    -- Purpose : Dnet обгортка для роботи з журналом можливих проблем з картками СРКО

    PROCEDURE get_Journal (p_Sc_Unique   IN     VARCHAR2,
                           p_Start_Dt    IN     DATE,
                           p_Stop_Dt     IN     DATE,
                           p_Spp_Tp      IN     VARCHAR2,
                           p_Spp_St      IN     VARCHAR2,
                           res_cur          OUT SYS_REFCURSOR);

    PROCEDURE get_card (p_spp_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    PROCEDURE forward_sc_possible_problems (
        p_spp_id     sc_possible_problems.spp_id%TYPE,
        p_dest_org   sc_possible_problems.com_org%TYPE);

    PROCEDURE make_processed (
        p_spp_id              sc_possible_problems.spp_id%TYPE,
        p_spp_decision_desc   sc_possible_problems.spp_decision_desc%TYPE);

    PROCEDURE make_not_confirmed (
        p_spp_id              sc_possible_problems.spp_id%TYPE,
        p_spp_decision_desc   sc_possible_problems.spp_decision_desc%TYPE);
END DNET$SC_POSSIBLE_PROBLEMS;
/


GRANT EXECUTE ON USS_PERSON.DNET$SC_POSSIBLE_PROBLEMS TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:57:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.DNET$SC_POSSIBLE_PROBLEMS
IS
    PROCEDURE get_Journal (p_Sc_Unique   IN     VARCHAR2,
                           p_Start_Dt    IN     DATE,
                           p_Stop_Dt     IN     DATE,
                           p_Spp_Tp      IN     VARCHAR2,
                           p_Spp_St      IN     VARCHAR2,
                           res_cur          OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   sc.sc_unique,
                   hsi.hs_dt                        AS spp_hs_ins_dt,
                   hsf.hs_dt                        AS spp_hs_forward_dt,
                   tools.GetUserPib (hsf.hs_wu)     AS spp_hs_forward_pib,
                   hsd.hs_dt                        AS spp_hs_decision_dt,
                   tools.GetUserPib (hsd.hs_wu)     AS spp_hs_decision_pib,
                   tp.DIC_NAME                      AS spp_tp_name,
                   st.DIC_NAME                      AS spp_st_name
              FROM v_sc_possible_problems  t
                   JOIN v_socialcard sc ON (sc.sc_id = t.spp_sc)
                   JOIN histsession hsi ON (hsi.hs_id = t.spp_hs_ins)
                   JOIN uss_ndi.v_ddn_spp_tp tp ON (tp.dic_value = t.spp_tp)
                   JOIN uss_ndi.v_ddn_spp_st st ON (st.dic_value = t.spp_st)
                   LEFT JOIN histsession hsf
                       ON (hsf.hs_id = t.spp_hs_forward)
                   LEFT JOIN histsession hsd
                       ON (hsd.hs_id = t.spp_hs_decision)
             WHERE     1 = 1
                   AND (p_Sc_Unique IS NULL OR sc.sc_unique = p_Sc_Unique)
                   AND (p_Spp_Tp IS NULL OR t.spp_tp = p_Spp_Tp)
                   AND (p_Spp_St IS NULL OR t.spp_st = p_Spp_St)
                   AND (p_Start_Dt IS NULL OR TRUNC (hsi.hs_dt) >= p_Start_Dt)
                   AND (p_Stop_Dt IS NULL OR TRUNC (hsi.hs_dt) <= p_Stop_Dt);
    END;

    PROCEDURE get_card (p_spp_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   sc.sc_unique,
                   hsi.hs_dt                        AS spp_hs_ins_dt,
                   hsf.hs_dt                        AS spp_hs_forward_dt,
                   tools.GetUserPib (hsf.hs_wu)     AS spp_hs_forward_pib,
                   hsd.hs_dt                        AS spp_hs_decision_dt,
                   tools.GetUserPib (hsd.hs_wu)     AS spp_hs_decision_pib,
                   tp.DIC_NAME                      AS spp_tp_name,
                   st.DIC_NAME                      AS spp_st_name
              FROM v_sc_possible_problems  t
                   JOIN v_socialcard sc ON (sc.sc_id = t.spp_sc)
                   JOIN histsession hsi ON (hsi.hs_id = t.spp_hs_ins)
                   JOIN uss_ndi.v_ddn_spp_tp tp ON (tp.dic_value = t.spp_tp)
                   JOIN uss_ndi.v_ddn_spp_st st ON (st.dic_value = t.spp_st)
                   LEFT JOIN histsession hsf
                       ON (hsf.hs_id = t.spp_hs_forward)
                   LEFT JOIN histsession hsd
                       ON (hsd.hs_id = t.spp_hs_decision)
             WHERE spp_id = p_spp_id;
    END;

    --Передача записів на обробку в ОСЗН
    PROCEDURE forward_sc_possible_problems (
        p_spp_id     sc_possible_problems.spp_id%TYPE,
        p_dest_org   sc_possible_problems.com_org%TYPE)
    IS
    BEGIN
        api$sc_possible_problems.forward_sc_possible_problems (p_spp_id,
                                                               p_dest_org);
    END;

    --Можлива проблема з СРКО - оброблена
    PROCEDURE make_processed (
        p_spp_id              sc_possible_problems.spp_id%TYPE,
        p_spp_decision_desc   sc_possible_problems.spp_decision_desc%TYPE)
    IS
    BEGIN
        api$sc_possible_problems.make_processed (p_spp_id,
                                                 p_spp_decision_desc);
    END;

    --Можлива проблема з СРКО - не підтвердилось
    PROCEDURE make_not_confirmed (
        p_spp_id              sc_possible_problems.spp_id%TYPE,
        p_spp_decision_desc   sc_possible_problems.spp_decision_desc%TYPE)
    IS
    BEGIN
        api$sc_possible_problems.make_not_confirmed (p_spp_id,
                                                     p_spp_decision_desc);
    END;
BEGIN
    NULL;
END DNET$SC_POSSIBLE_PROBLEMS;
/