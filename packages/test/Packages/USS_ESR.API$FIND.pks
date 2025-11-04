/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$FIND
IS
    -- Author  : OLEKSII
    -- Created : 12.05.2023 11:32:53
    -- Purpose :

    CURSOR rAct IS
        SELECT *
          FROM Act
         WHERE 1 = 0;

    TYPE cAct IS TABLE OF ACT%ROWTYPE;

    TYPE cActServices IS TABLE OF AT_SERVICE%ROWTYPE;


    --Запит наявного рішення по людині
    PROCEDURE Get_Act_PDSP (p_sc_id         NUMBER,
                            p_nst_id        NUMBER,
                            p_act_cur   OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_By_Id (p_at_id NUMBER, p_Act_Cur OUT cAct);

    --Запит наявного рішення по людині для припинення
    PROCEDURE Get_Act_Terminate (p_sc_id         NUMBER,
                                 p_nst_id        NUMBER,
                                 p_act_cur   OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_By_Ap (p_Ap_Id        IN     NUMBER,
                             p_At_Tp_List   IN     VARCHAR2,
                             p_Act_Cur         OUT cAct);

    --Запит наявного рішення по людині
    PROCEDURE Get_Decision (p_sc_id        NUMBER,
                            p_nst_id       NUMBER,
                            p_pd_cur   OUT SYS_REFCURSOR);

    -- пошук надавачів соц послуг для соц. картки
    PROCEDURE get_sc_rnspm_list (p_sc_id NUMBER);

    PROCEDURE Get_At_Services_Only (p_At_Id   IN     NUMBER,
                                    p_Res        OUT SYS_REFCURSOR);

    PROCEDURE Get_Tctr_Services_By_Ap (p_Ap_Id   IN     NUMBER,
                                       p_Res        OUT SYS_REFCURSOR);

    PROCEDURE Get_Apop_Services_By_Ap (p_Ap_Id   IN     NUMBER,
                                       p_Res        OUT cActServices);

    FUNCTION Is_Esr_Appeal_Reg (p_Ap_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION Check_Attr_801_Serv_To (p_Ap_Id       IN APPEAL.AP_ID%TYPE,
                                     p_Ap_ServTo   IN VARCHAR2,
                                     p_Rel_Tp      IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Init_Act_By_Appeal (p_Ap_Id IN APPEAL.AP_ID%TYPE);


    PROCEDURE Get_avalilable_dzr_by_sc (p_sc_id   IN     NUMBER,
                                        p_res        OUT SYS_REFCURSOR);

    FUNCTION Get_avalilable_dzr_by_sc_list (p_sc_id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_At_Atp_Num_By_FIO (p_Ap_id   IN NUMBER,
                                    p_At_Tp   IN VARCHAR2,
                                    p_Ln      IN VARCHAR2,
                                    p_Mn      IN VARCHAR2,
                                    p_Fn      IN VARCHAR2)
        RETURN NUMBER;

    -- чи є запис в at_wares (1 - є/0 - немає)
    FUNCTION has_at_ware (p_scdr_id IN NUMBER)
        RETURN NUMBER;

    -- кількість записів в at_wares
    FUNCTION get_at_ware_cnt (p_scdr_id IN NUMBER)
        RETURN NUMBER;

    --кількість замовленою вже (таблиця AT_WARES з посиланням на таблицю рекомендованих ATW_SCDR з причиною ATW_ST != 'RJ')
    FUNCTION Get_wrn_count (p_sc act.at_sc%TYPE, p_wrn AT_WARES.ATW_WRN%TYPE)
        RETURN NUMBER;
END API$FIND;
/


GRANT EXECUTE ON USS_ESR.API$FIND TO II01RC_USS_ESR_AP_COPY
/

GRANT EXECUTE ON USS_ESR.API$FIND TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.API$FIND TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.API$FIND TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.API$FIND TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.API$FIND TO USS_VISIT
/


/* Formatted on 8/12/2025 5:49:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$FIND
IS
    PROCEDURE Get_Act_PDSP (p_sc_id         NUMBER,
                            p_nst_id        NUMBER,
                            p_act_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_act_cur FOR
            SELECT at_id
              FROM act
                   JOIN at_service s
                       ON ats_at = at_id AND s.history_status = 'A'
                   JOIN personalcase ON pc_id = at_pc AND pc_sc = p_sc_id
             WHERE     at_tp = 'PDSP'
                   AND ats_nst = p_nst_id
                   AND at_st IN ('SA', 'O.SA', 'SV');
    END;

    PROCEDURE Get_Act_By_Id (p_at_id NUMBER, p_Act_Cur OUT cAct)
    IS
    BEGIN
        SELECT *
          BULK COLLECT INTO p_Act_Cur
          FROM act
         WHERE at_id = p_at_id;
    END;


    PROCEDURE Get_Act_Terminate (p_sc_id         NUMBER,
                                 p_nst_id        NUMBER,
                                 p_act_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_act_cur FOR
            SELECT at_id
              FROM act
                   JOIN at_service s
                       ON ats_at = at_id AND s.history_status = 'A'
                   JOIN personalcase ON pc_id = at_pc AND pc_sc = p_sc_id
             WHERE at_tp = 'TCTR' AND ats_nst = p_nst_id AND at_st IN ('DT');
    END;

    PROCEDURE Get_Decision (p_sc_id        NUMBER,
                            p_nst_id       NUMBER,
                            p_pd_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_pd_cur FOR
            SELECT pd_id
              FROM pc_decision
                   JOIN personalcase ON pc_id = pd_pc AND pc_sc = p_sc_id
             WHERE pd_nst = p_nst_id AND pd_st IN ('S', 'P', 'O.P');
    END;

    -- пошук надавачів соц послуг для соц. картки
    PROCEDURE get_sc_rnspm_list (p_sc_id NUMBER)
    IS
    BEGIN
        DELETE FROM tmp_work_set1;

        INSERT INTO tmp_work_set1 (x_id1)
            SELECT DISTINCT z.at_rnspm
              FROM v_act z
             WHERE 1 = 1 AND z.at_sc = p_sc_id --AND z.at_st IN ('SV')
                                               AND z.at_tp = 'PDSP';
    END;

    PROCEDURE Get_Act_By_Ap (p_Ap_Id        IN     NUMBER,
                             p_At_Tp_List   IN     VARCHAR2,
                             p_Act_Cur         OUT cAct)
    IS
    BEGIN
        SELECT *
          BULK COLLECT INTO p_Act_Cur
          FROM act
         WHERE     At_Ap = p_Ap_Id
               AND At_Tp IN
                       (SELECT CAST (COLUMN_VALUE AS VARCHAR2 (50))
                          FROM Tools.split_clob (p_At_Tp_List));
    END;

    --         ОТРИМАННЯ ПОСЛУГ
    -----------------------------------------------------------
    PROCEDURE Get_At_Services_Only (p_At_Id   IN     NUMBER,
                                    p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        API$ACT.Get_Services_Only (p_At_Id, p_Res);
    END;

    PROCEDURE Get_Tctr_Services_By_Ap (p_Ap_Id   IN     NUMBER,
                                       p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        CMES$ACT_TCTR.Get_Services_By_Ap (p_Ap_Id, p_Res);
    END;

    PROCEDURE Get_Apop_Services_By_Ap (p_Ap_Id   IN     NUMBER,
                                       p_Res        OUT cActServices)
    IS
    BEGIN
        SELECT s.*
          BULK COLLECT INTO p_Res
          FROM At_Service s JOIN Act a ON s.ats_at = a.at_id
         WHERE     a.at_ap = p_Ap_Id
               AND a.at_tp = 'APOP'
               AND s.history_status = 'A';
    END;

    FUNCTION Check_Attr_801_Serv_To (p_Ap_Id       IN APPEAL.AP_ID%TYPE,
                                     p_Ap_ServTo   IN VARCHAR2,
                                     p_Rel_Tp      IN VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN Api$appeal.Get_Attr_801_ChkQty (p_Ap_Id       => p_Ap_Id,
                                               p_Ap_ServTo   => p_Ap_ServTo,
                                               p_Rel_Tp      => p_Rel_Tp);
    END;

    FUNCTION Is_Esr_Appeal_Reg (p_Ap_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_qty   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_qty
          FROM uss_esr.appeal z
         WHERE z.ap_id = p_Ap_Id;

        RETURN l_qty;
    END;

    --#109549
    PROCEDURE Init_Act_By_Appeal (p_Ap_Id IN APPEAL.AP_ID%TYPE)
    IS
        l_Message   SYS_REFCURSOR;
    BEGIN
        API$ACT.Init_Act_By_Appeals (5, p_Ap_Id, l_Message);
    END;

    --#113474
    PROCEDURE Get_avalilable_dzr_by_sc (p_sc_id   IN     NUMBER,
                                        p_res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT id,
                   name,
                   code,
                   wrn_issue_max,
                   wrn_mult_qnt,
                   CASE WHEN used_dzr_qnt > 0 THEN 1 ELSE 0 END     used_dzr,
                   used_dzr_qnt
              FROM (SELECT                                          --w.wrn_id
                           r.scdr_id                                AS id,
                           w.wrn_name                               AS name,
                           w.wrn_shifr                              AS code,
                           w.wrn_issue_max,
                           w.wrn_mult_qnt,
                           (SELECT COUNT (1)
                              FROM act  ac
                                   JOIN at_wares atw
                                       ON     ac.at_id = atw.atw_at
                                          AND atw.history_status = 'A'
                             WHERE     ac.at_tp = 'NDZR'
                                   AND atw.atw_st NOT IN ('RJ')
                                   AND ac.at_sc = r.scdr_sc
                                   AND w.wrn_id = atw.atw_wrn
                                   AND r.scdr_id = atw.atw_scdr)    used_dzr_qnt
                      FROM uss_ndi.v_ndi_cbi_wares  w
                           JOIN uss_person.v_sc_dzr_recomm r
                               ON w.wrn_id = r.scdr_wrn
                     WHERE     r.history_status = 'A'
                           AND r.scdr_sc = p_sc_id
                           AND w.wrn_issue_max IS NOT NULL
                           AND w.wrn_mult_qnt IS NOT NULL/*
                                                         AND NOT EXISTS(SELECT 1--ac.at_sc, atw.atw_wrn, atw.atw_st
                                                                        FROM act ac
                                                                        JOIN at_wares atw
                                                                          ON ac.at_id = atw.atw_at
                                                                         AND atw.history_status='A'
                                                                        WHERE ac.at_tp = 'NDZR'
                                                                          AND atw.atw_st NOT IN ('RJ')
                                                                          AND ac.at_sc = r.scdr_sc
                                                                          AND w.wrn_id =  atw.atw_wrn
                                                                          AND r.scdr_id = atw.atw_scdr)
                                                      */
                                                         );
    END;

    --#113305
    FUNCTION Get_avalilable_dzr_by_sc_list (p_sc_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (4000);
    BEGIN
        SELECT LISTAGG (r.scdr_wrn, ',')
          INTO l_res
          FROM uss_person.v_sc_dzr_recomm r
         WHERE     r.history_status = 'A'
               AND r.scdr_sc = p_sc_id
               AND NOT EXISTS
                       (SELECT 1           --ac.at_sc, atw.atw_wrn, atw.atw_st
                          FROM act  ac
                               JOIN at_wares atw
                                   ON     ac.at_id = atw.atw_at
                                      AND atw.history_status = 'A'
                         WHERE     ac.at_tp = 'NDZR'
                               AND atw.atw_st NOT IN ('RJ')
                               AND ac.at_sc = r.scdr_sc
                               AND r.scdr_wrn = atw.atw_wrn
                               AND r.scdr_id = atw.atw_scdr);

        RETURN l_res;
    END;

    FUNCTION Get_At_Atp_Num_By_FIO (p_Ap_id   IN NUMBER,
                                    p_At_Tp   IN VARCHAR2,
                                    p_Ln      IN VARCHAR2,
                                    p_Mn      IN VARCHAR2,
                                    p_Fn      IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT atp.atp_num
          INTO l_Res
          FROM at_person  atp
               JOIN Act at
                   ON     atp.atp_at = at.at_id
                      AND at.at_tp = p_At_Tp
                      AND at.at_ap = p_Ap_id
         WHERE     UPPER (atp.atp_ln) = UPPER (p_Ln)
               AND UPPER (atp.atp_mn) = UPPER (p_Mn)
               AND UPPER (atp.atp_fn) = UPPER (p_Fn)
               AND atp.history_status = 'A';

        RETURN l_Res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
        WHEN TOO_MANY_ROWS
        THEN
            RETURN NULL;
    END;

    -- чи є запис в at_wares (1 - є/0 - немає)
    FUNCTION has_at_ware (p_scdr_id IN NUMBER)
        RETURN NUMBER
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM at_wares t
         WHERE t.atw_scdr = p_scdr_id AND t.atw_st != 'RJ';

        RETURN CASE WHEN l_cnt > 0 THEN 1 ELSE 0 END;
    END;

    -- кількість записів в at_wares
    FUNCTION get_at_ware_cnt (p_scdr_id IN NUMBER)
        RETURN NUMBER
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM at_wares t
         WHERE t.atw_scdr = p_scdr_id AND t.atw_st != 'RJ';

        RETURN l_cnt;
    END;

    --кількість замовленою вже (таблиця AT_WARES з посиланням на таблицю рекомендованих ATW_SCDR з причиною ATW_ST != 'RJ')
    FUNCTION Get_wrn_count (p_sc act.at_sc%TYPE, p_wrn AT_WARES.ATW_WRN%TYPE)
        RETURN NUMBER
    IS
        ret   NUMBER (10);
    BEGIN
        SELECT COUNT (1)
          INTO ret
          FROM act  a
               JOIN AT_WARES w
                   ON     w.atw_at = a.at_id
                      AND w.atw_st != 'RJ'
                      AND w.history_status = 'A'
         WHERE a.at_sc = p_sc AND w.atw_wrn = p_wrn;

        RETURN ret;
    END;
BEGIN
    NULL;
END API$FIND;
/