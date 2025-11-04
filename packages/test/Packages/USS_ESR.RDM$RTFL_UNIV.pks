/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.RDM$RTFL_UNIV
IS
    -- Author  : SHOSTAK
    -- Created : 17.05.2023 2:03:09 PM
    -- Purpose : Адаптер для побудови звітів, який використовує
    --           побудову через сервіс або через БД в залежності від вказаного способу в параметрі.
    --           Основна мета - запобігання дублювання реалізації друкованих форм, коли використовуються
    --           обидва варіанти побудови

    c_Ss_Code      CONSTANT VARCHAR2 (20) := 'USS_ESR';

    c_Bld_Tp_Svc   CONSTANT VARCHAR2 (10) := 'SVC';
    c_Bld_Tp_Db    CONSTANT VARCHAR2 (10) := 'DB';

    PROCEDURE InitReport (p_Code IN VARCHAR2, p_Bld_Tp IN VARCHAR2);

    PROCEDURE AddScript (p_Script_Name VARCHAR2, p_Script_Text VARCHAR2);

    PROCEDURE AddParam (p_Param_Name VARCHAR2, p_Param_Value VARCHAR2);

    PROCEDURE AddDataset (p_Dataset VARCHAR2, p_Sql VARCHAR2);

    PROCEDURE AddRelation (Pmaster        VARCHAR2,
                           Pmasterfield   VARCHAR2,
                           Pdetail        VARCHAR2,
                           Pdetailfield   VARCHAR2);

    PROCEDURE AddSummary (Pdataset   VARCHAR2,
                          Pfield     VARCHAR2,
                          Ptype      VARCHAR2,
                          Pformat    VARCHAR2);

    PROCEDURE SetFilename (p_File_Name VARCHAR2);

    PROCEDURE SaveMessage (p_Jm_Tp VARCHAR2, p_Jm_Message VARCHAR2);

    FUNCTION Putreporttoworkingqueue
        RETURN NUMBER;

    -- info:   отримання результату підготовки звіту
    -- params:
    -- note:
    PROCEDURE Get_Report_Result (p_Jbr_Id OUT NUMBER, p_Rpt_Blob OUT BLOB);

    FUNCTION Get_g_Bld_Tp
        RETURN VARCHAR2;
END Rdm$rtfl_Univ;
/


/* Formatted on 8/12/2025 5:50:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.RDM$RTFL_UNIV
IS
    g_Bld_Tp                      VARCHAR2 (10);
    g_Jbr_Id                      NUMBER;

    c_Incorrect_Bld_Tp   CONSTANT VARCHAR2 (200)
        := 'Вказано некоректний тип побудови звіту' ;

    ----------------------------------------------------------------
    --    Ініціалізація побудови звіту через сервіс
    ----------------------------------------------------------------
    FUNCTION Init_Report_Svc (p_Code IN VARCHAR2)
        RETURN DECIMAL
    IS
        l_Rt_Id          NUMBER;
        l_Templ          BLOB;
        l_Jbr_Rpt_Code   VARCHAR2 (100);
        l_Jbr_Ss_Code    VARCHAR2 (100);
        l_Jbr_User       VARCHAR2 (100);
    BEGIN
        g_Bld_Tp := c_Bld_Tp_Svc;
        l_Jbr_User := Uss_Esr_Context.Getcontext (Uss_Esr_Context.Glogin);

        SELECT Rt_Id,
               Rt_Text,
               Rt_Code,
               Rt_Ss_Code
          INTO l_Rt_Id,
               l_Templ,
               l_Jbr_Rpt_Code,
               l_Jbr_Ss_Code
          FROM v_Rpt_Templates
         WHERE Rt_Code = p_Code;

        RETURN Ikis_Sysweb.Reportfl_Engine_Ex.Initreport (
                   p_Jbr_App_Ident      => c_Ss_Code,
                   p_Jbr_Rpt_Code       => l_Jbr_Rpt_Code,
                   p_Jbr_Rpt_Template   => l_Templ,
                   p_Jbr_Ss_Code        => l_Jbr_Ss_Code,
                   p_Jbr_User           => l_Jbr_User,
                   p_Tmpl_Id            => l_Rt_Id);
    END;

    ----------------------------------------------------------------
    --    Ініціалізація побудови звіту через БД
    ----------------------------------------------------------------
    PROCEDURE Init_Report_Db (p_Code IN VARCHAR2)
    IS
    BEGIN
        g_Bld_Tp := c_Bld_Tp_Db;
        Reportfl_Engine.Initreport (c_Ss_Code, p_Code);
    END;

    ----------------------------------------------------------------
    --    Ініціалізація побудови звіту
    ----------------------------------------------------------------
    PROCEDURE Initreport (p_Code IN VARCHAR2, p_Bld_Tp IN VARCHAR2)
    IS
    BEGIN
        IF p_Bld_Tp = c_Bld_Tp_Svc
        THEN
            g_Jbr_Id := Init_Report_Svc (p_Code => p_Code);
        ELSIF p_Bld_Tp = c_Bld_Tp_Db
        THEN
            Init_Report_Db (p_Code => p_Code);
        ELSE
            Raise_Application_Error (-20000, c_Incorrect_Bld_Tp);
        END IF;
    END;

    ----------------------------------------------------------------
    --Додавання скрипта підготовки даних (виконуватимуться в
    --порядку вставки в одному з'єднанні з БД). Без параметрів.
    --Контекст виконання - користувача, що визвав побудову звіту
    ----------------------------------------------------------------
    PROCEDURE Addscript (p_Script_Name VARCHAR2, p_Script_Text VARCHAR2)
    IS
    BEGIN
        IF g_Bld_Tp = c_Bld_Tp_Svc
        THEN
            Ikis_Sysweb.Reportfl_Engine_Ex.Addscript (
                p_Jbr_Id        => g_Jbr_Id,
                p_Script_Name   => p_Script_Name,
                p_Script_Text   => p_Script_Text);
        END IF;
    END;

    ----------------------------------------------------------------
    --Додавання константи
    ----------------------------------------------------------------
    PROCEDURE Addparam (p_Param_Name VARCHAR2, p_Param_Value VARCHAR2)
    IS
    BEGIN
        IF g_Bld_Tp = c_Bld_Tp_Svc
        THEN
            Ikis_Sysweb.Reportfl_Engine_Ex.Addparam (
                p_Jbr_Id        => g_Jbr_Id,
                p_Param_Name    => p_Param_Name,
                p_Param_Value   => p_Param_Value);
        ELSIF g_Bld_Tp = c_Bld_Tp_Db
        THEN
            Reportfl_Engine.Addparam (p_Param_Name    => p_Param_Name,
                                      p_Param_Value   => p_Param_Value);
        ELSE
            Raise_Application_Error (-20000, c_Incorrect_Bld_Tp);
        END IF;
    END;

    ----------------------------------------------------------------
    --Додавання набору даних у вигляді запиту
    ----------------------------------------------------------------
    PROCEDURE Adddataset (p_Dataset VARCHAR2, p_Sql VARCHAR2)
    IS
    BEGIN
        IF g_Bld_Tp = c_Bld_Tp_Svc
        THEN
            Ikis_Sysweb.Reportfl_Engine_Ex.Adddataset (
                p_Jbr_Id    => g_Jbr_Id,
                p_Dataset   => p_Dataset,
                p_Sql       => p_Sql);
        ELSIF g_Bld_Tp = c_Bld_Tp_Db
        THEN
            Reportfl_Engine.Adddataset (p_Dataset => p_Dataset, p_Sql => p_Sql);
        ELSE
            Raise_Application_Error (-20000, c_Incorrect_Bld_Tp);
        END IF;
    END;

    ----------------------------------------------------------------
    --Додавання пов'язаних наборів даних
    ----------------------------------------------------------------
    PROCEDURE Addrelation (Pmaster        VARCHAR2,
                           Pmasterfield   VARCHAR2,
                           Pdetail        VARCHAR2,
                           Pdetailfield   VARCHAR2)
    IS
    BEGIN
        IF g_Bld_Tp = c_Bld_Tp_Svc
        THEN
            Ikis_Sysweb.Reportfl_Engine_Ex.Addrelation (
                p_Jbr_Id       => g_Jbr_Id,
                Pmaster        => Pmaster,
                Pmasterfield   => Pmasterfield,
                Pdetail        => Pdetail,
                Pdetailfield   => Pdetailfield);
        ELSIF g_Bld_Tp = c_Bld_Tp_Db
        THEN
            Reportfl_Engine.Addrelation (Pmaster        => Pmaster,
                                         Pmasterfield   => Pmasterfield,
                                         Pdetail        => Pdetail,
                                         Pdetailfield   => Pdetailfield);
        ELSE
            Raise_Application_Error (-20000, c_Incorrect_Bld_Tp);
        END IF;
    END;

    ----------------------------------------------------------------
    --Додавання саммарі
    ----------------------------------------------------------------
    PROCEDURE Addsummary (Pdataset   VARCHAR2,
                          Pfield     VARCHAR2,
                          Ptype      VARCHAR2,
                          Pformat    VARCHAR2)
    IS
    BEGIN
        IF g_Bld_Tp = c_Bld_Tp_Svc
        THEN
            Ikis_Sysweb.Reportfl_Engine_Ex.Addsummary (p_Jbr_Id   => g_Jbr_Id,
                                                       Pdataset   => Pdataset,
                                                       Pfield     => Pfield,
                                                       Ptype      => Ptype,
                                                       Pformat    => Pformat);
        ELSIF g_Bld_Tp = c_Bld_Tp_Db
        THEN
            Reportfl_Engine.Addsummary (Pdataset   => Pdataset,
                                        Pfield     => Pfield,
                                        Ptype      => Ptype,
                                        Pformat    => Pformat);
        ELSE
            Raise_Application_Error (-20000, c_Incorrect_Bld_Tp);
        END IF;
    END;

    ----------------------------------------------------------------
    --Встановлення кастомного імені файлу
    ----------------------------------------------------------------
    PROCEDURE Setfilename (p_File_Name VARCHAR2)
    IS
    BEGIN
        IF g_Bld_Tp = c_Bld_Tp_Svc
        THEN
            Ikis_Sysweb.Reportfl_Engine_Ex.Setfilename (g_Jbr_Id,
                                                        p_File_Name);
        END IF;
    END;

    ----------------------------------------------------------------
    --Збереження повідомлення
    ----------------------------------------------------------------
    PROCEDURE Savemessage (p_Jm_Tp VARCHAR2, p_Jm_Message VARCHAR2)
    IS
    BEGIN
        IF g_Bld_Tp = c_Bld_Tp_Svc
        THEN
            Ikis_Sysweb.Reportfl_Engine_Ex.Savemessage (
                p_Jbr_Id       => g_Jbr_Id,
                p_Jp_Tp        => p_Jm_Tp,
                p_Jp_Message   => p_Jm_Message);
        END IF;
    END;

    ----------------------------------------------------------------
    --Зміна стану звіту на "готовий для обробки в сервері додатків"
    --- тільки для ініціалізованих (звіт переходить в стан READY)
    ----------------------------------------------------------------
    FUNCTION Putreporttoworkingqueue
        RETURN NUMBER
    IS
    BEGIN
        IF g_Bld_Tp = c_Bld_Tp_Svc
        THEN
            Ikis_Sysweb.Reportfl_Engine_Ex.Putreporttoworkingqueue (
                p_Jbr_Id   => g_Jbr_Id);
        END IF;
    END;

    -- info:   отримання результату підготовки звіту
    -- params:
    -- note:
    PROCEDURE Get_Report_Result (p_Jbr_Id OUT NUMBER, p_Rpt_Blob OUT BLOB)
    IS
    BEGIN
        IF g_Bld_Tp = c_Bld_Tp_Svc
        THEN
            Ikis_Sysweb.Reportfl_Engine_Ex.Putreporttoworkingqueue (
                p_Jbr_Id   => g_Jbr_Id);
            p_Jbr_Id := g_Jbr_Id;
        ELSIF g_Bld_Tp = c_Bld_Tp_Db
        THEN
            p_Rpt_Blob := reportfl_engine.publishreportblob;
        ELSE
            Raise_Application_Error (-20000, c_Incorrect_Bld_Tp);
        END IF;
    END;

    FUNCTION Get_g_Bld_Tp
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN g_Bld_Tp;
    END;
END Rdm$rtfl_Univ;
/