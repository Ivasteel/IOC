/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ACT_LIST
IS
    -- Author  : OLEKSII
    -- Created : 16.08.2023
    -- Purpose :

    --=========================================================--
    --  API – Перегляд інформації щодо сформованих та внесених форм оцінювання потреб сім’ї/особи (вторинне оцінювання) в кабінеті НСП
    --=========================================================--
    PROCEDURE Get_avop_G (p_At_Dt_Start   IN     DATE,     --Дата реєстрації з
                          p_At_Dt_Stop    IN     DATE,    --Дата реєстрації по
                          p_At_Num        IN     VARCHAR2,             --Номер
                          p_At_PIB        IN     VARCHAR2, --ПІБ кейс- менеджера, яким сформовано форму оцінювання
                          p_At_src        IN     VARCHAR2,           --Джерело
                          p_is_for_sign   IN     VARCHAR2, --Наявність документів на підпис затвердження
                          p_Res              OUT SYS_REFCURSOR);

    --=========================================================--
    --  API – Перегляд інформації щодо сформованих та внесених форм оцінювання потреб сім’ї/особи (вторинне оцінювання) в кабінеті ОСП
    --=========================================================--
    PROCEDURE Get_Acts_OS (p_At_Num      IN     VARCHAR2,              --Номер
                           p_At_Dt_reg   IN     DATE,        --Дата реєстрації
                           p_At_src      IN     VARCHAR2,            --Джерело
                           p_At_st       IN     VARCHAR2,        --Статус акту
                           p_Res            OUT SYS_REFCURSOR);
END Api$act_List;
/


/* Formatted on 8/12/2025 5:48:38 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ACT_LIST
IS
    Pkg   CONSTANT VARCHAR2 (30) := 'API$ACT_LIST';

    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;


    PROCEDURE Get_avop_List_G (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Pc,
                   a.At_Ap,
                   --Загальна інформація
                   a.At_Num,                                         --7 Номер
                   a.At_Dt,                                --8 Дата реєстрації
                   a.At_Src,                                       --9 Джерело
                   s.Dic_Name
                       AS At_Src_Name,
                   a.At_st,                                        --10 Статус
                   St.Dic_Name
                       AS At_St_Name,
                   ndt.ndt_name_short
                       AS atd_name,         --11 Найменування форми оцінювання
                   --Ким сформовано форму оцінювання
                   uss_rnsp.api$find.Get_Nsp_Name (a.at_rnspm)
                       AS Nsp_Name,              --12 Найменування організації
                   ''
                       AS Nsp_rang,          --13 Посада особи, яка сформувала
                   Ikis_Rbm.Tools.Getcupib (a.at_Cu)
                       AS nsp_pib, --14 Прізвище особи, яка сформувала --15 Ім’я особи, яка сформувала --16 По - батькові особи, яка сформувала
                   --Форма оцінювання щодо кого
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib, --17 Прізвище особи               --18 Ім’я особи  --19 По-батькові особи
                   --Перегляд електронних образів документів
                   --20 Перегляд доданих електронних копій документі до форми оцінювання
                   --21 Електронний документ - форми оцінювання підписаний КЕП
                   --22 Друкований образ форми оцінювання
                   --23 Форму оцінювання затверджено

                   --Відмітки про затвердження форми оцінювання керівником при погодженні та підписанні
                   --25 Затверджено
                   --26 Випадок класифіковано як

                   --Відповідальним за організацію соціального супроводу сім’ї призначено
                   --27 Посада
                   --28 Прізвище
                   --29 Ім’я
                   --30 По-батькові

                   --Підписант (керівник) складеної форми оцінювання потреб сім’ї/особи
                   ''
                       AS At_Approver_rang,             --31 Посада підписанта
                   Cmes$act_Pdsp.Get_Approver_Pib (a.At_Id)
                       AS At_Approver_Pib, --32 Прізвище підписанта --33 Ім’я підписанта --34 По-батькові підписанта
                   --a.At_Org, o.Org_Name AS At_Org_Name,
                   --Код файлу друкованої форми
                   Cmes$act_Pdsp.Get_Act_File (a.At_Id, 842)
                       AS At_Form_File
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN At_Document atd
                       ON atd.atd_at = a.At_Id AND atd.history_status = 'A'
                   JOIN Uss_Ndi.v_Ddn_Ap_Src s ON a.At_Src = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_At_Pdsp_St St ON a.At_St = St.Dic_Value
                   JOIN Opfu o ON a.At_Org = o.Org_Id
                   JOIN Uss_Ndi.v_Ndi_Document_Type ndt
                       ON ndt.ndt_id = atd.atd_ndt;
    /*
    ndt_id = 837 «Карта визначення індивідуальних потреб особи в наданні соціальної послуги консультування»
    ndt_id = 838 «Анкета вуличного консультування»
    ndt_id = 839 «Алфавітна картка отримувача соціальної послуги»
    ndt_id = 844 «Картка визначення індивідуальних потреб особи/сім’ї в наданні соціальної послуги натуральної допомоги»
    */
    END;

    PROCEDURE Get_avop_List_OS (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Pc,
                   a.At_Ap,
                   a.At_Num,                                         --6 Номер
                   a.At_Dt,                                --7 Дата реєстрації
                   a.At_Src,                                       --8 Джерело
                   s.Dic_Name
                       AS At_Src_Name,
                   a.At_st,                                         --9 Статус
                   St.Dic_Name
                       AS At_St_Name,
                   --Ким сформовано форму оцінювання
                   uss_rnsp.api$find.Get_Nsp_Name (a.at_rnspm)
                       AS Nsp_Name,              --10 Найменування організації
                   ''
                       AS Nsp_rang,          --11 Посада особи, яка сформувала
                   Ikis_Rbm.Tools.Getcupib (a.at_Cu)
                       AS nsp_pib, --12 Прізвище особи, яка сформувала --13 Ім’я особи, яка сформувала --14 По - батькові особи, яка сформувала
                   --Форма оцінювання щодо кого
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib, --15 Прізвище особи               --16 Ім’я особи  --17 По-батькові особи
                   --Перегляд електронних образів документів
                   --18 Перегляд доданих електронних копій документів
                   --19 Електронний документ - форми оцінювання підписаний КЕП
                   --20 Друкований образ форми оцінювання
                   --21 Форму оцінювання підписано

                   --Відмітки про ознайомлення з результатами оцінки
                   --23 Ознайомившись із результатами оцінки
                   --24 Відповідно до Закону України «Про захист персональних даних» даю згоду на оброблення персональних даних.
                   --25 Коментар
                   --26 Файл
                   Cmes$act_Pdsp.Get_Approver_Pib (a.At_Id)
                       AS At_Approver_Pib --27 Прізвище підписанта --28 Ім’я підписанта --29 По-батькові підписанта
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN At_Document atd
                       ON atd.atd_at = a.At_Id AND atd.history_status = 'A'
                   JOIN Uss_Ndi.v_Ddn_Ap_Src s ON a.At_Src = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_At_Pdsp_St St ON a.At_St = St.Dic_Value
                   JOIN Opfu o ON a.At_Org = o.Org_Id
                   JOIN Uss_Ndi.v_Ndi_Document_Type ndt
                       ON ndt.ndt_id = atd.atd_ndt;
    END;

    --=========================================================--
    --  API – Перегляд інформації щодо сформованих та внесених форм оцінювання потреб сім’ї/особи (вторинне оцінювання) в кабінеті НСП
    --=========================================================--
    PROCEDURE Get_avop_G (p_At_Dt_Start   IN     DATE,     --Дата реєстрації з
                          p_At_Dt_Stop    IN     DATE,    --Дата реєстрації по
                          p_At_Num        IN     VARCHAR2,             --Номер
                          p_At_PIB        IN     VARCHAR2, --ПІБ кейс- менеджера, яким сформовано форму оцінювання
                          p_At_src        IN     VARCHAR2,           --Джерело
                          p_is_for_sign   IN     VARCHAR2, --Наявність документів на підпис затвердження
                          p_Res              OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Acts_Cm');

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, які закріплені за поточним користувачем
        IF p_is_for_sign = 'T'
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     a.At_Tp = 'AVOP'
                       AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                       AND NVL (p_At_Dt_Stop, a.At_Dt)
                       AND a.At_Num LIKE p_At_Num || '%'
                       AND NVL (Ikis_Rbm.Tools.Getcupib (a.at_cu),
                                Tools.Getuserpib (a.at_Wu)) LIKE
                               p_At_PIB || '%'
                       AND a.at_src = NVL (p_At_src, a.at_src)
                       AND EXISTS
                               (SELECT 1
                                  FROM at_document  atd
                                       LEFT JOIN at_signers s
                                           ON     s.ati_atd = atd.atd_id
                                              AND s.history_status = 'A'
                                 WHERE     atd.atd_at = a.at_id
                                       AND s.ati_id IS NULL);
        ELSE
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     a.At_Tp = 'AVOP'
                       AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                       AND NVL (p_At_Dt_Stop, a.At_Dt)
                       AND a.At_Num LIKE p_At_Num || '%'
                       AND NVL (Ikis_Rbm.Tools.Getcupib (a.at_cu),
                                Tools.Getuserpib (a.at_Wu)) LIKE
                               p_At_PIB || '%'
                       AND a.at_src = NVL (p_At_src, a.at_src);
        END IF;

        Get_avop_List_G (p_Res);
    END;

    --=========================================================--
    --  API – Перегляд інформації щодо сформованих та внесених форм оцінювання потреб сім’ї/особи (вторинне оцінювання) в кабінеті ОСП
    --=========================================================--
    PROCEDURE Get_Acts_OS (p_At_Num      IN     VARCHAR2,              --Номер
                           p_At_Dt_reg   IN     DATE,        --Дата реєстрації
                           p_At_src      IN     VARCHAR2,            --Джерело
                           p_At_st       IN     VARCHAR2,        --Статус акту
                           p_Res            OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Acts_Cm');

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, які закріплені за поточним користувачем
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'AVOP'
                   AND a.At_Num LIKE p_At_Num || '%'
                   AND a.At_Dt = NVL (p_At_Dt_reg, a.At_Dt)
                   AND a.at_src = NVL (p_At_src, a.at_src)
                   AND a.at_st = NVL (p_At_st, a.at_st);

        Get_avop_List_OS (p_Res);
    END;
END Api$act_List;
/