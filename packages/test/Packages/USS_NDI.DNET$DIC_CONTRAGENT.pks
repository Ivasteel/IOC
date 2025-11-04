/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$DIC_CONTRAGENT
IS
    -- рахунки
    PROCEDURE get_pay_person_acc_list (p_dpp_id   IN     NUMBER,
                                       res_cur       OUT SYS_REFCURSOR);



    Package_Name   CONSTANT VARCHAR2 (100) := 'DNET$DIC_CONTRAGENT';

    TYPE r_ndi_pay_person_acc
        IS RECORD
    (
        Dppa_Id                    ndi_pay_person_acc.dppa_id%TYPE,
        Dppa_Dpp                   ndi_pay_person_acc.dppa_dpp%TYPE,
        Dppa_Nb                    ndi_pay_person_acc.dppa_nb%TYPE,
        Dppa_Is_Main               ndi_pay_person_acc.dppa_is_main%TYPE,
        --dppa_ab_id                 ndi_pay_person_acc.dppa_ab_id%TYPE,
        Dppa_Account               ndi_pay_person_acc.dppa_account%TYPE,
        Dppa_Nbg                   ndi_pay_person_acc.dppa_nbg%TYPE,
        Dppa_Is_Social             ndi_pay_person_acc.dppa_is_social%TYPE,
        Dppa_Description           ndi_pay_person_acc.dppa_description%TYPE,
        Dppa_Last_Payment_Order    ndi_pay_person_acc.dppa_last_payment_order%TYPE,
        Dppa_Nb_Filia_Num          ndi_pay_person_acc.dppa_nb_filia_num%TYPE
    );

    TYPE t_ndi_pay_person_acc IS TABLE OF r_ndi_pay_person_acc;

    TYPE t_id_arr IS TABLE OF NUMBER;


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
        P_DPP_ORG        IN     ndi_pay_person.dpp_org%TYPE,
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
        p_dppa_description          IN     ndi_pay_person_acc.dppa_description%TYPE,
        p_dppa_nb_filia_num         IN     ndi_pay_person_acc.dppa_nb_filia_num%TYPE);

    PROCEDURE DELETE_PAY_PERSON_ACC (
        p_dppa_id   IN ndi_pay_person_acc.dppa_Id%TYPE);


    ---------------------------------------------------------
    --------------- Банківські рахунки власні ---------------

    PROCEDURE GET_OWN_PAY_PERSON_CARD (RES_CUR   OUT SYS_REFCURSOR,
                                       ACC_CUR   OUT SYS_REFCURSOR);
END DNET$DIC_CONTRAGENT;
/


GRANT EXECUTE ON USS_NDI.DNET$DIC_CONTRAGENT TO DNET_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_CONTRAGENT TO II01RC_USS_NDI_PORTAL
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_CONTRAGENT TO II01RC_USS_NDI_WEB
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_CONTRAGENT TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:55:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$DIC_CONTRAGENT
IS
    -- рахунки
    PROCEDURE get_pay_person_acc_list (p_dpp_id   IN     NUMBER,
                                       res_cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        API$DIC_CONTRAGENT.get_pay_person_acc_list (p_dpp_id   => p_dpp_id,
                                                    res_cur    => res_cur);
    END;



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
            API$DIC_CONTRAGENT.insert_ndi_pay_person (
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
        tools.check_user_and_raise (3);

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

        API$DIC_CONTRAGENT.update_ndi_pay_person (
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
        l_flag   NUMBER;
    BEGIN
        tools.check_user_and_raise (3);

        SELECT COUNT (*)
          INTO l_flag
          FROM ndi_pay_person t
         WHERE     t.dpp_id = p_dpp_id
               AND t.history_status = 'A'
               AND t.dpp_tp = 'OSZN';

        IF (l_flag > 0)
        THEN
            raise_application_error (-20000,
                                     'Контрагент ОСЗН видаляти не можна!');
        END IF;

        API$DIC_CONTRAGENT.set_ndi_pay_person_hist_st (
            p_dpp_id           => p_dpp_id,
            p_History_Status   => 'H');
    END;

    -- журнал
    PROCEDURE GET_JOURNAL (
        P_DPP_TAX_CODE   IN     ndi_pay_person.dpp_tax_code%TYPE,
        P_DPP_NAME       IN     ndi_pay_person.dpp_name%TYPE,
        P_DPP_TP         IN     ndi_pay_person.dpp_tp%TYPE,
        P_DPP_ORG        IN     ndi_pay_person.dpp_org%TYPE,
        res_cur             OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (12);

        OPEN res_cur FOR
            SELECT t.*,
                   d.dic_sname                        AS DPP_TP_NAME,
                   p.org_code || ' ' || p.org_name    AS dpp_org_name,
                   (SELECT MAX (ba)
                      FROM (SELECT zz.dppa_account /*|| ' (' || zz.dppa_description || ')'*/
                                                                               AS ba,
                                   ROW_NUMBER () OVER (ORDER BY zz.dppa_id)    AS rn
                              FROM ndi_pay_person_acc zz
                             WHERE     zz.dppa_dpp = t.dpp_id
                                   AND zz.history_status = 'A'
                                   AND zz.dppa_is_main = '1')
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
                   AND (P_DPP_ORG IS NULL OR t.dpp_org = P_DPP_ORG)
                   AND t.history_status = 'A';
    END;

    -- картка
    PROCEDURE GET_PAY_PERSON_CARD (P_DPP_ID   IN     NUMBER,
                                   RES_CUR       OUT SYS_REFCURSOR,
                                   ACC_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (3); -- #76808 Надати доступ до довідників на перегляд для користувачів W_ESR_KPAYROLL та W_ESR_BUDGET_INSP

        OPEN RES_CUR FOR
            SELECT t.*, d.dic_sname AS DPP_TP_NAME, op.org_to AS DPP_ORG_TO
              FROM ndi_pay_person  t
                   LEFT JOIN v_ddn_dpp_tp d ON (d.DIC_VALUE = dpp_tp)
                   LEFT JOIN v_opfu op ON t.dpp_org = op.org_id
             WHERE t.dpp_id = p_dpp_id;

        OPEN ACC_CUR FOR
            SELECT t.dppa_id,
                   t.dppa_dpp,
                   t.dppa_nb,
                   t.dppa_is_main,
                   t.dppa_ab_id,
                   t.history_status,
                   CASE
                       WHEN SUBSTR (t.dppa_account, 1, 2) = 'UA'
                       THEN
                           SUBSTR (t.dppa_account, 3)
                       ELSE
                           t.dppa_account
                   END             AS dppa_account,
                   t.dppa_nbg,
                   t.dppa_is_social,
                   t.dppa_last_payment_order,
                   t.dppa_hs_upd,
                   t.dppa_hs_del,
                   t.dppa_description,
                   t.dppa_nb_filia_num,
                   bp.nbg_sname    AS dppa_nbg_name,
                   b.nb_sname      AS dppa_nb_name
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
        --l_ids VARCHAR2(4000);
        l_idx_arr      t_id_arr := t_id_arr ();
        l_arr          t_ndi_pay_person_acc;
        l_dpp_cnt      NUMBER;
        l_dpp_tp_cnt   NUMBER;
        l_dpp_tax      NUMBER;
        l_fin_pay      NUMBER;
        l_cnt          NUMBER;
        l_Err_Text     VARCHAR2 (4000);
    BEGIN
        tools.check_user_and_raise (3);

        -- контроль на дубль суб'єктів по p_dpp_org
        -- raise_application_error(-20000, 'p_dpp_org='||p_dpp_org||';p_dpp_id='||p_dpp_id||';p_dpp_tp='||p_dpp_tp);
        SELECT COUNT (1)
          INTO l_dpp_cnt
          FROM ndi_pay_person p
         WHERE     1 = 1
               AND dpp_org = p_dpp_org
               AND dpp_tp = p_dpp_tp
               AND dpp_tp = 'OSZN'
               AND (   (dpp_id != p_dpp_id)
                    OR (    dpp_id = p_dpp_id
                        AND dpp_org IS NOT NULL
                        AND dpp_org != p_dpp_org))
               AND p.history_status = 'A';

        IF (l_dpp_cnt > 0)
        THEN
            raise_application_error (
                -20002,
                'Суб''єкт даного типу з ОСЗН ' || p_dpp_org                       --|| ' та типом '
                                                            --|| p_dpp_tp
                                                            || ' вже існує');
        END IF;

        -- контроль на дубль суб'єктів по p_dpp_tax_code
        SELECT COUNT (1)
          INTO l_dpp_tax
          FROM ndi_pay_person p
         WHERE     dpp_tax_code = p_dpp_tax_code
               AND dpp_tp = p_dpp_tp
               AND (   (dpp_id != p_dpp_id)
                    OR (dpp_id = p_dpp_id AND dpp_tax_code != p_dpp_tax_code))
               AND p.history_status = 'A';

        /* IF (l_dpp_tax > 0) THEN
           raise_application_error(-20002,
                                   'Суб''єкт даного типу з ЄДРПОУ ' ||
                                   p_dpp_tax_code || ' вже існує');
         END IF;*/
        /* SELECT
          sign(NVL(SUM( CASE dpp_org    WHEN p_dpp_org    THEN 1 ELSE 0 END ),0)),
          sign(NVL(SUM( CASE dpp_tp    WHEN p_dpp_tp    THEN 1 ELSE 0 END ),0))

         INTO l_dpp_cnt, l_dpp_tp_cnt
         FROM v_ndi_pay_person np
         WHERE (
                 (dpp_org = p_dpp_org and dpp_tp = p_dpp_tp )
                 and (
                          (dpp_id !=p_dpp_id)
                             or (dpp_id =p_dpp_id and dpp_org!=p_dpp_org)
                      )
         )
         AND history_status = 'A';
         IF l_dpp_cnt = 1  and l_dpp_tp_cnt=1 THEN
           raise_application_error(-20002,
                                   'Суб''єкт даного типу з ОСЗН ' || p_dpp_org || ' та типом '|| p_dpp_tp||' вже існує');
         END IF;*/


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
                                                dppa_description,
                                                dppa_last_payment_order,
                                                dppa_nb_filia_num,
                                                dppa_hs_upd)
                     VALUES (p_new_id,
                             xx.dppa_nb,
                             xx.dppa_is_main,
                             'A',
                             'UA' || xx.dppa_account,
                             xx.dppa_nbg,
                             xx.dppa_is_social,
                             xx.dppa_description,
                             xx.dppa_last_payment_order,
                             xx.dppa_nb_filia_num,
                             TOOLS.GetHistSession);
            END LOOP;
        -- update
        ELSE
            p_new_id := p_dpp_id;

            --Запросим перечень удаляемых счетов, по которым есть работа
            SELECT LISTAGG (t.dppa_account, ', ') WITHIN GROUP (ORDER BY 1)
              INTO l_Err_Text
              FROM ndi_pay_person_acc t
             WHERE     t.dppa_dpp = p_new_id
                   AND t.history_status = 'A'
                   AND t.dppa_id NOT IN (SELECT dppa_id
                                           FROM TABLE (l_arr)
                                          WHERE NVL (dppa_id, 0) > 0)
                   AND EXISTS
                           (SELECT 1
                              FROM v_ndi_fin_pay_config fpc
                             WHERE     fpc.nfpc_dppa = t.dppa_id
                                   AND fpc.history_status = 'A');

            --Если перечень удаляемых счетов, по которым есть работа, не пуст, то ошибка
            IF l_Err_Text IS NOT NULL
            THEN
                raise_application_error (
                    -20002,
                       'Видалити рахунки ('
                    || l_Err_Text
                    || ') неможливо, оскільки є налаштування рахунків для виплат');
            END IF;


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

            ------------------------------------------------------
            /*
                  SELECT listagg(dppa_id, ',') within GROUP (ORDER BY 1)
                    INTO l_ids
                    FROM TABLE(l_arr)
                   WHERE dppa_id IS NOT NULL;

                      --контроль на видалення рядка в гриді чи є посилання на неї в таблиці ndi_fin_pay_config
                  SELECT COUNT(1)
                    INTO l_fin_pay
                  FROM v_ndi_fin_pay_config fpc
                  WHERE fpc.nfpc_dppa = p_new_id
                  AND fpc.history_status = 'A'
                  AND fpc.nfpc_dppa IN (
                      SELECT ppa.dppa_id
                      FROM ndi_pay_person_acc ppa
                      where ppa.history_status='A'
                  )
                   AND (l_ids IS NULL
                          OR fpc.nfpc_dppa NOT IN (select regexp_substr(text ,'[^(\,)]+', 1, level)  as z_rdt_id
                                              from (select l_ids as text from dual)
                                           connect by length(regexp_substr(text ,'[^(\,)]+', 1, level)) > 0));

                  IF (l_fin_pay > 0) THEN
                    raise_application_error(-20002,
                                            ' видалення рядка в гриді ' ||
                                            p_dpp_tax_code || ' вже існує');
                  END IF;*/
            --Закриємо старі записи


            FOR xx
                IN (SELECT t.dppa_id
                      FROM ndi_pay_person_acc  t
                           LEFT JOIN TABLE (l_arr) z
                               ON (z.dppa_id = t.dppa_id)
                     WHERE     t.dppa_dpp = p_new_id
                           AND t.dppa_id NOT IN (SELECT dppa_id
                                                   FROM TABLE (l_arr)
                                                  WHERE NVL (dppa_id, 0) > 0))
            LOOP
                UPDATE ndi_pay_person_acc t
                   SET t.history_status = 'H',
                       dppa_hs_del = TOOLS.GetHistSession
                 WHERE t.dppa_id = xx.dppa_id;
            END LOOP;

            /*    UPDATE ndi_pay_person_acc t SET
                     t.history_status = 'H'
                WHERE t.dppa_dpp = p_new_id
                      AND t.dppa_id NOT IN (SELECT dppa_id FROM TABLE(l_arr) WHERE nvl(dppa_id,0)>0)
                      ;*/

            FOR p1 IN (SELECT t.*
                         FROM TABLE (l_arr) t)
            LOOP
                IF (p1.dppa_id IS NULL OR p1.dppa_id < 0)
                THEN
                    INSERT INTO ndi_pay_person_acc p (
                                    p.dppa_dpp,
                                    p.dppa_nb,
                                    p.dppa_is_main,
                                    p.history_status,
                                    p.dppa_account,
                                    p.dppa_nbg,
                                    p.dppa_is_social,
                                    p.dppa_description,
                                    p.dppa_last_payment_order,
                                    p.dppa_nb_filia_num,
                                    dppa_hs_upd)
                             VALUES (
                                        p_new_id,
                                        p1.dppa_nb,
                                        p1.dppa_is_main,
                                        'A',
                                        CASE
                                            WHEN SUBSTR (p1.dppa_account,
                                                         1,
                                                         2) =
                                                 'UA'
                                            THEN
                                                p1.dppa_account
                                            ELSE
                                                'UA' || p1.dppa_account
                                        END,
                                        p1.dppa_nbg,
                                        p1.dppa_is_social,
                                        p1.dppa_description,
                                        p1.dppa_last_payment_order,
                                        p1.dppa_nb_filia_num,
                                        TOOLS.GetHistSession);
                ELSE
                    UPDATE ndi_pay_person_acc p
                       SET p.dppa_dpp = p1.dppa_dpp,
                           p.dppa_nb = p1.dppa_nb,
                           p.dppa_is_main = p1.dppa_is_main,
                           p.dppa_account =
                               CASE
                                   WHEN SUBSTR (p1.dppa_account, 1, 2) = 'UA'
                                   THEN
                                       p1.dppa_account
                                   ELSE
                                       'UA' || p1.dppa_account
                               END,
                           p.dppa_nbg = p1.dppa_nbg,
                           p.dppa_is_social = p1.dppa_is_social,
                           p.dppa_last_payment_order =
                               p1.dppa_last_payment_order,
                           p.dppa_description = p1.dppa_description,
                           p.dppa_nb_filia_num = p1.dppa_nb_filia_num,
                           dppa_hs_upd = TOOLS.GetHistSession
                     WHERE p.dppa_id = p1.dppa_id;
                END IF;
            END LOOP;
        --Зробимо insert та update
        /* MERGE INTO ndi_pay_person_acc p
         USING (    SELECT NULL dppa_id, p_new_id AS dppa_dpp, dppa_nb, dppa_is_main, 'A' AS history_status, 'UA' || dppa_account AS dppa_account, dppa_nbg,
                        dppa_is_social, 0 AS dppa_last_payment_order, dppa_description
                    FROM TABLE(l_arr)
               ) p1
         ON (p.dppa_id = p1.dppa_id)
         WHEN MATCHED THEN UPDATE SET
                p.dppa_dpp         = p1.dppa_dpp,
                p.dppa_nb          = p1.dppa_nb,
                p.dppa_is_main     = p1.dppa_is_main,
                p.dppa_account     = p1.dppa_account,
                p.dppa_nbg         = p1.dppa_nbg,
                p.dppa_is_social   = p1.dppa_is_social,
                p.dppa_description = p1.dppa_description
         WHEN NOT MATCHED THEN INSERT (p.dppa_dpp, p.dppa_nb, p.dppa_is_main, p.history_status, p.dppa_account, p.dppa_nbg,
                                       p.dppa_is_social, p.dppa_last_payment_order, p.dppa_description)
                               VALUES (p1.dppa_dpp, p1.dppa_nb, p1.dppa_is_main, p1.history_status, p1.dppa_account, p1.dppa_nbg,
                                       p1.dppa_is_social, p1.dppa_last_payment_order, p1.dppa_description);*/


        /*
              -- deleted (пробовал напрямую, но оно не работает так, пришлось через переменную)
              UPDATE ndi_pay_person_acc t
                 SET t.history_status = 'H'
               WHERE t.dppa_dpp = p_new_id
                 AND (l_ids IS NULL
                      OR t.dppa_id NOT IN (select regexp_substr(text ,'[^(\,)]+', 1, level)  as z_rdt_id
                                          from (select l_ids as text from dual)
                                       connect by length(regexp_substr(text ,'[^(\,)]+', 1, level)) > 0));

              -- new
              FOR xx IN (SELECT * FROM TABLE(l_arr) t WHERE t.dppa_id IS NULL OR t.dppa_id < 0) LOOP
                 INSERT INTO ndi_pay_person_acc
                   (dppa_dpp, dppa_nb, dppa_is_main, history_status, dppa_account, dppa_nbg,
                             dppa_is_social, dppa_last_payment_order, dppa_description)
                 VALUES
                   (p_new_id, xx.dppa_nb, xx.dppa_is_main, 'A', 'UA' || xx.dppa_account, xx.dppa_nbg,
                              xx.dppa_is_social, 0, xx.dppa_description);
              END LOOP;

              -- updated
              FOR xx IN (SELECT * FROM TABLE(l_arr) t WHERE t.dppa_id > 0) LOOP
                UPDATE ndi_pay_person_acc
                SET
                  dppa_dpp = xx.dppa_dpp,
                  dppa_nb = xx.dppa_nb,
                  dppa_is_main = xx.dppa_is_main,
                  dppa_account = 'UA' || xx.dppa_account,
                  dppa_nbg = xx.dppa_nbg,
                  dppa_is_social = xx.dppa_is_social,
                  --dppa_hs_upd = xx.dppa_hs_upd,
                  dppa_description = xx.dppa_description
                where dppa_id = xx.dppa_id;
              END LOOP;
        */
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM ndi_pay_person_acc t
         WHERE     t.dppa_dpp = p_new_id
               AND t.history_status = 'A'
               AND t.dppa_is_main = '1';

        IF (l_cnt > 1)
        THEN
            raise_application_error (
                -20000,
                'В контрагента може бути лише один основний рахунок!');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM (  SELECT t.dppa_account, COUNT (dppa_id) AS cnt
                    FROM ndi_pay_person_acc t
                   WHERE t.dppa_dpp = p_new_id AND t.history_status = 'A'
                GROUP BY dppa_account) t
         WHERE t.cnt > 1;


        IF (l_cnt > 0)
        THEN
            raise_application_error (
                -20000,
                'В контрагента не може бути двох однакових рахунків!');
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
        tools.check_user_and_raise (2);

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
        p_dppa_description          IN     ndi_pay_person_acc.dppa_description%TYPE,
        p_dppa_nb_filia_num         IN     ndi_pay_person_acc.dppa_nb_filia_num%TYPE)
    IS
        l_ba_id      NUMBER;
        l_dppa_cnt   NUMBER;
    BEGIN
        tools.check_user_and_raise (3);

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
                API$DIC_CONTRAGENT.insert_ndi_pay_person_acc (
                    p_dppa_dpp                  => p_dppa_dpp,
                    p_dppa_nb                   => p_dppa_nb,
                    p_dppa_ab_id                => p_dppa_ab_id,
                    p_dppa_is_main              => p_dppa_is_main,
                    p_dppa_account              => p_dppa_account,
                    p_dppa_last_payment_order   => p_dppa_last_payment_order,
                    p_dppa_nbg                  => p_dppa_nbg,
                    p_dppa_is_social            => p_dppa_is_social,
                    p_dppa_description          => p_dppa_description,
                    p_dppa_nb_filia_num         => p_dppa_nb_filia_num);
        ELSE
            SELECT t.dppa_ab_id
              INTO l_ba_id
              FROM ndi_pay_person_acc t
             WHERE t.dppa_id = p_DPPA_ID;


            API$DIC_CONTRAGENT.update_ndi_pay_person_acc (
                p_dppa_id                   => p_dppa_id,
                p_dppa_dpp                  => p_dppa_dpp,
                p_dppa_nb                   => p_dppa_nb,
                p_dppa_ab_id                => p_dppa_ab_id,
                p_dppa_is_main              => p_dppa_is_main,
                p_dppa_account              => p_dppa_account,
                p_dppa_last_payment_order   => p_dppa_last_payment_order,
                p_dppa_nbg                  => p_dppa_nbg,
                p_dppa_is_social            => p_dppa_is_social,
                p_dppa_description          => p_dppa_description,
                p_dppa_nb_filia_num         => p_dppa_nb_filia_num);
        END IF;
    END;

    -- unused
    PROCEDURE DELETE_PAY_PERSON_ACC (
        p_dppa_id   IN ndi_pay_person_acc.dppa_Id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (3);
        API$DIC_CONTRAGENT.set_ndi_pay_person_acc_hist_st (
            p_dppa_id          => p_dppa_id,
            p_History_Status   => 'H');
    END;


    ---------------------------------------------------------
    --------------- Банківські рахунки власні ---------------

    PROCEDURE GET_OWN_PAY_PERSON_CARD (RES_CUR   OUT SYS_REFCURSOR,
                                       ACC_CUR   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
            SELECT t.dpp_id,
                   t.dpp_tax_code,
                   t.dpp_name,
                   t.dpp_org,
                   t.history_status,
                   t.dpp_sname,
                   t.dpp_address,
                   t.dpp_tp,
                   t.dpp_is_ur
              FROM v_ndi_pay_person t
             WHERE t.dpp_org = tools.GetCurrOrg AND t.dpp_tp = 'OSZN'
            UNION
            SELECT NULL           AS dpp_id,
                   NULL           AS dpp_tax_code,
                   z.org_name     AS dpp_name,
                   z.org_id       AS dpp_org,
                   'A'            AS history_status,
                   z.org_name     AS dpp_sname,
                   NULL           AS dpp_address,
                   'OSZN'         AS dpp_tp,
                   'T'            AS dpp_is_ur
              FROM v_opfu z
             WHERE     z.org_id = tools.GetCurrOrg
                   AND NOT EXISTS
                           (SELECT *
                              FROM v_ndi_pay_person t
                             WHERE     t.dpp_org = tools.GetCurrOrg
                                   AND t.dpp_tp = 'OSZN');

        OPEN ACC_CUR FOR
            SELECT t.dppa_id,
                   t.dppa_dpp,
                   t.dppa_nb,
                   t.dppa_is_main,
                   t.dppa_ab_id,
                   t.history_status,
                   CASE
                       WHEN SUBSTR (t.dppa_account, 1, 2) = 'UA'
                       THEN
                           SUBSTR (t.dppa_account, 3)
                       ELSE
                           t.dppa_account
                   END             AS dppa_account,
                   t.dppa_nbg,
                   t.dppa_is_social,
                   t.dppa_last_payment_order,
                   t.dppa_hs_upd,
                   t.dppa_hs_del,
                   t.dppa_description,
                   bp.nbg_sname    AS dppa_nbg_name,
                   b.nb_sname      AS dppa_nb_name
              FROM ndi_pay_person_acc  t
                   LEFT JOIN ndi_budget_program bp ON bp.nbg_id = t.dppa_nbg
                   LEFT JOIN ndi_bank b ON b.nb_id = t.dppa_nb
             WHERE     t.dppa_dpp =
                       (SELECT MAX (z.dpp_id)
                          FROM v_ndi_pay_person z
                         WHERE     z.dpp_org = tools.GetCurrOrg
                               AND z.dpp_tp = 'OSZN')
                   AND t.history_status = 'A';
    END;
END DNET$DIC_CONTRAGENT;
/