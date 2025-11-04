/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SC_VERIFICATION_DOC
IS
    -- Author  : KELATEV
    -- Created : 07.02.2025 17:11:28
    -- Purpose : Верифікація довільного документу СРКО

    c_Nrt_Id   CONSTANT NUMBER := 140;

    PROCEDURE Create_Verification (p_Scd_Id IN NUMBER);

    PROCEDURE Scdi_Main_Scv_Callback (p_Scdi_Id   IN NUMBER,
                                      p_Scv_Id    IN NUMBER,
                                      p_Scv_St    IN VARCHAR2);
END Api$sc_Verification_Doc;
/


/* Formatted on 8/12/2025 5:56:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SC_VERIFICATION_DOC
IS
    PROCEDURE Create_Verification (p_Scd_Id IN NUMBER)
    IS
        l_Sc_Id       NUMBER;
        l_Scd_Ndt     NUMBER;

        l_Ln          v_Sc_Identity.Sci_Ln%TYPE;
        l_Fn          v_Sc_Identity.Sci_Fn%TYPE;
        l_Mn          v_Sc_Identity.Sci_Mn%TYPE;
        l_Birthdate   DATE;

        l_Scdi_Id     NUMBER;
        l_Scpo_Id     NUMBER;
    BEGIN
        SELECT Scd_Sc, Scd_Ndt
          INTO l_Sc_Id, l_Scd_Ndt
          FROM Sc_Document d
         WHERE d.Scd_Id = p_Scd_Id;

        IF l_Scd_Ndt NOT IN (5)
        THEN
            Raise_Application_Error (
                -20000,
                'Тип документу [' || l_Scd_Ndt || '] не підримується');
        END IF;

        SELECT i.Sci_Ln, i.Sci_Fn, i.Sci_Mn
          INTO l_Ln, l_Fn, l_Mn
          FROM v_Socialcard t, v_Sc_Change Ch, v_Sc_Identity i
         WHERE     t.Sc_Id = l_Sc_Id
               AND Ch.Scc_Id = t.Sc_Scc
               AND i.Sci_Id = Ch.Scc_Sci;

        l_Birthdate := Api$sc_Tools.Get_Birthdate (l_Sc_Id);

        CASE
            WHEN l_Scd_Ndt IN (5)
            THEN
                DECLARE
                    l_Doc_Num   Sc_Document.Scd_Number%TYPE;
                BEGIN
                    SELECT Scd_Number
                      INTO l_Doc_Num
                      FROM Sc_Document
                     WHERE Scd_Id = p_Scd_Id;

                    Api$socialcard_Ext.Save_Data_Ident (
                        p_Scdi_Id         => l_Scdi_Id,
                        p_Scdi_Sc         => l_Sc_Id,
                        p_Scdi_Ln         => l_Ln,
                        p_Scdi_Fn         => l_Fn,
                        p_Scdi_Mn         => l_Mn,
                        p_Scdi_Numident   => l_Doc_Num,
                        p_Scdi_Birthday   => l_Birthdate,
                        p_Nrt_Id          => c_Nrt_Id);
                    Api$socialcard_Ext.Save_Document (
                        p_Scpo_Id     => l_Scpo_Id,
                        p_Scpo_Sc     => l_Sc_Id,
                        p_Scpo_Scdi   => l_Scdi_Id,
                        p_Scpo_Ndt    => l_Scd_Ndt,
                        p_Scpo_Scd    => p_Scd_Id);
                END;
            ELSE
                NULL;
        END CASE;
    END;

    -------------------------------------------------------------------------------
    -- Фінішна процедура верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Scdi_Main_Scv_Callback (p_Scdi_Id   IN NUMBER,
                                      p_Scv_Id    IN NUMBER,
                                      p_Scv_St    IN VARCHAR2)
    IS
        l_Scd_Id   NUMBER;

        PROCEDURE LOG (p_Action IN VARCHAR2, p_Clob IN CLOB DEFAULT NULL)
        IS
        BEGIN
            Tools.LOG ('Api$sc_Verification_Doc.Scdi_Main_Scv_Callback',
                       'SCDI',
                       p_Scdi_Id,
                       p_Action,
                       p_Clob);
        END;
    BEGIN
        LOG ('Start. p_Scdi_Id=' || p_Scdi_Id || ', p_Scv_St=' || p_Scv_St);

        --Успішна верифікація
        IF p_Scv_St = 'X'
        THEN
            LOG ('Finish by existing process');
            RETURN;
        ELSE
            SELECT Scpo_Scd
              INTO l_Scd_Id
              FROM Sc_Pfu_Document d
             WHERE d.Scpo_Scdi = p_Scdi_Id;

            --Неуспішна верифікація
            LOG (
                   'Close Doc. p_Scdi_Id='
                || p_Scdi_Id
                || ', Scd_Id='
                || l_Scd_Id);
            --Змінюємо статус документа
            Api$socialcard.Set_Doc_St (
                p_Scd_Id   => l_Scd_Id,
                p_Scd_St   => Api$socialcard.c_Scd_St_Closed);
        END IF;

        LOG ('Finish');
    EXCEPTION
        WHEN OTHERS
        THEN
            LOG (
                'Exception.',
                   SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Stack
                || DBMS_UTILITY.Format_Error_Backtrace);
            Api$sc_Verification.Write_Scv_Log (
                p_Scv_Id         => p_Scv_Id,
                p_Scvl_Hs        => Tools.Gethistsession (),
                p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Terror,
                p_Scvl_Message   =>
                       'Помилка обробки звернення після верифікації: '
                    || SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace,
                p_Scvl_St        => 'VW',
                p_Scvl_St_Old    => NULL);
    END;
END Api$sc_Verification_Doc;
/