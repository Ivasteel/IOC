/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$VERIFICATION
IS
    -- Author  : BOGDAN
    -- Created : 30.07.2021 10:51:55
    -- Purpose :


    ----------------------------------------------------
    --  СТАТУСИ ВЕРИФІКАЦІЙ
    ----------------------------------------------------
    c_Vf_St_Error          CONSTANT VARCHAR2 (10) := 'E';
    c_Vf_St_Ok             CONSTANT VARCHAR2 (10) := 'X';
    c_Vf_St_Not_Verified   CONSTANT VARCHAR2 (10) := 'N';

    ----------------------------------------------------
    --  ТИПИ ПОВІДОМЛЕНЬ В ПРОТОКОЛІ ВЕРИФІКАЦІЇ
    ----------------------------------------------------
    c_Vfl_Tp_Info          CONSTANT VARCHAR2 (10) := 'I';
    c_Vfl_Tp_Error         CONSTANT VARCHAR2 (10) := 'E';
    c_Vfl_Tp_Terror        CONSTANT VARCHAR2 (10) := 'T';   --Технічна помилка
    c_Vfl_Tp_Warning       CONSTANT VARCHAR2 (10) := 'W';
    c_Vfl_Tp_Done          CONSTANT VARCHAR2 (10) := 'D';

    ----------------------------------------------------
    --  ТИПИ ВЕРИФІКАЦІЇ
    ----------------------------------------------------
    c_Nvt_Main_Appeal      CONSTANT NUMBER := 2;
    c_Nvt_Main_Person      CONSTANT NUMBER := 3;
    c_Nvt_Person           CONSTANT NUMBER := 4; --Верифікація реквізитів учасника
    c_Nvt_Person_Incomes   CONSTANT NUMBER := 7; --Верифікація доходів учасника зверення
    c_Nvt_Appeal_Docs      CONSTANT NUMBER := 6; --Верифікація наявності документів звернення

    ----------------------------------------------------
    --  ТИПИ ДОКУМЕНТІВ
    ----------------------------------------------------
    c_Ndt_Inn                       NUMBER := 5;

    FUNCTION Get_Vf_St_Name (p_Vf_Id IN Verification.Vf_Id%TYPE)
        RETURN VARCHAR2;

    PROCEDURE Get_Vf_Protocol (p_Vf_Id          Verification.Vf_Id%TYPE,
                               p_Main_Cur   OUT SYS_REFCURSOR,
                               p_Vf_Cur     OUT SYS_REFCURSOR,
                               p_Log_Cur    OUT SYS_REFCURSOR);
END DNET$VERIFICATION;
/


GRANT EXECUTE ON USS_ESR.DNET$VERIFICATION TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$VERIFICATION TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$VERIFICATION
IS
    FUNCTION Get_Vf_St_Name (p_Vf_Id IN Verification.Vf_Id%TYPE)
        RETURN VARCHAR2
    IS
        l_Vf_St_Name   Uss_Ndi.v_Ddn_Vf_St.Dic_Name%TYPE;
    BEGIN
        SELECT MAX (s.Dic_Name)
          INTO l_Vf_St_Name
          FROM Verification  v
               JOIN Uss_Ndi.v_Ddn_Vf_St s ON v.Vf_St = s.Dic_Value
         WHERE v.Vf_Id = p_Vf_Id;

        RETURN l_Vf_St_Name;
    END;

    PROCEDURE Get_Vf_Protocol (p_Vf_Id          Verification.Vf_Id%TYPE,
                               p_Main_Cur   OUT SYS_REFCURSOR,
                               p_Vf_Cur     OUT SYS_REFCURSOR,
                               p_Log_Cur    OUT SYS_REFCURSOR)
    IS
    BEGIN
        --Основна інформация про об’єкт верифікації
        OPEN p_Main_Cur FOR
            SELECT    t.Dic_Name
                   || CASE
                          WHEN v.Vf_Obj_Tp = 'A'
                          THEN
                              (SELECT ' №' || a.Ap_Num
                                 FROM Appeal a
                                WHERE a.Ap_Id = v.Vf_Obj_Id)
                          WHEN v.Vf_Obj_Tp = 'P'
                          THEN
                              (SELECT    ' '
                                      || uss_person.api$sc_tools.GET_PIB (
                                             p.app_sc)
                                 FROM Ap_Person p
                                WHERE p.App_Id = v.Vf_Obj_Id)
                          WHEN v.Vf_Obj_Tp = 'D'
                          THEN
                              (SELECT    ' "'
                                      || t.Ndt_Name
                                      || '"'
                                 FROM Ap_Document  d
                                      JOIN
                                      Uss_Ndi.v_Ndi_Document_Type
                                      t
                                          ON d.Apd_Ndt =
                                             t.Ndt_Id
                                WHERE d.Apd_Id = v.Vf_Obj_Id)
                      END    AS Vf_Object_Descr,
                   CASE
                       WHEN v.Vf_Own_St IN
                                (c_Vf_St_Error,
                                 c_Vf_St_Not_Verified)
                       THEN
                           'T'
                       ELSE
                           'F'
                   END       AS Confirm_Allowed
              FROM Verification  v
                   JOIN Uss_Ndi.v_Ddn_Vf_Obj_Tp t
                       ON v.Vf_Obj_Tp = t.Dic_Value
             WHERE v.Vf_Id = p_Vf_Id;

        --Дерево верифікацій
        OPEN p_Vf_Cur FOR
                       SELECT v.Vf_Id,
                                 CASE
                                     WHEN LEVEL > 1
                                     THEN
                                         LPAD (Tt.Nvt_Name,
                                               LENGTH (Tt.Nvt_Name) + (LEVEL * 3),
                                               CHR (160))
                                     ELSE
                                         Tt.Nvt_Name
                                 END
                              || CASE
                                     WHEN v.Vf_Nvt = c_Nvt_Main_Person
                                     THEN
                                            ' '
                                         || uss_person.api$sc_tools.GET_PIB (p.app_sc,
                                                                             1)
                                     ELSE
                                         ''
                                 END           AS Vf_Nvt_Name,
                              t.Dic_Name       AS Vf_Tp_Name,
                              v.Vf_Start_Dt    AS Vf_Star_Tdt,
                              v.Vf_Stop_Dt,
                              v.Vf_Expected_Stop_Dt,
                              St.Dic_Name      AS Vf_St_Name,
                              NULL                                 /*s.Hs_Dt*/
                                               AS Vf_Confirm_Dt,
                              NULL                             /* u.Wu_Login*/
                                               AS Vf_Confirm_Wu,
                              Ost.Dic_Name     AS Vf_Own_St_Name,
                              v.Vf_Tp
                         FROM Verification v
                              JOIN Uss_Ndi.v_Ddn_Vf_Tp t ON v.Vf_Tp = t.Dic_Value
                              JOIN Uss_Ndi.v_Ndi_Verification_Type Tt
                                  ON v.Vf_Nvt = Tt.Nvt_Id
                              JOIN Uss_Ndi.v_Ddn_Vf_St St ON v.Vf_St = St.Dic_Value
                              LEFT JOIN Uss_Ndi.v_Ddn_Vf_St Ost
                                  ON v.Vf_Own_St = Ost.Dic_Value
                              /*LEFT JOIN Histsession s
                                ON v.Vf_Hs_Rewrite = s.Hs_Id
                              LEFT JOIN Ikis_Sysweb.V$w_Users_4gic u
                                ON s.Hs_Wu = u.Wu_Id*/
                              LEFT JOIN Ap_Person p
                                  ON v.Vf_Obj_Id = p.App_Id AND v.Vf_Obj_Tp = 'P'
                   START WITH v.Vf_Id = p_Vf_Id
                   CONNECT BY PRIOR v.Vf_Id = v.Vf_Vf_Main
            ORDER SIBLINGS BY v.Vf_Start_Dt;

        --Протоколи верифікацій
        OPEN p_Log_Cur FOR
              SELECT l.Vfl_Vf,
                     l.Vfl_Dt,
                     Uss_Ndi.Rdm$msg_Template.Getmessagetext (l.Vfl_Message)
                         AS Vfl_Message,
                     t.Dic_Name
                         AS Vfl_Tp_Name
                FROM Vf_Log l
                     JOIN Uss_Ndi.v_Ddn_Vfl_Tp t ON l.Vfl_Tp = t.Dic_Value
               WHERE     l.Vfl_Vf IN (    SELECT t.Vf_Id
                                            FROM Verification t
                                      START WITH t.Vf_Id = p_Vf_Id
                                      CONNECT BY PRIOR t.Vf_Id = t.Vf_Vf_Main)
                     --Виключаємо технічні помилки
                     AND l.Vfl_Tp <> 'T'
            ORDER BY l.Vfl_Vf, l.Vfl_Id;
    END;
BEGIN
    NULL;
END DNET$VERIFICATION;
/