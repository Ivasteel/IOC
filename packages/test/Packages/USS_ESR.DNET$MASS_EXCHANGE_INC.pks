/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$MASS_EXCHANGE_INC
IS
    -- Author  : BOGDAN
    -- Created : 11.11.2024 12:02:38
    -- Purpose : Отримання доходів з ДПС та ПФУ (Основний)

    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_Mirr_Id       IN NUMBER)
        RETURN VARCHAR2;

    -- Картка пакету
    PROCEDURE Get_Packet_Card (p_Me_Id           IN     NUMBER,
                               p_Mirr_Numident   IN     VARCHAR2,
                               p_Mirr_Ln         IN     VARCHAR2,
                               p_Mirr_Fn         IN     VARCHAR2,
                               p_Mirr_Mn         IN     VARCHAR2,
                               P_Sc_Unique       IN     VARCHAR2,
                               Res_Cur              OUT SYS_REFCURSOR);

    -- Форма "Отримання доходів з ДПС та ПФУ"
    PROCEDURE Get_Row_Card (p_Mirr_Id   IN     NUMBER,
                            Info_Cur       OUT SYS_REFCURSOR,
                            Insp_Cur       OUT SYS_REFCURSOR,
                            Row_Cur        OUT SYS_REFCURSOR);
END Dnet$mass_Exchange_Inc;
/


GRANT EXECUTE ON USS_ESR.DNET$MASS_EXCHANGE_INC TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$MASS_EXCHANGE_INC TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$MASS_EXCHANGE_INC
IS
    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_Mirr_Id       IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (4000);
    BEGIN
        EXECUTE IMMEDIATE   'SELECT '
                         || CASE
                                /* WHEN p_Col_Name = 'MIRR_SC' THEN
                                  '(SELECT max(z.sc_unique) FROM uss_person.v_socialcard z where z.sc_id = MIRR_SC)'*/
                                WHEN     p_Col_Data_Tp = 'NUMBER'
                                     AND p_Col_Scale IS NOT NULL
                                     AND p_Col_Scale > 0
                                THEN
                                       'to_char('
                                    || p_Col_Name
                                    || ', ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''')'
                                WHEN p_Col_Data_Tp = 'DATE'
                                THEN
                                       'to_char('
                                    || p_Col_Name
                                    || ', ''DD.MM.YYYY'')'
                                ELSE
                                    p_Col_Name
                            END
                         || '
                         FROM me_income_request_rows d
                        WHERE d.Mirr_id = :id'
            INTO l_Res
            USING p_Mirr_Id;

        RETURN l_Res;
    END;

    -- Картка пакету
    PROCEDURE Get_Packet_Card (p_Me_Id           IN     NUMBER,
                               p_Mirr_Numident   IN     VARCHAR2,
                               p_Mirr_Ln         IN     VARCHAR2,
                               p_Mirr_Fn         IN     VARCHAR2,
                               p_Mirr_Mn         IN     VARCHAR2,
                               P_Sc_Unique       IN     VARCHAR2,
                               Res_Cur              OUT SYS_REFCURSOR)
    IS
        l_Org_To   NUMBER := Tools.Getcurrorgto;
        l_Org      NUMBER := Tools.Getcurrorg;
    BEGIN
        OPEN Res_Cur FOR
            SELECT /*+ FIRST_ROWS(502) */
                   t.*, sc.sc_unique
              --Uss_Person.Api$sc_Tools.Get_Vpo_Num(t.Mirr_sc) AS Vpo_Num
              FROM v_me_income_request_rows  t
                   LEFT JOIN uss_person.v_socialcard sc
                       ON (sc.sc_id = t.mirr_sc)
             WHERE     Mirr_Me = p_Me_Id
                   AND (   p_Mirr_Numident IS NULL
                        OR t.mirr_numident LIKE p_Mirr_Numident || '%')
                   AND (   p_Mirr_Ln IS NULL
                        OR UPPER (t.Mirr_Ln) LIKE UPPER (p_Mirr_Ln) || '%')
                   AND (   p_Mirr_Fn IS NULL
                        OR UPPER (t.Mirr_Fn) LIKE UPPER (p_Mirr_Fn) || '%')
                   AND (   p_Mirr_Mn IS NULL
                        OR UPPER (t.mirr_mn) LIKE UPPER (p_Mirr_Mn) || '%')
                   AND (   P_Sc_Unique IS NULL
                        OR UPPER (sc.sc_unique) LIKE
                               UPPER (P_Sc_Unique) || '%')
             FETCH FIRST 502 ROWS ONLY;
    END;

    -- Форма "Отримання доходів з ДПС та ПФУ"
    PROCEDURE Get_Row_Card (p_Mirr_Id   IN     NUMBER,
                            Info_Cur       OUT SYS_REFCURSOR,
                            Insp_Cur       OUT SYS_REFCURSOR,
                            Row_Cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Info_Cur FOR
            SELECT MAX (CASE WHEN t.mirs_src_tp = 'PFU' THEN st.DIC_NAME END)
                       AS pfu_st_name,
                   MAX (CASE WHEN t.mirs_src_tp = 'DPS' THEN st.DIC_NAME END)
                       AS dps_st_name,
                   MAX (
                       CASE
                           WHEN t.mirs_src_tp = 'PFU' AND t.mirs_st = 'K'
                           THEN
                               'Дані є'
                           WHEN t.mirs_src_tp = 'PFU' AND t.mirs_st = 'U'
                           THEN
                               uss_ndi.rdm$msg_template.Getmessagetext (
                                   t.mirs_answer_text)
                       END)
                       AS pfu_answer,
                   MAX (
                       CASE
                           WHEN t.mirs_src_tp = 'DPS' AND t.mirs_st = 'K'
                           THEN
                               'Дані є'
                           WHEN t.mirs_src_tp = 'DPS' AND t.mirs_st = 'U'
                           THEN
                               uss_ndi.rdm$msg_template.Getmessagetext (
                                   t.mirs_answer_text)
                       END)
                       AS dps_answer
              FROM me_income_request_src  t
                   LEFT JOIN uss_ndi.V_DDN_MEMR_ST st
                       ON (st.DIC_VALUE = t.mirs_st)
             WHERE t.mirs_mirr = p_Mirr_Id;

        OPEN Insp_Cur FOR
              SELECT t.Comments                       AS NAME,
                     Get_Dynamic_Value (t.Column_Name,
                                        Ct.Data_Type,
                                        Ct.Data_Scale,
                                        p_Mirr_Id)    AS VALUE
                FROM All_Col_Comments t
                     JOIN All_Tab_Columns Ct
                         ON     Ct.Table_Name = t.Table_Name
                            AND Ct.Column_Name = t.Column_Name
               WHERE     t.Table_Name = UPPER ('me_income_request_rows')
                     AND NOT EXISTS
                             (SELECT *
                                FROM All_Cons_Columns z
                               WHERE     z.Table_Name = t.Table_Name
                                     AND z.Column_Name = t.Column_Name)
            ORDER BY Ct.Column_Id;

        OPEN Row_Cur FOR
            SELECT t.*,
                   uss_person.api$sc_tools.GET_PIB (t.misr_sc)    AS Misr_Sc_Pib
              FROM v_me_income_result_rows t
             WHERE t.Misr_Mirr = p_Mirr_Id;
    END;
BEGIN
    NULL;
END Dnet$mass_Exchange_Inc;
/