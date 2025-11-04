/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SC_VERIFICATION_MOZ
IS
    -- Author  : KELATEV
    -- Created : 25.12.2024 11:52:44
    -- Purpose : Верифікація даних, що надходять від МОЗ

    c_Src_Moz           CONSTANT VARCHAR2 (10) := 'MOZ';
    c_Src_Moz_Id        CONSTANT VARCHAR2 (10) := '60';

    c_Pt_Scdi_Id        CONSTANT NUMBER := 509;

    c_Feedback_Ok       CONSTANT NUMBER := 1;
    c_Feedback_Verify   CONSTANT NUMBER := 201;
    c_Feedback_Valid    CONSTANT NUMBER := 202;
    c_Feedback_Dead     CONSTANT NUMBER := 203;

    PROCEDURE Send_Feedback (p_Scdi_Id   IN NUMBER,
                             p_Result    IN NUMBER,
                             p_Message   IN VARCHAR2);

    PROCEDURE Validate_Decision (p_Scdi_Id IN NUMBER, p_Scv_Id IN NUMBER);

    PROCEDURE Set_Scmd_Wrn (p_Scdi_Id IN NUMBER, p_Scv_Id IN NUMBER);

    PROCEDURE Set_Scdi_Sc (p_Scdi_Id   IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
                           p_Scdi_Sc   IN Sc_Pfu_Data_Ident.Scdi_Sc%TYPE);

    PROCEDURE Scdi_Main_Scv_Callback (p_Scdi_Id   IN NUMBER,
                                      p_Scv_Id    IN NUMBER,
                                      p_Scv_St    IN VARCHAR2);
END Api$sc_Verification_Moz;
/


GRANT EXECUTE ON USS_PERSON.API$SC_VERIFICATION_MOZ TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:56:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SC_VERIFICATION_MOZ
IS
    /*
    info:    Відправка в МОЗ інформацію про верифікацію
    author:  kelatev
    info:    116665
    */
    PROCEDURE Send_Feedback (p_Scdi_Id   IN NUMBER,
                             p_Result    IN NUMBER,
                             p_Message   IN VARCHAR2)
    IS
        l_Ur_Id    NUMBER;
        l_Urt_Id   NUMBER;
        l_Req_Id   VARCHAR2 (100);
    BEGIN
        SELECT r.Ur_Id, r.Ur_Urt, p.Scdi_Ext_Ident
          INTO l_Ur_Id, l_Urt_Id, l_Req_Id
          FROM Uss_Person.Sc_Pfu_Data_Ident p, Ikis_Rbm.v_Uxp_Request r
         WHERE p.Scdi_Id = p_Scdi_Id AND p.Scdi_Rn = r.Ur_Rn;

        IF l_Urt_Id != 129
        THEN
            RETURN;
        END IF;
    /*Ikis_Rbm.Api$request_Moz.Reg_Feedback_Errors_Req(p_Ur_Id   => l_Ur_Id,
                                                     p_Scdi_Id => p_Scdi_Id,
                                                     p_Req_Id  => l_Req_Id,
                                                     p_Result  => p_Result,
                                                     p_Message => p_Message);*/
    END;

    /*
    info:    Верифікація рішень
    author:  kelatev
    info:    116393
    */
    PROCEDURE Validate_Decision (p_Scdi_Id IN NUMBER, p_Scv_Id IN NUMBER)
    IS
        l_Hs             NUMBER := Tools.Gethistsession;
        l_Decision_Num   Uss_Person.Sc_Moz_Assessment.Scma_Decision_Num%TYPE;
        l_Sc_Id          NUMBER;
    BEGIN
        SELECT Scma_Decision_Num
          INTO l_Decision_Num
          FROM Uss_Person.Sc_Moz_Assessment a
         WHERE Scma_Scdi = p_Scdi_Id;

        SELECT MAX (A2.Scma_Sc)
          INTO l_Sc_Id
          FROM Uss_Person.Sc_Moz_Assessment  a,
               Uss_Person.Sc_Moz_Assessment  A2
         WHERE     a.Scma_Scdi = p_Scdi_Id
               AND A2.Scma_St = 'VO'
               AND A2.Scma_Decision_Num = a.Scma_Decision_Num
               AND (   A2.Scma_Decision_Dt = a.Scma_Decision_Dt
                    OR A2.Scma_Decision_Dt IS NULL)
               AND A2.Scma_Sc != a.Scma_Sc;

        IF l_Sc_Id IS NOT NULL
        THEN
            Send_Feedback (
                p_Scdi_Id   => p_Scdi_Id,
                p_Result    => c_Feedback_Valid,
                p_Message   => 'Номер рішення присутній у іншої особи');

            Api$sc_Verification.Set_Not_Verified (
                p_Scv_Id    => p_Scv_Id,
                p_Scvl_Hs   => l_Hs,
                p_Error     =>
                    CHR (38) || '379#' || l_Decision_Num || '#' || l_Sc_Id);
            RETURN;
        END IF;

        Api$sc_Verification.Set_Ok (p_Scv_Id => p_Scv_Id, p_Scvl_Hs => l_Hs);
    END;

    /*
    info:    Пошук відповідностей в довіднику ДЗР
    author:  kelatev
    */
    PROCEDURE Set_Scmd_Wrn (p_Scdi_Id IN NUMBER, p_Scv_Id IN NUMBER)
    IS
        l_Hs   NUMBER := Tools.Gethistsession;
    BEGIN
        FOR Rec IN (SELECT *
                      FROM Sc_Moz_Dzr_Recomm d
                     WHERE d.Scmd_Scdi = p_Scdi_Id)
        LOOP
            IF Rec.Scmd_Iso_Code IS NOT NULL
            THEN
                DECLARE
                    l_Wrn_Id   NUMBER;
                    l_Error    VARCHAR2 (32767);
                BEGIN
                    BEGIN
                          SELECT c.Wrn_Id
                            INTO l_Wrn_Id
                            FROM Uss_Ndi.v_Ndi_Cbi_Wares c
                           WHERE     c.Wrn_Shifr = Rec.Scmd_Iso_Code
                                 AND c.History_Status = 'A'
                                 AND c.Wrn_St = 'A'
                                 AND UTL_MATCH.Edit_Distance_Similarity (
                                         UPPER (TRIM (c.Wrn_Name)),
                                         UPPER (TRIM (Rec.Scmd_Dzr_Name))) >=
                                       100
                                     * (    LENGTH (
                                                TRIM (
                                                       c.Wrn_Name
                                                    || Rec.Scmd_Dzr_Name))
                                          / 2
                                        - 2)
                                     /         -- (-2 = отличие в два символа)
                                       (  LENGTH (
                                              TRIM (
                                                     c.Wrn_Name
                                                  || Rec.Scmd_Dzr_Name))
                                        / 2)
                        ORDER BY UTL_MATCH.Edit_Distance_Similarity (
                                     UPPER (TRIM (Rec.Scmd_Dzr_Name)),
                                     UPPER (TRIM (c.Wrn_Name))) DESC
                           FETCH FIRST ROW ONLY;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            UPDATE Sc_Moz_Dzr_Recomm d
                               SET d.Scmd_St = 'VE'
                             WHERE d.Scmd_Id = Rec.Scmd_Id;

                            l_Error :=
                                   CHR (38)
                                || '364#'
                                || Rec.Scmd_Iso_Code
                                || '#'
                                || Rec.Scmd_Dzr_Name;

                            Api$sc_Verification_Moz.Send_Feedback (
                                p_Scdi_Id   => p_Scdi_Id,
                                p_Result    =>
                                    Api$sc_Verification_Moz.c_Feedback_Valid,
                                p_Message   =>
                                    Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                        l_Error));

                            Api$sc_Verification.Set_Not_Verified (
                                p_Scv_Id    => p_Scv_Id,
                                p_Scvl_Hs   => l_Hs,
                                p_Error     => l_Error);
                            /*Uss_Ndi.Api$dic_Common.Save_Ndi_Cbi_Wares(p_Wrn_Id         => NULL,
                            p_Wrn_Code       => Rec.Scmd_Dzr_Code,
                            p_Wrn_Shifr      => Rec.Scmd_Iso_Code,
                            p_Wrn_Name       => Upper(Rec.Scmd_Dzr_Name),
                            p_Wrn_St         => 'A',
                            p_History_Status => 'A',
                            p_Wrn_Candelete  => 'F',
                            p_New_Id         => l_Wrn_Id);*/
                            RETURN;
                    END;

                    UPDATE Sc_Moz_Dzr_Recomm d
                       SET d.Scmd_St = 'VO', d.Scmd_Wrn = l_Wrn_Id
                     WHERE d.Scmd_Id = Rec.Scmd_Id;
                END;
            END IF;
        END LOOP;

        Api$sc_Verification.Set_Ok (p_Scv_Id => p_Scv_Id, p_Scvl_Hs => l_Hs);
    END;

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

            UPDATE Sc_Moz_Assessment
               SET Scma_Sc = p_Scdi_Sc
             WHERE Scma_Scdi = p_Scdi_Id;

            UPDATE Sc_Moz_Dzr_Recomm
               SET Scmd_Sc = p_Scdi_Sc
             WHERE Scmd_Scdi = p_Scdi_Id;

            UPDATE Sc_Moz_Med_Data_Recomm
               SET Scmm_Sc = p_Scdi_Sc
             WHERE Scmm_Scdi = p_Scdi_Id;

            UPDATE Sc_Moz_Zoz
               SET Scmz_Sc = p_Scdi_Sc
             WHERE Scmz_Scdi = p_Scdi_Id;

            UPDATE Sc_Moz_Loss_Prof_Ability
               SET Scml_Sc = p_Scdi_Sc
             WHERE Scml_Scdi = p_Scdi_Id;
        END IF;
    END;

    /*
    * Збереження рекомендацій ДЗР до основних таблиць
    * #113493
    * З 07.02.2025 попередніми даними важається привязані до особи, а не рішення
    */
    PROCEDURE Save_Dzr_Recomm (p_Scdi_Id IN NUMBER)
    IS
        l_Sc_Id         NUMBER;
        l_Scd_201       NUMBER;

        l_Others_Scdi   OWA_UTIL.Ident_Arr;
        l_Decision_Dt   DATE;
        l_Exists        NUMBER;

        PROCEDURE LOG (p_Action IN VARCHAR2, p_Clob IN CLOB DEFAULT NULL)
        IS
        BEGIN
            Tools.LOG ('Api$sc_Verification_Moz.Save_Dzr_Recomm',
                       'SCDI',
                       p_Scdi_Id,
                       p_Action,
                       p_Clob);
        END;
    BEGIN
        LOG ('Start. p_Scdi_Id=' || p_Scdi_Id);

        --Перевірка чи записи вже існуюсь (виконується повторна верифікація)
        SELECT COUNT (*)
          INTO l_Exists
          FROM Uss_Person.Sc_Dzr_Recomm
         WHERE     Scdr_Src = c_Src_Moz_Id
               AND Scdr_Src_Id = p_Scdi_Id
               AND History_Status = 'A';

        LOG (
            'Scdi_Id=' || p_Scdi_Id || ', exists Sc_Dzr_Recomm=' || l_Exists);

        IF l_Exists > 0
        THEN
            LOG (
                'Exit, because Sc_Dzr_Recomm exists. p_Scdi_Id=' || p_Scdi_Id);
            RETURN;
        END IF;

        SELECT Scdi_Sc
          INTO l_Sc_Id
          FROM Sc_Pfu_Data_Ident
         WHERE Scdi_Id = p_Scdi_Id;

        --Шукаємо всі ДЗР що в роботі, щоб потім виключичти їх із видалення
        DELETE FROM Tmp_Work_Ids
              WHERE 1 = 1;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT d.Scdr_Id
              FROM Uss_Person.Sc_Dzr_Recomm d
             WHERE     d.Scdr_Sc = l_Sc_Id
                   AND d.History_Status = 'A'
                   AND d.Scdr_Src = c_Src_Moz_Id
                   AND (   EXISTS
                               (SELECT 1
                                  FROM Uss_Esr.v_At_Wares w
                                 WHERE     w.History_Status = 'A'
                                       AND w.Atw_Scdr = d.Scdr_Id)
                        OR EXISTS
                               (SELECT 1
                                  FROM Uss_Esr.v_Ap_Person         p,
                                       Uss_Esr.v_Ap_Document       d,
                                       Uss_Esr.v_Ap_Document_Attr  a
                                 WHERE     p.History_Status = 'A'
                                       AND d.Apd_App = p.App_Id
                                       AND d.Apd_Ndt = 10344
                                       AND d.History_Status = 'A'
                                       AND a.Apda_Apd = d.Apd_Id
                                       AND a.History_Status = 'A'
                                       AND a.Apda_Nda = 8735
                                       AND REGEXP_LIKE (
                                               a.Apda_Val_String,
                                                  '(^|,)'
                                               || d.Scdr_Id
                                               || '(,|$)')));

        LOG ('Scdi_Id=' || p_Scdi_Id || ', Work_Scdr=' || SQL%ROWCOUNT);

        --Пошук МСЕК документ - для інформації до переліку ДЗР
        SELECT MAX (d.Scpo_Scd)
          INTO l_Scd_201
          FROM Uss_Person.Sc_Pfu_Document d
         WHERE d.Scpo_Scdi = p_Scdi_Id AND d.Scpo_Ndt = 201;

        --Отримання дати рішення - для інформації до переліку ДЗР
        SELECT Scma_Decision_Dt
          INTO l_Decision_Dt
          FROM Uss_Person.Sc_Moz_Assessment a
         WHERE Scma_Scdi = p_Scdi_Id;

        --Пошук існуючих рішень
        SELECT a.Scma_Scdi
          BULK COLLECT INTO l_Others_Scdi
          FROM Uss_Person.Sc_Moz_Assessment a
         WHERE     a.Scma_St = 'VO'
               AND a.Scma_Sc = l_Sc_Id
               AND a.Scma_Scdi <> p_Scdi_Id;

        --Закриття існуючих рішень/рекомендацій
        IF l_Others_Scdi.COUNT > 0
        THEN
            FORALL i IN 1 .. l_Others_Scdi.COUNT
                UPDATE Uss_Person.Sc_Moz_Assessment
                   SET Scma_St = 'VOH'
                 WHERE Scma_St = 'VO' AND Scma_Scdi = l_Others_Scdi (i);

            FORALL i IN 1 .. l_Others_Scdi.COUNT
                UPDATE Uss_Person.Sc_Dzr_Recomm
                   SET History_Status = 'H'
                 WHERE     History_Status = 'A'
                       AND Scdr_Src = c_Src_Moz_Id
                       AND Scdr_Src_Id = l_Others_Scdi (i)
                       AND Scdr_Id NOT IN (SELECT x_Id FROM Tmp_Work_Ids) /*без урахування тих що в роботі*/
                                                                         ;

            LOG (
                   'Scdi_Id='
                || p_Scdi_Id
                || ', close Sc_Dzr_Recomm='
                || SQL%ROWCOUNT);

            FOR i IN 1 .. l_Others_Scdi.COUNT
            LOOP
                LOG (
                       'Close actual Assessment/Dzr_Recomm. New_Scdi_Id='
                    || p_Scdi_Id
                    || ', Old_Scdi_Id='
                    || l_Others_Scdi (i));
            END LOOP;
        END IF;

        INSERT INTO Uss_Person.Sc_Dzr_Recomm (Scdr_Id,
                                              Scdr_Sc,
                                              Scdr_Wrn,
                                              Scdr_Is_Need,
                                              Scdr_Scd,
                                              Scdr_Src,
                                              Scdr_Src_Id,
                                              History_Status,
                                              Scdr_Src_Dt)
            SELECT 0,
                   d.Scmd_Sc,
                   d.Scmd_Wrn,
                   d.Scmd_Is_Dzr_Needed,
                   l_Scd_201,
                   c_Src_Moz_Id,
                   d.Scmd_Scdi,
                   'A',
                   l_Decision_Dt
              FROM Uss_Person.Sc_Moz_Dzr_Recomm d
             WHERE d.Scmd_Scdi = p_Scdi_Id;

        LOG ('Finish. p_Scdi_Id=' || p_Scdi_Id);
    END;

    -------------------------------------------------------------------------------
    -- Фінішна процедура верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Scdi_Main_Scv_Callback (p_Scdi_Id   IN NUMBER,
                                      p_Scv_Id    IN NUMBER,
                                      p_Scv_St    IN VARCHAR2)
    IS
        PROCEDURE LOG (p_Action IN VARCHAR2, p_Clob IN CLOB DEFAULT NULL)
        IS
        BEGIN
            Tools.LOG ('Api$sc_Verification_Moz.Scdi_Main_Scv_Callback',
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
            Save_Dzr_Recomm (p_Scdi_Id => p_Scdi_Id);

            Api$sc_Verification_Moz.Send_Feedback (
                p_Scdi_Id   => p_Scdi_Id,
                p_Result    => Api$sc_Verification_Moz.c_Feedback_Ok,
                p_Message   => 'Рішення успішно збережено');

            LOG ('Finish by existing process');
            RETURN;
        ELSE
            --Неуспішна верифікація
            --Log('Unlink SC. p_Scdi_Id=' || p_Scdi_Id);
            NULL;
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
                       'Помилка обробки проміжних даних після верифікації: '
                    || SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace,
                p_Scvl_St        => 'VW',
                p_Scvl_St_Old    => NULL);
    END;
END Api$sc_Verification_Moz;
/