/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SC_VERIFICATION_VPO
IS
    -- Author  : KELATEV
    -- Created : 27.01.2025
    -- Purpose : Верифікація даних, що надходять від ЄІБД ВПО

    PROCEDURE Set_Scdi_Sc (p_Scdi_Id   IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
                           p_Scdi_Sc   IN Sc_Pfu_Data_Ident.Scdi_Sc%TYPE);

    PROCEDURE Scdi_Main_Scv_Callback (p_Scdi_Id   IN NUMBER,
                                      p_Scv_Id    IN NUMBER,
                                      p_Scv_St    IN VARCHAR2);
END Api$sc_Verification_Vpo;
/


/* Formatted on 8/12/2025 5:56:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SC_VERIFICATION_VPO
IS
    PROCEDURE Set_Scdi_Sc (p_Scdi_Id   IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
                           p_Scdi_Sc   IN Sc_Pfu_Data_Ident.Scdi_Sc%TYPE)
    IS
    BEGIN
        UPDATE Sc_Pfu_Data_Ident
           SET Scdi_Sc = p_Scdi_Sc
         WHERE Scdi_Id = p_Scdi_Id;

        IF SQL%ROWCOUNT > 0
        THEN
            UPDATE Sc_Pfu_Document t
               SET Scpo_Sc = p_Scdi_Sc
             WHERE Scpo_Scdi = p_Scdi_Id;

            UPDATE Sc_Pfu_Address t
               SET Scpa_Sc = p_Scdi_Sc
             WHERE Scpa_Scdi = p_Scdi_Id;
        END IF;
    END;

    -------------------------------------------------------------------------------
    -- Фінішна процедура верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Scdi_Main_Scv_Callback (p_Scdi_Id   IN NUMBER,
                                      p_Scv_Id    IN NUMBER,
                                      p_Scv_St    IN VARCHAR2)
    IS
        c_Ndt_Vpo      CONSTANT NUMBER := 10052;
        l_Scd_Id                NUMBER;
        l_Dh_Id                 NUMBER;
        c_Nda_Vpo_St   CONSTANT NUMBER := 1855;
        l_Vpo_St                VARCHAR2 (10);

        PROCEDURE LOG (p_Action IN VARCHAR2, p_Clob IN CLOB DEFAULT NULL)
        IS
        BEGIN
            Tools.LOG ('Api$sc_Verification_Vpo.Scdi_Main_Scv_Callback',
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
            SELECT MAX (Scd_Id), MAX (d.Scd_Dh)
              INTO l_Scd_Id, l_Dh_Id
              FROM Uss_Person.Sc_Document d, Uss_Person.Sc_Pfu_Document Pd
             WHERE     Pd.Scpo_Scdi = p_Scdi_Id
                   AND Pd.Scpo_Ndt = c_Ndt_Vpo
                   AND Pd.Scpo_Scd = d.Scd_Id;

            --Отримуємо статус довідки ВПО
            l_Vpo_St :=
                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                    p_Nda_Id   => c_Nda_Vpo_St,
                    p_Dh_Id    => l_Dh_Id);

            IF l_Vpo_St = 'H'
            THEN
                --Змінюємо статус документа
                Api$socialcard.Set_Doc_St (
                    p_Scd_Id   => l_Scd_Id,
                    p_Scd_St   => Api$socialcard.c_Scd_St_Closed);
            END IF;

            LOG ('Finish by existing process');
            RETURN;
        ELSE
            --Неуспішна верифікація
            LOG ('Unlink SC. p_Scdi_Id=' || p_Scdi_Id);
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
END Api$sc_Verification_Vpo;
/