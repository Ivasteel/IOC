/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SC_VERIFICATION_PFU
IS
    -- Author  : KELATEV
    -- Created : 14.08.2024 12:29:58
    -- Purpose : Верифікація проміжних структур від ПФУ та ПФУ верифікації

    c_Pt_Scdi_Id   CONSTANT NUMBER := 509;

    PROCEDURE Set_Scdi_Child_St (
        p_Scdi_Id    IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
        p_Scdi_St    IN Sc_Pfu_Data_Ident.Scdi_St%TYPE,
        p_Is_Force   IN BOOLEAN DEFAULT FALSE);

    PROCEDURE Set_Scdi_Sc (p_Scdi_Id   IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
                           p_Scdi_Sc   IN Sc_Pfu_Data_Ident.Scdi_Sc%TYPE);

    PROCEDURE Find_Scdi_Scpo (p_Scdi_Id IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE);


    PROCEDURE Scdi_Main_Scv_Callback (p_Scdi_Id   IN NUMBER,
                                      p_Scv_Id    IN NUMBER,
                                      p_Scv_St    IN VARCHAR2);

    PROCEDURE Validate_Documents (p_Scdi_Id IN NUMBER, p_Scv_Id IN NUMBER);

    FUNCTION Reg_Put_Moz_Data_Req (p_Rn_Nrt   IN     NUMBER,
                                   p_Obj_Id   IN     NUMBER,
                                   p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Put_Moz_Data_Resp (p_Ur_Id      IN     NUMBER,
                                        p_Response   IN     CLOB,
                                        p_Error      IN OUT VARCHAR2);
END Api$sc_Verification_Pfu;
/


GRANT EXECUTE ON USS_PERSON.API$SC_VERIFICATION_PFU TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:56:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SC_VERIFICATION_PFU
IS
    -------------------------------------------------------------------------------
    --Зміна статусів (VW,VO,VE) у дочірніх елементів
    --Статуси документів змінюються під час "блокування" обєктів для верифікації
    --Якщо якоюсь валідацією було відмічено невалідні дані, на інший статус вже не міняємо
    -------------------------------------------------------------------------------
    PROCEDURE Set_Scdi_Child_St (
        p_Scdi_Id    IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
        p_Scdi_St    IN Sc_Pfu_Data_Ident.Scdi_St%TYPE,
        p_Is_Force   IN BOOLEAN DEFAULT FALSE)
    IS
        l_Is_Force   NUMBER := 0;
    BEGIN
        IF p_Is_Force
        THEN
            l_Is_Force := 1;
        END IF;

        UPDATE Sc_Pfu_Address t
           SET Scpa_St = p_Scdi_St
         WHERE Scpa_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scpa_St <> 'VE');

        UPDATE Sc_Pfu_Document t
           SET Scpo_St = p_Scdi_St
         WHERE Scpo_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scpo_St <> 'VE');

        UPDATE Sc_Pfu_Document_Attr a
           SET a.Scpda_St = p_Scdi_St
         WHERE EXISTS
                   (SELECT 1
                      FROM Sc_Pfu_Document t
                     WHERE     Scpo_Scdi = p_Scdi_Id
                           AND t.Scpo_Id = a.Scpda_Scpo
                           AND (l_Is_Force = 1 OR Scpo_St <> 'VE'));

        UPDATE Sc_Household
           SET Schh_St = p_Scdi_St
         WHERE Schh_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Schh_St <> 'VE');

        UPDATE Sc_Pfu_Pay_Summary
           SET Scpp_St = p_Scdi_St
         WHERE Scpp_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scpp_St <> 'VE');

        UPDATE Sc_Scpp_Detail
           SET Scpd_St = p_Scdi_St
         WHERE Scpd_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scpd_St <> 'VE');

        UPDATE Sc_Scpp_Family
           SET Scpf_St = p_Scdi_St
         WHERE Scpf_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scpf_St <> 'VE');

        /*UPDATE Sc_Scpp_Family
          SET Scpf_St = p_Scdi_St
        WHERE Scpf_Scdi_Main = p_Scdi_Id
          AND (l_Is_Force = 1 OR Scpf_St <> 'VE');*/
        UPDATE Sc_Pfu_Pay_Out
           SET Scpu_St = p_Scdi_St
         WHERE Scpu_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scpu_St <> 'VE');

        UPDATE Sc_Pfu_Accrual
           SET Scpc_St = p_Scdi_St
         WHERE Scpc_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scpc_St <> 'VE');

        UPDATE Sc_Benefit_Extend
           SET Scbe_St = p_Scdi_St
         WHERE Scbe_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scbe_St <> 'VE');

        UPDATE Sc_Benefit_Category
           SET Scbc_St = p_Scdi_St
         WHERE Scbc_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scbc_St <> 'VE');

        UPDATE Sc_Benefit_Type
           SET Scbt_St = p_Scdi_St
         WHERE Scbt_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scbt_St <> 'VE');

        UPDATE Sc_Benefit_Docs
           SET Scbd_St = p_Scdi_St
         WHERE     Scbd_Scpo IN (SELECT Scpo_Id
                                   FROM Sc_Pfu_Document
                                  WHERE Scpo_Scdi = p_Scdi_Id)
               AND (l_Is_Force = 1 OR Scbd_St <> 'VE');

        --MOZ
        UPDATE Sc_Moz_Assessment
           SET Scma_St = p_Scdi_St
         WHERE Scma_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scma_St <> 'VE');

        UPDATE Sc_Moz_Dzr_Recomm
           SET Scmd_St = p_Scdi_St
         WHERE Scmd_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scmd_St <> 'VE');

        UPDATE Sc_Moz_Med_Data_Recomm
           SET Scmm_St = p_Scdi_St
         WHERE Scmm_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scmm_St <> 'VE');

        UPDATE Sc_Moz_Zoz
           SET Scmz_St = p_Scdi_St
         WHERE Scmz_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scmz_St <> 'VE');

        UPDATE Sc_Moz_Loss_Prof_Ability
           SET Scml_St = p_Scdi_St
         WHERE Scml_Scdi = p_Scdi_Id AND (l_Is_Force = 1 OR Scml_St <> 'VE');
    END;

    ----------------------------------------------------------------------------------
    PROCEDURE Set_Scdi_Sc (p_Scdi_Id   IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
                           p_Scdi_Sc   IN Sc_Pfu_Data_Ident.Scdi_Sc%TYPE)
    IS
    BEGIN
        UPDATE Sc_Pfu_Data_Ident
           SET Scdi_Sc = p_Scdi_Sc
         WHERE Scdi_Id = p_Scdi_Id AND Scdi_Sc IS NULL;

        IF SQL%ROWCOUNT > 0
        THEN
            UPDATE Sc_Pfu_Address t
               SET Scpa_Sc = p_Scdi_Sc
             WHERE Scpa_Scdi = p_Scdi_Id;

            UPDATE Sc_Pfu_Document t
               SET Scpo_Sc = p_Scdi_Sc
             WHERE Scpo_Scdi = p_Scdi_Id;

            UPDATE Sc_Household
               SET Schh_Sc = p_Scdi_Sc
             WHERE Schh_Scdi = p_Scdi_Id;

            UPDATE Sc_Pfu_Pay_Summary
               SET Scpp_Sc = p_Scdi_Sc
             WHERE Scpp_Scdi = p_Scdi_Id;

            UPDATE Sc_Scpp_Detail
               SET Scpd_Sc = p_Scdi_Sc
             WHERE Scpd_Scdi = p_Scdi_Id;

            UPDATE Sc_Scpp_Family
               SET Scpf_Sc = p_Scdi_Sc
             WHERE Scpf_Scdi = p_Scdi_Id;

            UPDATE Sc_Scpp_Family
               SET Scpf_Sc_Main = p_Scdi_Sc
             WHERE Scpf_Scdi_Main = p_Scdi_Id;

            UPDATE Sc_Pfu_Pay_Out
               SET Scpu_Sc = p_Scdi_Sc
             WHERE Scpu_Scdi = p_Scdi_Id;

            UPDATE Sc_Pfu_Accrual
               SET Scpc_Sc = p_Scdi_Sc
             WHERE Scpc_Scdi = p_Scdi_Id;

            UPDATE Sc_Benefit_Extend
               SET Scbe_Sc = p_Scdi_Sc
             WHERE Scbe_Scdi = p_Scdi_Id;

            UPDATE Sc_Benefit_Category
               SET Scbc_Sc = p_Scdi_Sc
             WHERE Scbc_Scdi = p_Scdi_Id;

            UPDATE Sc_Benefit_Type
               SET Scbt_Sc = p_Scdi_Sc
             WHERE Scbt_Scdi = p_Scdi_Id;
        END IF;
    END;

    ----------------------------------------------------------------------------------
    PROCEDURE Find_Scdi_Scpo (p_Scdi_Id IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE)
    IS
        TYPE r_Item IS RECORD
        (
            Id          NUMBER,
            Pfu_Code    NUMBER
        );

        TYPE t_Item IS TABLE OF r_Item
            INDEX BY BINARY_INTEGER;

        l_Docs   t_Item;
        l_Attr   t_Item;
    BEGIN
        --Пошук та прив'язка нашого Типу документу
        SELECT Scpo_Id, Scpo_Pfu_Ndt
          BULK COLLECT INTO l_Docs
          FROM Sc_Pfu_Document
         WHERE Scpo_Scdi = p_Scdi_Id AND Scpo_Ndt IS NULL;

        FOR i IN 1 .. l_Docs.COUNT
        LOOP
            DECLARE
                l_Ndt_Id   NUMBER;
            BEGIN
                l_Ndt_Id :=
                    Uss_Ndi.Tools.Decode_Dict (
                        p_Nddc_Tp         => 'NDT_ID',
                        p_Nddc_Src        => 'RZO',
                        p_Nddc_Dest       => 'USS',
                        p_Nddc_Code_Src   => l_Docs (i).Pfu_Code);

                IF l_Ndt_Id IS NOT NULL
                THEN
                    UPDATE Sc_Pfu_Document
                       SET Scpo_Ndt = l_Ndt_Id
                     WHERE Scpo_Id = l_Docs (i).Id;
                END IF;
            END;
        END LOOP;

        --Пошук та прив'язка наших Типів атрибутів документу
        SELECT Scpda_Id, Scpda_Pfu_Nda
          BULK COLLECT INTO l_Attr
          FROM Sc_Pfu_Document, Sc_Pfu_Document_Attr
         WHERE     Scpo_Scdi = p_Scdi_Id
               AND Scpda_Scpo = Scpo_Id
               AND Scpda_Nda IS NULL;

        FOR j IN 1 .. l_Attr.COUNT
        LOOP
            DECLARE
                l_Nda_Id   Sc_Pfu_Document_Attr.Scpda_Nda%TYPE;
            BEGIN
                l_Nda_Id :=
                    Uss_Ndi.Tools.Decode_Dict (
                        p_Nddc_Tp         => 'NDA_ID',
                        p_Nddc_Src        => 'RZO',
                        p_Nddc_Dest       => 'USS',
                        p_Nddc_Code_Src   => l_Attr (j).Pfu_Code);

                IF l_Nda_Id IS NOT NULL
                THEN
                    UPDATE Sc_Pfu_Document_Attr
                       SET Scpda_Nda = l_Nda_Id
                     WHERE Scpda_Id = l_Attr (j).Id;
                END IF;
            END;
        END LOOP;
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
            Tools.LOG ('Api$sc_Verification_Pfu.Scdi_Main_Scv_Callback',
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
            --проставити дату початку/закінчення дії пільг на підставі документів
            /*FOR c IN (SELECT b.Scbc_Id
                        FROM Sc_Benefit_Category b
                       WHERE b.Scbc_Scdi = p_Scdi_Id)
            LOOP
              Dnet$exch_Uss2ikis.Set_Sc_Benefit_Stop_Dt(p_Scbc_Id => c.Scbc_Id);
            END LOOP;*/

            IF Api$socialcard_Ext.Get_Scdi_Nrt_Code (p_Scdi_Id) =
               'USS.Common.PutBenefitCat'
            THEN
                DECLARE
                    l_Sc_Id   NUMBER;
                BEGIN
                    SELECT Scdi_Sc
                      INTO l_Sc_Id
                      FROM Sc_Pfu_Data_Ident
                     WHERE Scdi_Id = p_Scdi_Id;

                    --Реєструємо запит до Мінвету
                    Dnet$exch_Mve.Reg_Create_Vet_Req (p_Sc_Id => l_Sc_Id);
                END;
            END IF;

            LOG ('Finish by existing process');
            RETURN;
        ELSE
            --Неуспішна верифікація
            LOG ('Unlink SC. p_Scdi_Id=' || p_Scdi_Id);
        --Set_Scdi_Sc(p_Scdi_Id => p_Scdi_Id, p_Scdi_Sc => NULL);
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

    -------------------------------------------------------------------------------
    -- Автоматична верифікація по наявності необхідних документів для верифікації даних особи з ПФУ
    -------------------------------------------------------------------------------
    PROCEDURE Validate_Documents (p_Scdi_Id IN NUMBER, p_Scv_Id IN NUMBER)
    IS
        l_Hs         NUMBER := Tools.Gethistsession ();
        l_Numident   Sc_Pfu_Data_Ident.Scdi_Numident%TYPE;
        l_Doc_Tp     Sc_Pfu_Data_Ident.Scdi_Doc_Tp%TYPE;
        l_Doc_Sn     Sc_Pfu_Data_Ident.Scdi_Doc_Sn%TYPE;

        PROCEDURE LOG (p_Action IN VARCHAR2, p_Clob IN CLOB DEFAULT NULL)
        IS
        BEGIN
            Tools.LOG ('Api$sc_Verification_Pfu.Validate_Documents',
                       'SCDI',
                       p_Scdi_Id,
                       p_Action,
                       p_Clob);
        END;
    BEGIN
        LOG ('Start: p_Scdi_Id=' || p_Scdi_Id || ', p_Scv_Id=' || p_Scv_Id);

        SELECT Scdi_Numident, Scdi_Doc_Tp, Scdi_Doc_Sn
          INTO l_Numident, l_Doc_Tp, l_Doc_Sn
          FROM Sc_Pfu_Data_Ident t
         WHERE t.Scdi_Id = p_Scdi_Id;

        IF l_Numident IS NULL
        THEN
            SELECT MAX (Da.Scpda_Val_String)
              INTO l_Numident
              FROM Sc_Pfu_Document d, Sc_Pfu_Document_Attr Da
             WHERE     d.Scpo_Scdi = p_Scdi_Id
                   AND d.Scpo_Ndt = 5
                   AND Da.Scpda_Scpo = d.Scpo_Id
                   AND Da.Scpda_Nda = 1;
        END IF;

        LOG (
               'After Numident: p_Scdi_Id='
            || p_Scdi_Id
            || ', p_Scv_Id='
            || p_Scv_Id
            || ', l_Numident='
            || l_Numident);

        IF l_Doc_Tp IS NULL OR l_Doc_Sn IS NULL
        THEN
            SELECT MAX (d.Scpo_Ndt), MAX (Da.Scpda_Val_String)
              INTO l_Doc_Tp, l_Doc_Sn
              FROM Sc_Pfu_Document d, Sc_Pfu_Document_Attr Da
             WHERE     d.Scpo_Scdi = p_Scdi_Id
                   AND d.Scpo_Ndt IN (6, 7)
                   AND Da.Scpda_Scpo = d.Scpo_Id
                   AND Da.Scpda_Nda IN (3, 9);
        END IF;

        LOG (
               'After Docident: p_Scdi_Id='
            || p_Scdi_Id
            || ', p_Scv_Id='
            || p_Scv_Id
            || ', l_Doc_Tp='
            || l_Doc_Tp
            || ', l_Doc_Sn='
            || l_Doc_Sn);

        IF NOT (   --ІПН
                   (l_Numident IS NOT NULL)
                OR --Документ
                   (    REPLACE (REPLACE (l_Doc_Sn, '-', ''), ' ', '')
                            IS NOT NULL
                    AND --Документи що посвідчують особу
                        NVL (l_Doc_Tp, -1) IN (6,
                                               7,
                                               8,
                                               9,
                                               11,
                                               13,
                                               37,
                                               673,
                                               10095,
                                               10192)))
        THEN
            LOG (
                   'Numident and Docident is empty: p_Scdi_Id='
                || p_Scdi_Id
                || ', p_Scv_Id='
                || p_Scv_Id);
            --НЕУСПІШНА ВЕРИФІКАЦІЯ
            Api$sc_Verification_Moz.Send_Feedback (
                p_Scdi_Id   => p_Scdi_Id,
                p_Result    => Api$sc_Verification_Moz.c_Feedback_Verify,
                p_Message   =>
                    Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                        CHR (38) || '112'));
            Api$sc_Verification.Set_Not_Verified (
                p_Scv_Id    => p_Scv_Id,
                p_Scvl_Hs   => l_Hs,
                p_Error     => CHR (38) || '112');
        END IF;

        LOG (
               'Before Set_Ok: p_Scdi_Id='
            || p_Scdi_Id
            || ', p_Scv_Id='
            || p_Scv_Id);
        Api$sc_Verification.Set_Ok (p_Scv_Id, p_Scvl_Hs => l_Hs);
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
                p_Scvl_Hs        => l_Hs,
                p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Terror,
                p_Scvl_Message   =>
                       SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace,
                p_Scvl_St        => 'VE',
                p_Scvl_St_Old    => NULL);
            --ТЕХНІЧНА ПОМИЛКА
            Api$sc_Verification.Set_Scdi_Verification_Status (
                p_Scv_Id          => p_Scv_Id,
                p_Scv_St          => Api$sc_Verification.c_Scv_St_Error,
                p_Scv_Hs          => l_Hs,
                p_Lock_Main_Scv   => TRUE);
    END;


    -----------------------------------------------------------------
    --         Реєстрація запиту до ПФУ
    --    для передачі відомостей від МОЗ про встановлення інвалідності та призначення ДЗР тимчасового або постійного застосування/використання
    -----------------------------------------------------------------
    FUNCTION Reg_Put_Moz_Data_Req (p_Rn_Nrt   IN     NUMBER,
                                   p_Obj_Id   IN     NUMBER,
                                   p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id   NUMBER;
    BEGIN
        Ikis_Rbm.Api$request_Pfu.Reg_Put_Moz_Data_Req (
            p_Scdi_Id     => p_Obj_Id,
            p_Ur_Ext_Id   => p_Obj_Id,
            p_Rn_Src      => 'MOZ',
            p_Rn_Id       => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$sc_Verification_Pfu.Reg_Put_Moz_Data_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    --         Обробка відповіді на запит до ПФУ
    --    по передачі відомостей від МОЗ про встановлення інвалідності та призначення ДЗР тимчасового або постійного застосування/використання
    -----------------------------------------------------------------
    PROCEDURE Handle_Put_Moz_Data_Resp (p_Ur_Id      IN     NUMBER,
                                        p_Response   IN     CLOB,
                                        p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id              NUMBER;
        l_Scdi_Id            NUMBER;
        l_Scpo_Id            NUMBER;
        l_Scv_Id             NUMBER;
        l_Hs                 NUMBER;
        l_Response_Body      CLOB;
        l_Response_Payload   CLOB;
        l_Reponse_Status     VARCHAR2 (10);
    BEGIN
        l_Hs := Tools.Gethistsession;
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);
        l_Scdi_Id :=
            Ikis_Rbm.Api$request.Get_Rn_Common_Info_Int (
                p_Rnc_Rn   => l_Rn_Id,
                p_Rnc_Pt   => c_Pt_Scdi_Id);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --Зберігаємо відповідь
        Api$sc_Verification.Save_Verification_Answer (
            p_Scva_Rn            => l_Rn_Id,
            p_Scva_Answer_Data   => p_Response,
            p_Scva_Scv           => l_Scv_Id);

           --Парсимо відповідь
           SELECT Status
             INTO l_Reponse_Status
             FROM XMLTABLE (
                      '/*'
                      PASSING Xmltype (p_Response)
                      COLUMNS Status    VARCHAR2 (10) PATH 'Statuses/Status');

        --Збереження відповіді від ПФУ
        SELECT MAX (Scpo_Id)
          INTO l_Scpo_Id
          FROM Sc_Pfu_Document d
         WHERE d.Scpo_Scdi = l_Scdi_Id AND d.Scpo_Ndt = 10367;

        IF l_Scpo_Id IS NULL
        THEN
            Api$socialcard_Ext.Save_Document (p_Scpo_Id     => l_Scpo_Id,
                                              p_Scpo_Scdi   => l_Scdi_Id,
                                              p_Scpo_Ndt    => 10367,
                                              p_Scpo_St     => 'VO'); --Особливості особи
        END IF;

        Api$socialcard_Ext.Save_Doc_Attr (
            p_Scpda_Scpo         => l_Scpo_Id,
            p_Scpda_Nda          => 8736,
            p_Scpda_Val_String   => l_Reponse_Status,
            p_Scpda_St           => 'VO');                      --Ознака особи
        Api$socialcard_Ext.Save_Doc_Attr (p_Scpda_Scpo     => l_Scpo_Id,
                                          p_Scpda_Nda      => 8737,
                                          p_Scpda_Val_Dt   => SYSDATE,
                                          p_Scpda_St       => 'VO'); --Дата отримання ознаки

        /*
        update Scv_Log set Scvl_Message = Chr(38) || '381' where Scvl_Message = 'Ознака особи - Пенсіонер';
        update Scv_Log set Scvl_Message = Chr(38) || '382' where Scvl_Message = 'Ознака особи - Потенційний пенсіонер';
        update Scv_Log set Scvl_Message = Chr(38) || '383' where Scvl_Message = 'Ознака особи - Не на обліку';
        */

        Api$sc_Verification.Write_Scv_Log (
            p_Scv_Id         => l_Scv_Id,
            p_Scvl_Hs        => l_Hs,
            p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Info,
            p_Scvl_Message   =>
                CASE l_Reponse_Status
                    WHEN '1'
                    THEN
                        CHR (38) || '381'
                    WHEN '2'
                    THEN
                        CHR (38) || '382'
                    WHEN '3'
                    THEN
                        CHR (38) || '383'
                    ELSE
                           'Відповідь від ПФУ по ознаці особи: '
                        || l_Reponse_Status
                END,
            p_Scvl_St        => NULL,
            p_Scvl_St_Old    => NULL);

        --УСПІШНА ВЕРИФІКАЦІЯ
        Api$sc_Verification.Set_Ok (l_Scv_Id, p_Scvl_Hs => l_Hs);
    END;
END Api$sc_Verification_Pfu;
/