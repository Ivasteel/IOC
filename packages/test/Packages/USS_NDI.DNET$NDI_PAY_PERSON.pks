/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$NDI_PAY_PERSON
IS
    Package_Name   CONSTANT VARCHAR2 (100) := 'DNET$NDI_PAY_PERSON';

    TYPE r_ndi_pay_person_acc IS RECORD
    (
        Dppa_Id             ndi_pay_person_acc.dppa_id%TYPE,
        Dppa_Dpp            ndi_pay_person_acc.dppa_dpp%TYPE,
        Dppa_Nb             ndi_pay_person_acc.dppa_nb%TYPE,
        Dppa_Is_Main        ndi_pay_person_acc.dppa_is_main%TYPE,
        --dppa_ab_id                 ndi_pay_person_acc.dppa_ab_id%TYPE,
        Dppa_Account        ndi_pay_person_acc.dppa_account%TYPE,
        Dppa_Nbg            ndi_pay_person_acc.dppa_nbg%TYPE,
        Dppa_Is_Social      ndi_pay_person_acc.dppa_is_social%TYPE,
        Dppa_Description    ndi_pay_person_acc.dppa_description%TYPE
    --dppa_last_payment_order    ndi_pay_person_acc.dppa_last_payment_order%TYPE
    );

    TYPE t_ndi_pay_person_acc IS TABLE OF r_ndi_pay_person_acc;


    PROCEDURE INSERT_PAY_PERSON (
        p_dpp_tax_code       ndi_pay_person.dpp_tax_code%TYPE,
        p_dpp_name           ndi_pay_person.dpp_name%TYPE,
        p_dpp_org            ndi_pay_person.dpp_org%TYPE,
        p_dpp_is_ur          ndi_pay_person.dpp_is_ur%TYPE,
        p_dpp_sname          ndi_pay_person.dpp_sname%TYPE,
        p_dpp_address        ndi_pay_person.dpp_address%TYPE,
        p_dpp_tp             ndi_pay_person.dpp_tp%TYPE,
        p_dpp_id         OUT ndi_pay_person.dpp_id%TYPE);

    PROCEDURE UPDATE_PAY_PERSON (
        p_dpp_id         ndi_pay_person.dpp_id%TYPE,
        p_dpp_tax_code   ndi_pay_person.dpp_tax_code%TYPE,
        p_dpp_name       ndi_pay_person.dpp_name%TYPE,
        p_dpp_org        ndi_pay_person.dpp_org%TYPE,
        p_dpp_is_ur      ndi_pay_person.dpp_is_ur%TYPE,
        p_dpp_sname      ndi_pay_person.dpp_sname%TYPE,
        p_dpp_address    ndi_pay_person.dpp_address%TYPE,
        p_dpp_tp         ndi_pay_person.dpp_tp%TYPE);

    PROCEDURE DELETE_PAY_PERSON (p_dpp_id IN ndi_pay_person.dpp_Id%TYPE);

    -- журнал
    PROCEDURE GET_JOURNAL (
        P_DPP_TAX_CODE   IN     ndi_pay_person.dpp_tax_code%TYPE,
        P_DPP_NAME       IN     ndi_pay_person.dpp_name%TYPE,
        P_DPP_TP         IN     ndi_pay_person.dpp_tp%TYPE,
        res_cur             OUT SYS_REFCURSOR);

    -- картка
    PROCEDURE GET_PAY_PERSON_CARD (P_DPP_ID   IN     NUMBER,
                                   RES_CUR       OUT SYS_REFCURSOR,
                                   ACC_CUR       OUT SYS_REFCURSOR);

    -- збереження картки
    PROCEDURE SAVE_PAY_PERSON_CARD (
        p_dpp_id         IN     uss_ndi.ndi_pay_person.dpp_id%TYPE,
        p_dpp_tp         IN     uss_ndi.ndi_pay_person.dpp_tp%TYPE,
        p_dpp_org        IN     uss_ndi.ndi_pay_person.dpp_org%TYPE,
        p_dpp_name       IN     uss_ndi.ndi_pay_person.dpp_name%TYPE,
        p_dpp_sname      IN     uss_ndi.ndi_pay_person.dpp_sname%TYPE,
        p_dpp_tax_code   IN     uss_ndi.ndi_pay_person.dpp_tax_code%TYPE,
        p_dpp_address    IN     uss_ndi.ndi_pay_person.dpp_address%TYPE,
        p_Dpp_Is_Ur      IN     uss_ndi.ndi_pay_person.Dpp_Is_Ur%TYPE,
        p_xml            IN     CLOB,
        p_new_id            OUT uss_ndi.ndi_pay_person.dpp_id%TYPE);

    PROCEDURE GET_PAY_PERSON (
        p_dpp_id           IN     ndi_pay_person.dpp_id%TYPE,
        p_dpp_tax_code        OUT ndi_pay_person.dpp_tax_code%TYPE,
        p_dpp_name            OUT ndi_pay_person.dpp_name%TYPE,
        p_dpp_org             OUT ndi_pay_person.dpp_org%TYPE,
        p_history_status      OUT ndi_pay_person_acc.history_status%TYPE,
        p_dpp_is_ur           OUT ndi_pay_person.dpp_is_ur%TYPE,
        p_dpp_sname           OUT ndi_pay_person.dpp_sname%TYPE,
        p_dpp_address         OUT ndi_pay_person.dpp_address%TYPE,
        p_dpp_tp              OUT ndi_pay_person.dpp_tp%TYPE);

    PROCEDURE GET_PAY_PERSON_ACC (
        P_DPPA_DPP         IN     ndi_pay_person_acc.dppa_dpp%TYPE,
        P_PAY_PERSON_ACC      OUT SYS_REFCURSOR);

    PROCEDURE SAVE_PAY_PERSON_ACC (
        p_dppa_id                   IN OUT ndi_pay_person_acc.dppa_id%TYPE,
        p_dppa_dpp                  IN     ndi_pay_person_acc.dppa_dpp%TYPE,
        p_dppa_nb                   IN     ndi_pay_person_acc.dppa_nb%TYPE,
        p_dppa_is_main              IN     ndi_pay_person_acc.dppa_is_main%TYPE,
        p_dppa_account              IN     ndi_pay_person_acc.dppa_account%TYPE,
        p_dppa_last_payment_order   IN     ndi_pay_person_acc.dppa_last_payment_order%TYPE,
        p_dppa_nbg                  IN     ndi_pay_person_acc.dppa_nbg%TYPE,
        p_dppa_is_social            IN     ndi_pay_person_acc.dppa_is_social%TYPE,
        p_dppa_ab_id                IN     ndi_pay_person_acc.dppa_ab_id%TYPE,
        p_dppa_description          IN     ndi_pay_person_acc.dppa_description%TYPE);

    PROCEDURE DELETE_PAY_PERSON_ACC (
        p_dppa_id   IN ndi_pay_person_acc.dppa_Id%TYPE);
END;
/


GRANT EXECUTE ON USS_NDI.DNET$NDI_PAY_PERSON TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$NDI_PAY_PERSON
IS
    -- unused
    PROCEDURE INSERT_PAY_PERSON (
        p_dpp_tax_code       ndi_pay_person.dpp_tax_code%TYPE,
        p_dpp_name           ndi_pay_person.dpp_name%TYPE,
        p_dpp_org            ndi_pay_person.dpp_org%TYPE,
        p_dpp_is_ur          ndi_pay_person.dpp_is_ur%TYPE,
        p_dpp_sname          ndi_pay_person.dpp_sname%TYPE,
        p_dpp_address        ndi_pay_person.dpp_address%TYPE,
        p_dpp_tp             ndi_pay_person.dpp_tp%TYPE,
        p_dpp_id         OUT ndi_pay_person.dpp_id%TYPE)
    IS
        l_dpp_cnt   NUMBER;
    BEGIN
        -- контроль на дубль суб'єктів по p_dpp_tax_code
        SELECT COUNT (1)
          INTO l_dpp_cnt
          FROM ndi_pay_person p
         WHERE     p.dpp_tax_code = p_dpp_tax_code
               AND p.dpp_tp = p_dpp_tp
               AND p.history_status = 'A';

        IF l_dpp_cnt > 0
        THEN
            Raise_Application_Error (
                -20002,
                   'Суб''єкт даного типу з єдрпоу '
                || p_dpp_tax_code
                || ' вже існує');
        END IF;

        P_DPP_ID :=
            RDM$NDI_PAY_PERSON.insert_ndi_pay_person (
                p_dpp_tax_code   => p_dpp_tax_code,
                p_dpp_name       => p_dpp_name,
                p_dpp_org        => p_dpp_org,
                p_dpp_is_ur      => p_dpp_is_ur,
                p_dpp_sname      => p_dpp_sname,
                p_dpp_address    => p_dpp_address,
                p_dpp_tp         => p_dpp_tp);
    END;

    -- unused
    PROCEDURE UPDATE_PAY_PERSON (
        p_dpp_id         ndi_pay_person.dpp_id%TYPE,
        p_dpp_tax_code   ndi_pay_person.dpp_tax_code%TYPE,
        p_dpp_name       ndi_pay_person.dpp_name%TYPE,
        p_dpp_org        ndi_pay_person.dpp_org%TYPE,
        p_dpp_is_ur      ndi_pay_person.dpp_is_ur%TYPE,
        p_dpp_sname      ndi_pay_person.dpp_sname%TYPE,
        p_dpp_address    ndi_pay_person.dpp_address%TYPE,
        p_dpp_tp         ndi_pay_person.dpp_tp%TYPE)
    IS
        l_dpp_cnt   NUMBER;
    BEGIN
        -- контроль на дубль суб'єктів по p_dpp_tax_code
        SELECT COUNT (1)
          INTO l_dpp_cnt
          FROM ndi_pay_person p
         WHERE     p.dpp_tax_code = p_dpp_tax_code
               AND p.dpp_tp = p_dpp_tp
               AND p.history_status = 'A'
               AND p.dpp_id != p_dpp_id;

        IF l_dpp_cnt > 0
        THEN
            Raise_Application_Error (
                -20002,
                   'Суб''єкт даного типу з єдрпоу '
                || p_dpp_tax_code
                || ' вже існує');
        END IF;

        RDM$NDI_PAY_PERSON.update_ndi_pay_person (
            p_dpp_id         => p_dpp_id,
            p_dpp_tax_code   => p_dpp_tax_code,
            p_dpp_name       => p_dpp_name,
            p_dpp_org        => p_dpp_org,
            p_dpp_is_ur      => p_dpp_is_ur,
            p_dpp_sname      => p_dpp_sname,
            p_dpp_address    => p_dpp_address,
            p_dpp_tp         => p_dpp_tp);
    END;

    PROCEDURE DELETE_PAY_PERSON (p_dpp_id IN ndi_pay_person.dpp_Id%TYPE)
    IS
    BEGIN
        RDM$NDI_PAY_PERSON.set_ndi_pay_person_hist_st (
            p_dpp_id           => p_dpp_id,
            p_History_Status   => 'H');
    END;

    -- журнал
    PROCEDURE GET_JOURNAL (
        P_DPP_TAX_CODE   IN     ndi_pay_person.dpp_tax_code%TYPE,
        P_DPP_NAME       IN     ndi_pay_person.dpp_name%TYPE,
        P_DPP_TP         IN     ndi_pay_person.dpp_tp%TYPE,
        res_cur             OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   d.dic_sname                        AS DPP_TP_NAME,
                   p.org_code || ' ' || p.org_name    AS dpp_org_name,
                   (SELECT MAX (ba)
                      FROM (SELECT    zz.dppa_account
                                   || ' ('
                                   || zz.dppa_description
                                   || ')'                                      AS ba,
                                   ROW_NUMBER ()
                                       OVER (
                                           ORDER BY
                                               zz.dppa_is_main, zz.dppa_id)    AS rn
                              FROM ndi_pay_person_acc zz
                             WHERE     zz.dppa_dpp = t.dpp_id
                                   AND zz.history_status = 'A')
                     WHERE rn = 1)                    AS DPPA_BANK_ACCOUNT
              FROM ndi_pay_person  t
                   LEFT JOIN v_ddn_dpp_tp d ON (d.DIC_VALUE = dpp_tp)
                   LEFT JOIN v_opfu p ON (p.org_id = t.dpp_org)
             WHERE     1 = 1
                   AND (   p_dpp_tax_code IS NULL
                        OR t.dpp_tax_code LIKE '%' || p_dpp_tax_code || '%')
                   AND (   P_DPP_NAME IS NULL
                        OR UPPER (t.dpp_name) LIKE
                               '%' || UPPER (P_DPP_NAME) || '%')
                   AND (P_DPP_TP IS NULL OR t.dpp_tp = P_DPP_TP)
                   AND t.history_status = 'A';
    END;

    -- картка
    PROCEDURE GET_PAY_PERSON_CARD (P_DPP_ID   IN     NUMBER,
                                   RES_CUR       OUT SYS_REFCURSOR,
                                   ACC_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
            SELECT t.*, d.dic_sname AS DPP_TP_NAME
              FROM ndi_pay_person  t
                   LEFT JOIN v_ddn_dpp_tp d ON (d.DIC_VALUE = dpp_tp)
             WHERE t.dpp_id = p_dpp_id;

        OPEN ACC_CUR FOR
            SELECT t.*,
                   bp.nbg_sname     AS dppa_nbg_name,
                   b.nb_sname       AS dppa_nb_name
              FROM ndi_pay_person_acc  t
                   LEFT JOIN ndi_budget_program bp ON bp.nbg_id = t.dppa_nbg
                   LEFT JOIN ndi_bank b ON b.nb_id = t.dppa_nb
             WHERE t.dppa_dpp = p_dpp_id AND t.history_status = 'A';
    END;

    -- збереження картки
    PROCEDURE SAVE_PAY_PERSON_CARD (
        p_dpp_id         IN     uss_ndi.ndi_pay_person.dpp_id%TYPE,
        p_dpp_tp         IN     uss_ndi.ndi_pay_person.dpp_tp%TYPE,
        p_dpp_org        IN     uss_ndi.ndi_pay_person.dpp_org%TYPE,
        p_dpp_name       IN     uss_ndi.ndi_pay_person.dpp_name%TYPE,
        p_dpp_sname      IN     uss_ndi.ndi_pay_person.dpp_sname%TYPE,
        p_dpp_tax_code   IN     uss_ndi.ndi_pay_person.dpp_tax_code%TYPE,
        p_dpp_address    IN     uss_ndi.ndi_pay_person.dpp_address%TYPE,
        p_Dpp_Is_Ur      IN     uss_ndi.ndi_pay_person.Dpp_Is_Ur%TYPE,
        p_xml            IN     CLOB,
        p_new_id            OUT uss_ndi.ndi_pay_person.dpp_id%TYPE)
    IS
        l_new_id   NUMBER;
        l_ids      VARCHAR2 (4000);
        l_arr      t_ndi_pay_person_acc;
    BEGIN
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_ndi_pay_person_acc',
                                         TRUE)
            BULK COLLECT INTO l_arr
            USING p_xml;

        -- create
        IF (p_dpp_id IS NULL OR p_dpp_id = -1)
        THEN
            INSERT INTO ndi_pay_person (dpp_tax_code,
                                        dpp_name,
                                        dpp_org,
                                        history_status,
                                        dpp_sname,
                                        dpp_address,
                                        Dpp_Is_Ur,
                                        dpp_tp)
                 VALUES (p_dpp_tax_code,
                         p_dpp_name,
                         p_dpp_org,
                         'A',
                         p_dpp_sname,
                         p_dpp_address,
                         p_Dpp_Is_Ur,
                         p_dpp_tp)
              RETURNING dpp_id
                   INTO p_new_id;

            FOR xx IN (SELECT * FROM TABLE (l_arr))
            LOOP
                INSERT INTO ndi_pay_person_acc (dppa_dpp,
                                                dppa_nb,
                                                dppa_is_main,
                                                history_status,
                                                dppa_account,
                                                dppa_nbg,
                                                dppa_is_social,
                                                dppa_last_payment_order,
                                                dppa_description)
                     VALUES (p_new_id,
                             xx.dppa_nb,
                             xx.dppa_is_main,
                             'A',
                             xx.dppa_account,
                             xx.dppa_nbg,
                             xx.dppa_is_social,
                             0,
                             xx.dppa_description);
            END LOOP;
        -- update
        ELSE
            p_new_id := p_dpp_id;

            UPDATE ndi_pay_person
               SET dpp_tax_code = p_dpp_tax_code,
                   dpp_name = p_dpp_name,
                   dpp_org = p_dpp_org,
                   dpp_sname = p_dpp_sname,
                   dpp_address = p_dpp_address,
                   dpp_tp = p_dpp_tp,
                   dpp_is_ur = p_dpp_is_ur
             --dpp_hs_upd = p_dpp_hs_upd
             WHERE dpp_id = p_new_id;

            SELECT LISTAGG (dppa_id, ',') WITHIN GROUP (ORDER BY 1)
              INTO l_ids
              FROM TABLE (l_arr)
             WHERE dppa_id IS NOT NULL;

            -- deleted (пробовал напрямую, но оно не работает так, пришлось через переменную)
            UPDATE ndi_pay_person_acc t
               SET t.history_status = 'H'
             WHERE     t.dppa_dpp = p_new_id
                   AND (   l_ids IS NULL
                        OR t.dppa_id NOT IN
                               (    SELECT REGEXP_SUBSTR (
                                               text,
                                               '[^(\,)]+',
                                               1,
                                               LEVEL)    AS z_rdt_id
                                      FROM (SELECT l_ids AS text FROM DUAL)
                                CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                  '[^(\,)]+',
                                                                  1,
                                                                  LEVEL)) > 0));

            -- new
            FOR xx IN (SELECT *
                         FROM TABLE (l_arr) t
                        WHERE t.dppa_id IS NULL OR t.dppa_id < 0)
            LOOP
                INSERT INTO ndi_pay_person_acc (dppa_dpp,
                                                dppa_nb,
                                                dppa_is_main,
                                                history_status,
                                                dppa_account,
                                                dppa_nbg,
                                                dppa_is_social,
                                                dppa_last_payment_order,
                                                dppa_description)
                     VALUES (p_new_id,
                             xx.dppa_nb,
                             xx.dppa_is_main,
                             'A',
                             xx.dppa_account,
                             xx.dppa_nbg,
                             xx.dppa_is_social,
                             0,
                             xx.dppa_description);
            END LOOP;

            -- updated
            FOR xx IN (SELECT *
                         FROM TABLE (l_arr) t
                        WHERE t.dppa_id > 0)
            LOOP
                UPDATE ndi_pay_person_acc
                   SET dppa_dpp = xx.dppa_dpp,
                       dppa_nb = xx.dppa_nb,
                       dppa_is_main = xx.dppa_is_main,
                       dppa_account = xx.dppa_account,
                       dppa_nbg = xx.dppa_nbg,
                       dppa_is_social = xx.dppa_is_social,
                       --dppa_hs_upd = xx.dppa_hs_upd,
                       dppa_description = xx.dppa_description
                 WHERE dppa_id = xx.dppa_id;
            END LOOP;
        END IF;
    END;

    -- unused
    PROCEDURE GET_PAY_PERSON (
        p_dpp_id           IN     ndi_pay_person.dpp_id%TYPE,
        p_dpp_tax_code        OUT ndi_pay_person.dpp_tax_code%TYPE,
        p_dpp_name            OUT ndi_pay_person.dpp_name%TYPE,
        p_dpp_org             OUT ndi_pay_person.dpp_org%TYPE,
        p_history_status      OUT ndi_pay_person_acc.history_status%TYPE,
        p_dpp_is_ur           OUT ndi_pay_person.dpp_is_ur%TYPE,
        p_dpp_sname           OUT ndi_pay_person.dpp_sname%TYPE,
        p_dpp_address         OUT ndi_pay_person.dpp_address%TYPE,
        p_dpp_tp              OUT ndi_pay_person.dpp_tp%TYPE)
    IS
    BEGIN
        SELECT dpp_tax_code,
               dpp_name,
               dpp_org,
               history_status,
               dpp_sname,
               dpp_address,
               dpp_tp,
               dpp_is_ur
          INTO p_dpp_tax_code,
               p_dpp_name,
               p_dpp_org,
               p_history_status,
               p_dpp_sname,
               p_dpp_address,
               p_dpp_tp,
               p_dpp_is_ur
          FROM ndi_pay_person d
         WHERE DPP_ID = P_DPP_ID;
    END;

    PROCEDURE GET_PAY_PERSON_ACC (
        p_dppa_dpp         IN     ndi_pay_person_acc.dppa_dpp%TYPE,
        p_pay_person_acc      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_PAY_PERSON_ACC FOR SELECT *
                                    FROM ndi_pay_person_acc dppa
                                   WHERE dppa.DPPA_DPP = P_DPPA_DPP;
    END;

    -- unused
    PROCEDURE SAVE_PAY_PERSON_ACC (
        p_dppa_id                   IN OUT ndi_pay_person_acc.dppa_id%TYPE,
        p_dppa_dpp                  IN     ndi_pay_person_acc.dppa_dpp%TYPE,
        p_dppa_nb                   IN     ndi_pay_person_acc.dppa_nb%TYPE,
        p_dppa_is_main              IN     ndi_pay_person_acc.dppa_is_main%TYPE,
        p_dppa_account              IN     ndi_pay_person_acc.dppa_account%TYPE,
        p_dppa_last_payment_order   IN     ndi_pay_person_acc.dppa_last_payment_order%TYPE,
        p_dppa_nbg                  IN     ndi_pay_person_acc.dppa_nbg%TYPE,
        p_dppa_is_social            IN     ndi_pay_person_acc.dppa_is_social%TYPE,
        p_dppa_ab_id                IN     ndi_pay_person_acc.dppa_ab_id%TYPE,
        p_dppa_description          IN     ndi_pay_person_acc.dppa_description%TYPE)
    IS
        l_ba_id      NUMBER;
        l_dppa_cnt   NUMBER;
    BEGIN
        -- контроль на дубль разунків суб'єктів по p_dpp_tax_code
        SELECT COUNT (1)
          INTO l_dppa_cnt
          FROM ndi_pay_person_acc a
         WHERE     a.dppa_account = p_dppa_account
               AND a.history_status = 'A'
               AND a.dppa_dpp = p_dppa_dpp
               --and (nvl(p_DPPA_ID, 0) = 0 or p_dppa_id > 0 and dppa_id != p_dppa_id)
               AND dppa_id != NVL (p_DPPA_ID, 0);

        IF l_dppa_cnt > 0
        THEN
            Raise_Application_Error (
                -20002,
                   'Номер рахунку '
                || p_dppa_account
                || ' вже існує для даного суб''єкта');
        END IF;

        IF NVL (p_DPPA_ID, 0) = 0
        THEN
            p_DPPA_ID :=
                RDM$NDI_PAY_PERSON.insert_ndi_pay_person_acc (
                    p_dppa_dpp                  => p_dppa_dpp,
                    p_dppa_nb                   => p_dppa_nb,
                    p_dppa_ab_id                => p_dppa_ab_id,
                    p_dppa_is_main              => p_dppa_is_main,
                    p_dppa_account              => p_dppa_account,
                    p_dppa_last_payment_order   => p_dppa_last_payment_order,
                    p_dppa_nbg                  => p_dppa_nbg,
                    p_dppa_is_social            => p_dppa_is_social,
                    p_dppa_description          => p_dppa_description);
        ELSE
            SELECT t.dppa_ab_id
              INTO l_ba_id
              FROM ndi_pay_person_acc t
             WHERE t.dppa_id = p_DPPA_ID;


            RDM$NDI_PAY_PERSON.update_ndi_pay_person_acc (
                p_dppa_id                   => p_dppa_id,
                p_dppa_dpp                  => p_dppa_dpp,
                p_dppa_nb                   => p_dppa_nb,
                p_dppa_ab_id                => p_dppa_ab_id,
                p_dppa_is_main              => p_dppa_is_main,
                p_dppa_account              => p_dppa_account,
                p_dppa_last_payment_order   => p_dppa_last_payment_order,
                p_dppa_nbg                  => p_dppa_nbg,
                p_dppa_is_social            => p_dppa_is_social,
                p_dppa_description          => p_dppa_description);
        END IF;
    END;

    -- unused
    PROCEDURE DELETE_PAY_PERSON_ACC (
        p_dppa_id   IN ndi_pay_person_acc.dppa_Id%TYPE)
    IS
    BEGIN
        RDM$NDI_PAY_PERSON.set_ndi_pay_person_acc_hist_st (
            p_dppa_id          => p_dppa_id,
            p_History_Status   => 'H');
    END;
END;
/