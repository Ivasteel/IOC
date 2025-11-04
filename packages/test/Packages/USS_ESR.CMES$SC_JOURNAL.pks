/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$SC_JOURNAL
IS
    -- Author  : OLEKSII
    -- Created : 25.10.2023 14:24:25
    -- Purpose : Журнал даних про особу/сім'ю в НСП

    TYPE r_NSP_SC_JOURNAL IS RECORD
    (
        NSJ_ID              NSP_SC_JOURNAL.NSJ_ID%TYPE,
        NSJ_SC              NSP_SC_JOURNAL.NSJ_SC%TYPE,
        NSJ_RNSPM           NSP_SC_JOURNAL.NSJ_RNSPM%TYPE,
        NSJ_NUM             NSP_SC_JOURNAL.NSJ_NUM%TYPE,
        NSJ_ADDRESS         NSP_SC_JOURNAL.NSJ_ADDRESS%TYPE,
        NSJ_PHONE           NSP_SC_JOURNAL.NSJ_PHONE%TYPE,
        NSJ_START_DT        NSP_SC_JOURNAL.NSJ_START_DT%TYPE,
        NSJ_START_REASON    NSP_SC_JOURNAL.NSJ_START_REASON%TYPE,
        NSJ_STOP_DT         NSP_SC_JOURNAL.NSJ_STOP_DT%TYPE,
        NSJ_STOP_REASON     NSP_SC_JOURNAL.NSJ_STOP_REASON%TYPE,
        NSJ_ST              NSP_SC_JOURNAL.NSJ_ST%TYPE,
        NSJ_CASE_CLASS      NSP_SC_JOURNAL.NSJ_CASE_CLASS%TYPE,
        New_Id              NUMBER,
        Deleted             NUMBER
    );

    TYPE t_NSP_SC_JOURNAL IS TABLE OF r_NSP_SC_JOURNAL;

    TYPE r_NSJ_EXPERTS IS RECORD
    (
        NJE_ID            NSJ_EXPERTS.NJE_ID%TYPE, --Ід запису про фахівців, відповідальних за роботу з особою
        NJE_NSJ           NSJ_EXPERTS.NJE_NSJ%TYPE, --Ід запису журналу даних про особу/сім'ю в НСП
        NJE_START_DT      NSJ_EXPERTS.NJE_START_DT%TYPE,    --Роботу розпочато
        NJE_FN            NSJ_EXPERTS.NJE_FN%TYPE,                      --Ім'я
        NJE_MN            NSJ_EXPERTS.NJE_MN%TYPE,               --По-батькові
        NJE_LN            NSJ_EXPERTS.NJE_LN%TYPE,                  --Прізвище
        NJE_PHONE         NSJ_EXPERTS.NJE_PHONE%TYPE,                --Телефон
        NJE_EMAIL         NSJ_EXPERTS.NJE_EMAIL%TYPE,      --Електронна адреса
        NJE_STOP_DT       NSJ_EXPERTS.NJE_STOP_DT%TYPE,     --Роботу завершено
        NJE_NOTES         NSJ_EXPERTS.NJE_NOTES%TYPE,               --Примітки
        HISTORY_STATUS    NSJ_EXPERTS.HISTORY_STATUS%TYPE,    --history_status
        New_Id            NUMBER,
        Deleted           NUMBER
    );

    TYPE t_NSJ_EXPERTS IS TABLE OF r_NSJ_EXPERTS;

    TYPE r_NSJ_PERSONS IS RECORD
    (
        NJP_ID              NSJ_PERSONS.NJP_ID%TYPE, --Ід запису відомостей про членів сім'ї/особу
        NJP_NSJ             NSJ_PERSONS.NJP_NSJ%TYPE, --Ід запису журналу даних про особу/сім'ю в НСП
        NJP_TP              NSJ_PERSONS.NJP_TP%TYPE,              --Тип запису
        NJP_DT              NSJ_PERSONS.NJP_DT%TYPE, --Дата внесення інформації
        NJP_FN              NSJ_PERSONS.NJP_FN%TYPE,                    --Ім'я
        NJP_MN              NSJ_PERSONS.NJP_MN%TYPE,             --По-батькові
        NJP_LN              NSJ_PERSONS.NJP_LN%TYPE,                --Прізвище
        NJP_GENDER          NSJ_PERSONS.NJP_GENDER%TYPE,               --Стать
        NJP_BIRTH_DT        NSJ_PERSONS.NJP_BIRTH_DT%TYPE,   --Дата народження
        NJP_AGE             NSJ_PERSONS.NJP_AGE%TYPE,                    --Вік
        NJP_SC              NSJ_PERSONS.NJP_SC%TYPE,    --Ід соціальної картки
        NJP_RELATION_TP     NSJ_PERSONS.NJP_RELATION_TP%TYPE, --Родинний зв'язок
        NJP_IS_DISABLED     NSJ_PERSONS.NJP_IS_DISABLED%TYPE, --Ознака інвалідності
        NJP_IS_CAPABLE      NSJ_PERSONS.NJP_IS_CAPABLE%TYPE, --Ознака дієздатності
        NJP_WORK_PLACE      NSJ_PERSONS.NJP_WORK_PLACE%TYPE, --Ким і де працює/де навчається
        NJP_PHONE           NSJ_PERSONS.NJP_PHONE%TYPE,   --Контактний телефон
        NJP_REG_ADDRESS     NSJ_PERSONS.NJP_REG_ADDRESS%TYPE, --Місце реєстрації
        NJP_FACT_ADDRESS    NSJ_PERSONS.NJP_FACT_ADDRESS%TYPE, --Місце фактичного проживання
        NJP_NOTES           NSJ_PERSONS.NJP_NOTES%TYPE,             --Примітки
        NJP_NOTES_DT        NSJ_PERSONS.NJP_NOTES_DT%TYPE, --Дата заповнення приміток
        HISTORY_STATUS      NSJ_PERSONS.HISTORY_STATUS%TYPE,  --history_status
        New_Id              NUMBER,
        Deleted             NUMBER
    );

    TYPE t_NSJ_PERSONS IS TABLE OF r_NSJ_PERSONS;

    TYPE r_NSJ_FEATURES IS RECORD
    (
        NJF_ID            NSJ_FEATURES.NJF_ID%TYPE, --Ід запису про основні ознаки та чинники
        NJF_NSJ           NSJ_FEATURES.NJF_NSJ%TYPE, --Ід запису журналу даних про особу/сім'ю в НСП
        NJF_DT            NSJ_FEATURES.NJF_DT%TYPE, --Дата внесення інформації
        HISTORY_STATUS    NSJ_FEATURES.HISTORY_STATUS%TYPE,   --history_status
        New_Id            NUMBER,
        Deleted           NUMBER,
        Feature_Data      XMLTYPE
    );

    TYPE t_NSJ_FEATURES IS TABLE OF r_NSJ_FEATURES;

    TYPE r_NSJ_SUBJECTS IS RECORD
    (
        NJS_ID             NSJ_SUBJECTS.NJS_ID%TYPE, --Ід запису про суб'єкти, які працюють з особою/сім'єю
        NJS_NSJ            NSJ_SUBJECTS.NJS_NSJ%TYPE, --Ід запису журналу даних про особу/сім'ю в НСП
        NJS_DT             NSJ_SUBJECTS.NJS_DT%TYPE,                    --Дата
        NJS_NAME           NSJ_SUBJECTS.NJS_NAME%TYPE,          --Найменування
        NJS_SPEC_FN        NSJ_SUBJECTS.NJS_SPEC_FN%TYPE,               --Ім'я
        NJS_SPEC_MN        NSJ_SUBJECTS.NJS_SPEC_MN%TYPE,        --По-батькові
        NJS_SPEC_LN        NSJ_SUBJECTS.NJS_SPEC_LN%TYPE,           --Прізвище
        NJS_SPEC_PHONE     NSJ_SUBJECTS.NJS_SPEC_PHONE%TYPE,         --Телефон
        NJS_SPEC_EMAIL     NSJ_SUBJECTS.NJS_SPEC_EMAIL%TYPE, --Електронна адреса
        NJS_PURPOSE        NSJ_SUBJECTS.NJS_PURPOSE%TYPE, --З якою метою був залучений або які послуги надавав
        NJS_ISSUED_DOCS    NSJ_SUBJECTS.NJS_ISSUED_DOCS%TYPE, --Документи, видані організацією/спеціалістом
        NJS_NOTES          NSJ_SUBJECTS.NJS_NOTES%TYPE,             --Примітки
        HISTORY_STATUS     NSJ_SUBJECTS.HISTORY_STATUS%TYPE,  --history_status
        New_Id             NUMBER,
        Deleted            NUMBER
    );

    TYPE t_NSJ_SUBJECTS IS TABLE OF r_NSJ_SUBJECTS;

    TYPE r_NSJ_ACCOUNTING IS RECORD
    (
        NJA_ID                  NSJ_ACCOUNTING.NJA_ID%TYPE, --Ід рядка обліку надання послуг
        NJA_NSJ                 NSJ_ACCOUNTING.NJA_NSJ%TYPE, --Ід запису журналу даних про особу/сім'ю в НСП
        NJA_STAGE               NSJ_ACCOUNTING.NJA_STAGE%TYPE,          --Етап
        NJA_START_DT            NSJ_ACCOUNTING.NJA_START_DT%TYPE, --Дата початку
        NJA_STOP_DT             NSJ_ACCOUNTING.NJA_STOP_DT%TYPE, --Дата завершення
        NJA_FACT                NSJ_ACCOUNTING.NJA_FACT%TYPE, --Послуги, заходи, дії
        NJA_INVOLVED_PERSONS    NSJ_ACCOUNTING.NJA_INVOLVED_PERSONS%TYPE, --Залучені члени сім'ї/особи
        NJA_NJE                 NSJ_ACCOUNTING.NJA_NJE%TYPE, --Ід запису про фахівців, відповідальних за роботу з особою
        NJA_RESULTS             NSJ_ACCOUNTING.NJA_RESULTS%TYPE, --Результати роботи
        HISTORY_STATUS          NSJ_ACCOUNTING.HISTORY_STATUS%TYPE, --history_status
        NJA_NOTES               NSJ_ACCOUNTING.NJA_NOTES%TYPE,      --примітки
        New_Id                  NUMBER,
        Deleted                 NUMBER
    );

    TYPE t_NSJ_ACCOUNTING IS TABLE OF r_NSJ_ACCOUNTING;

    TYPE r_NSJ_OTHER_INFO IS RECORD
    (
        NJO_ID            NSJ_OTHER_INFO.NJO_ID%TYPE, --Ід рядка даних обліку іншої інформаціх про особу/сім'ю
        NJO_NSJ           NSJ_OTHER_INFO.NJO_NSJ%TYPE, --Ід запису журналу даних про особу/сім'ю в НСП
        NJO_DT            NSJ_OTHER_INFO.NJO_DT%TYPE,          --Дата внесення
        NJO_INFO          NSJ_OTHER_INFO.NJO_INFO%TYPE,                --Зміст
        HISTORY_STATUS    NSJ_OTHER_INFO.HISTORY_STATUS%TYPE, --history_status
        NJO_NOTES         NSJ_OTHER_INFO.NJO_NOTES%TYPE,            --Примітки
        New_Id            NUMBER,
        Deleted           NUMBER
    );

    TYPE t_NSJ_OTHER_INFO IS TABLE OF r_NSJ_OTHER_INFO;

    TYPE r_NSJ_FEATURE_DATA IS RECORD
    (
        NJFD_ID           NSJ_FEATURE_DATA.NJFD_ID%TYPE, --Ід рядка з ознакою або чинником по особі/сім'ї
        NJFD_NJF          NSJ_FEATURE_DATA.NJFD_NJF%TYPE, --Ід запису про основні ознаки та чинники
        NJFD_NFF          NSJ_FEATURE_DATA.NJFD_NFF%TYPE,             --nff_id
        HISTORY_STATUS    NSJ_FEATURE_DATA.HISTORY_STATUS%TYPE, --history_status
        New_Id            NUMBER,
        Deleted           NUMBER
    );

    TYPE t_NSJ_FEATURE_DATA IS TABLE OF r_NSJ_FEATURE_DATA;

    TYPE r_NSJ_INVOLVED_PERSONS IS RECORD
    (
        NJI_ID            NSJ_INVOLVED_PERSONS.NJI_ID%TYPE, --Ід рядка даних про залучених осіб
        NJI_NJA           NSJ_INVOLVED_PERSONS.NJI_NJA%TYPE, --Ід рядка обліку надання послуг
        NJI_NJP           NSJ_INVOLVED_PERSONS.NJI_NJP%TYPE, --Ід запису відомостей про членів сім'ї/особу
        HISTORY_STATUS    NSJ_INVOLVED_PERSONS.HISTORY_STATUS%TYPE, --history_status
        New_Id            NUMBER,
        Deleted           NUMBER
    );

    TYPE t_NSJ_INVOLVED_PERSONS IS TABLE OF r_NSJ_INVOLVED_PERSONS;

    --====================================================--
    --   Log
    --====================================================--
    PROCEDURE Write_NSJ_Log (p_NJL_NSJ       NSJ_LOG.NJL_NSJ%TYPE,
                             p_NJL_HS        NSJ_LOG.NJL_HS%TYPE,
                             p_NJL_ST        NSJ_LOG.NJL_ST%TYPE,
                             p_NJL_MESSAGE   NSJ_LOG.NJL_MESSAGE%TYPE,
                             p_NJL_OLD_ST    NSJ_LOG.NJL_OLD_ST%TYPE,
                             p_NJL_TP        NSJ_LOG.NJL_TP%TYPE:= 'SYS');

    --====================================================--
    --   Збереження інформації Фахівці, відповідальні за організацію роботи з особою/сім'єю
    --====================================================--
    PROCEDURE Save_NSJ_EXPERTS (p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                p_Xml      IN CLOB);

    --====================================================--
    --   Збереження інформації Відомості про членів сім'ї/особу
    --====================================================--
    PROCEDURE Save_NSJ_PERSONSS (p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                 p_Xml      IN CLOB);

    --====================================================--
    --   Збереження інформації Основні ознаки та чинники функціонування особи/сім'ї
    --====================================================--
    PROCEDURE Save_NSJ_FEATURES (p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                 p_Xml      IN CLOB);

    --====================================================--
    --   Збереження інформації Суб'єкти соціальної роботи, які працюють з особою/сім'єю
    --====================================================--
    PROCEDURE Save_NSJ_SUBJECTS (p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                 p_Xml      IN CLOB);

    --====================================================--
    --   Збереження інформації Дані обліку надання послуг
    --====================================================--
    PROCEDURE Save_NSJ_ACCOUNTINGS (p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                    p_Xml      IN CLOB);

    --====================================================--
    --   Збереження інформації Дані обліку іншої інформації, що стосується особи/сім'ї
    --====================================================--
    PROCEDURE Save_NSJ_OTHER_INFOS (p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                    p_Xml      IN CLOB);

    --====================================================--
    --   Збереження інформації Ознака або чинник функціонування особи/сім'ї
    --====================================================--
    /*
      PROCEDURE Save_NSJ_FEATURE_DATAS(
                    p_NSJ_ID                NSP_SC_JOURNAL.NSJ_ID%TYPE,
                    p_Xml                IN CLOB
                    );
    */
    --====================================================--
    --   Збереження інформації Дані про залучених осіб щодо обліку надання послуг
    --====================================================--
    PROCEDURE Save_NSJ_INVOLVED_PERSONS (
        p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_Xml      IN CLOB);

    --====================================================--
    --   Отримання інформації по КАТОТТГ
    --====================================================--
    FUNCTION get_katottg_info (p_kaot_id NUMBER)
        RETURN VARCHAR2;

    --====================================================--
    --  Отримання інформації по вулиці
    --====================================================--
    FUNCTION get_street_info (p_ns_id NUMBER)
        RETURN VARCHAR2;

    --====================================================--
    --  Адреса регістрації
    --====================================================--
    FUNCTION get_pers_reg_address (p_ap_id NUMBER, p_app_id NUMBER)
        RETURN VARCHAR2;

    --====================================================--
    --  Адреса проживання
    --====================================================--
    FUNCTION get_pers_fact_address (p_ap_id NUMBER, p_app_id NUMBER)
        RETURN VARCHAR2;

    --====================================================--

    PROCEDURE Create_SC_JOURNAL (p_at_id act.at_id%TYPE);

    PROCEDURE Update_SC_JOURNAL (p_at_id act.at_id%TYPE);

    PROCEDURE Close_SC_JOURNAL (p_nsj_id nsp_sc_journal.nsj_id%TYPE);

    --====================================================--
    -- Соціальної картки сім’ї/особи 1005 в кабінеті КМ
    --====================================================--
    PROCEDURE Get_JOURNAL_Card (
        p_nsj_id                 IN     NUMBER,
        p_NSP_SC_JOURNAL            OUT SYS_REFCURSOR,
        p_NSJ_PERSONS               OUT SYS_REFCURSOR,
        p_NSJ_EXPERTS               OUT SYS_REFCURSOR,
        p_NSJ_FEATURES              OUT SYS_REFCURSOR,
        p_NSJ_FEATURE_DATA          OUT SYS_REFCURSOR,
        p_NSJ_SUBJECTS              OUT SYS_REFCURSOR,
        p_NSJ_ACCOUNTING            OUT SYS_REFCURSOR,
        p_NSJ_OTHER_INFO            OUT SYS_REFCURSOR,
        p_NSJ_INVOLVED_PERSONS      OUT SYS_REFCURSOR);

    --====================================================--
    -- Перелік Соціальної картки сім’ї/особи 1005 в кабінеті КМ
    --====================================================--
    PROCEDURE Get_JOURNAL_LIST_CM (p_Dt_Start   IN     DATE,
                                   p_Dt_Stop    IN     DATE,
                                   p_Num        IN     VARCHAR2,
                                   p_St         IN     VARCHAR2,
                                   p_Ln         IN     VARCHAR2,
                                   p_Fn         IN     VARCHAR2,
                                   p_Mn         IN     VARCHAR2,
                                   p_sc_id      IN     NUMBER,
                                   p_Res           OUT SYS_REFCURSOR);

    -- побудова друкованої форми
    PROCEDURE get_form_file (p_nsj_id IN NUMBER, p_blob OUT BLOB);

    -- список по зверненню
    PROCEDURE get_nsj_list (p_ap_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- картка по зверненню та НСП
    PROCEDURE get_nsj_list_pr (p_ap_id           IN     NUMBER,
                               p_cmes_Owner_Id   IN     NUMBER,
                               res_cur              OUT SYS_REFCURSOR);
END CMES$SC_JOURNAL;
/


GRANT EXECUTE ON USS_ESR.CMES$SC_JOURNAL TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.CMES$SC_JOURNAL TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$SC_JOURNAL TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.CMES$SC_JOURNAL TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$SC_JOURNAL
IS
    Pkg   VARCHAR2 (50) := 'CMES$SC_JOURNAL';

    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    --====================================================--
    --   Log
    --====================================================--
    PROCEDURE Write_NSJ_Log (p_NJL_NSJ       NSJ_LOG.NJL_NSJ%TYPE,
                             p_NJL_HS        NSJ_LOG.NJL_HS%TYPE,
                             p_NJL_ST        NSJ_LOG.NJL_ST%TYPE,
                             p_NJL_MESSAGE   NSJ_LOG.NJL_MESSAGE%TYPE,
                             p_NJL_OLD_ST    NSJ_LOG.NJL_OLD_ST%TYPE,
                             p_NJL_TP        NSJ_LOG.NJL_TP%TYPE:= 'SYS')
    IS
        l_Hs   Histsession.Hs_Id%TYPE;
    BEGIN
        IF p_NJL_HS IS NOT NULL
        THEN
            l_Hs := p_NJL_HS;
        ELSIF Tools.Getcurrwu IS NOT NULL
        THEN
            l_Hs := Tools.Gethistsession;
        ELSIF Ikis_Rbm.Tools.Getcurrentcu IS NOT NULL
        THEN
            l_Hs := Tools.Gethistsessioncmes;
        END IF;

        INSERT INTO NSJ_LOG (NJL_ID,
                             NJL_NSJ,
                             NJL_HS,
                             NJL_ST,
                             NJL_MESSAGE,
                             NJL_OLD_ST,
                             NJL_TP)
             VALUES (0,
                     p_NJL_NSJ,
                     l_Hs,
                     p_NJL_ST,
                     p_NJL_MESSAGE,
                     p_NJL_OLD_ST,
                     p_NJL_TP);
    END;

    --====================================================--
    --   Парсинг акту
    --====================================================--
    FUNCTION Parse (p_Type_Name      IN VARCHAR2,
                    p_Clob_Input     IN BOOLEAN DEFAULT TRUE,
                    p_Has_Root_Tag   IN BOOLEAN DEFAULT TRUE)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN Type2xmltable (Pkg,
                              p_Type_Name,
                              TRUE,
                              p_Clob_Input,
                              p_Has_Root_Tag);
    END;

    --====================================================--
    FUNCTION Parse_SC_JOURNAL (p_Xml IN CLOB)
        RETURN r_NSP_SC_JOURNAL
    IS
        l_Result   r_NSP_SC_JOURNAL;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('t_NSP_SC_JOURNAL')
            INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Журнал даних про особу/сім''ю в НСП: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    FUNCTION Parse_ACCOUNTING (p_Xml IN CLOB)
        RETURN t_NSJ_ACCOUNTING
    IS
        l_Result   t_NSJ_ACCOUNTING;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('t_NSJ_ACCOUNTING')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Дані обліку надання послуг: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    FUNCTION Parse_EXPERTS (p_Xml IN CLOB)
        RETURN t_NSJ_EXPERTS
    IS
        l_Result   t_NSJ_EXPERTS;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('t_NSJ_EXPERTS')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Фахівці, відповідальні за організацію роботи з особою/сім''єю: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    FUNCTION Parse_FEATURES (p_Xml IN CLOB)
        RETURN t_NSJ_FEATURES
    IS
        l_Result   t_NSJ_FEATURES;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('t_NSJ_FEATURES')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Основні ознаки та чинники функціонування особи/сім''ї: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    FUNCTION Parse_FEATURE_DATA (p_Xml IN XMLTYPE)
        RETURN t_NSJ_FEATURE_DATA
    IS
        l_Result   t_NSJ_FEATURE_DATA;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_NSJ_FEATURE_DATA ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_NSJ_FEATURE_DATA', FALSE, TRUE)
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Ознака або чинник функціонування особи/сім''ї: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    FUNCTION Parse_INVOLVED_PERSONS (p_Xml IN CLOB)
        RETURN t_NSJ_INVOLVED_PERSONS
    IS
        l_Result   t_NSJ_INVOLVED_PERSONS;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('t_NSJ_INVOLVED_PERSONS')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Дані про залучених осіб щодо обліку надання послуг: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    FUNCTION Parse_OTHER_INFO (p_Xml IN CLOB)
        RETURN t_NSJ_OTHER_INFO
    IS
        l_Result   t_NSJ_OTHER_INFO;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('t_NSJ_OTHER_INFO')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Дані обліку іншої інформації, що стосується особи/сім''ї: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    FUNCTION Parse_PERSONS (p_Xml IN CLOB)
        RETURN t_NSJ_PERSONS
    IS
        l_Result   t_NSJ_PERSONS;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('t_NSJ_PERSONS')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Відомості про членів сім''ї/особу: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    FUNCTION Parse_SUBJECTS (p_Xml IN CLOB)
        RETURN t_NSJ_SUBJECTS
    IS
        l_Result   t_NSJ_SUBJECTS;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('t_NSJ_SUBJECTS')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Суб''єкти соціальної роботи, які працюють з особою/сім''єю: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;


    --====================================================--
    --   Збереження інформації Фахівці, відповідальні за організацію роботи з особою/сім'єю
    --====================================================--
    PROCEDURE Save_NSJ_EXPERT (
        p_NJE_ID               NSJ_EXPERTS.NJE_ID%TYPE,
        p_NJE_NSJ              NSJ_EXPERTS.NJE_NSJ%TYPE,
        p_NJE_START_DT         NSJ_EXPERTS.NJE_START_DT%TYPE,
        p_NJE_FN               NSJ_EXPERTS.NJE_FN%TYPE,
        p_NJE_MN               NSJ_EXPERTS.NJE_MN%TYPE,
        p_NJE_LN               NSJ_EXPERTS.NJE_LN%TYPE,
        p_NJE_PHONE            NSJ_EXPERTS.NJE_PHONE%TYPE,
        p_NJE_EMAIL            NSJ_EXPERTS.NJE_EMAIL%TYPE,
        p_NJE_STOP_DT          NSJ_EXPERTS.NJE_STOP_DT%TYPE,
        p_NJE_NOTES            NSJ_EXPERTS.NJE_NOTES%TYPE,
        p_HISTORY_STATUS       NSJ_EXPERTS.HISTORY_STATUS%TYPE,
        p_HS                   NUMBER,
        p_New_Id           OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_NJE_ID, -1) < 0
        THEN
            INSERT INTO NSJ_EXPERTS (NJE_ID,
                                     NJE_NSJ,
                                     NJE_START_DT,
                                     NJE_FN,
                                     NJE_MN,
                                     NJE_LN,
                                     NJE_PHONE,
                                     NJE_EMAIL,
                                     NJE_STOP_DT,
                                     NJE_NOTES,
                                     HISTORY_STATUS)
                 VALUES (0,
                         p_NJE_NSJ,
                         p_NJE_START_DT,
                         p_NJE_FN,
                         p_NJE_MN,
                         p_NJE_LN,
                         p_NJE_PHONE,
                         p_NJE_EMAIL,
                         p_NJE_STOP_DT,
                         p_NJE_NOTES,
                         p_HISTORY_STATUS)
              RETURNING NJE_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_NJE_ID;

            UPDATE NSJ_EXPERTS t
               SET t.NJE_ID = p_NJE_ID,
                   t.NJE_NSJ = p_NJE_NSJ,
                   t.NJE_START_DT = p_NJE_START_DT,
                   t.NJE_FN = p_NJE_FN,
                   t.NJE_MN = p_NJE_MN,
                   t.NJE_LN = p_NJE_LN,
                   t.NJE_PHONE = p_NJE_PHONE,
                   t.NJE_EMAIL = p_NJE_EMAIL,
                   t.NJE_STOP_DT = p_NJE_STOP_DT,
                   t.NJE_NOTES = p_NJE_NOTES,
                   t.HISTORY_STATUS = p_HISTORY_STATUS,
                   t.NJE_HS_UPD = p_HS
             WHERE t.NJE_ID = p_NJE_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження інформації Відомості про членів сім'ї/особу
    --====================================================--
    PROCEDURE Save_NSJ_PERSON (
        p_NJP_ID                 NSJ_PERSONS.NJP_ID%TYPE,
        p_NJP_NSJ                NSJ_PERSONS.NJP_NSJ%TYPE,
        p_NJP_TP                 NSJ_PERSONS.NJP_TP%TYPE,
        p_NJP_DT                 NSJ_PERSONS.NJP_DT%TYPE,
        p_NJP_FN                 NSJ_PERSONS.NJP_FN%TYPE,
        p_NJP_MN                 NSJ_PERSONS.NJP_MN%TYPE,
        p_NJP_LN                 NSJ_PERSONS.NJP_LN%TYPE,
        p_NJP_GENDER             NSJ_PERSONS.NJP_GENDER%TYPE,
        p_NJP_BIRTH_DT           NSJ_PERSONS.NJP_BIRTH_DT%TYPE,
        p_NJP_AGE                NSJ_PERSONS.NJP_AGE%TYPE,
        p_NJP_SC                 NSJ_PERSONS.NJP_SC%TYPE,
        p_NJP_RELATION_TP        NSJ_PERSONS.NJP_RELATION_TP%TYPE,
        p_NJP_IS_DISABLED        NSJ_PERSONS.NJP_IS_DISABLED%TYPE,
        p_NJP_IS_CAPABLE         NSJ_PERSONS.NJP_IS_CAPABLE%TYPE,
        p_NJP_WORK_PLACE         NSJ_PERSONS.NJP_WORK_PLACE%TYPE,
        p_NJP_PHONE              NSJ_PERSONS.NJP_PHONE%TYPE,
        p_NJP_REG_ADDRESS        NSJ_PERSONS.NJP_REG_ADDRESS%TYPE,
        p_NJP_FACT_ADDRESS       NSJ_PERSONS.NJP_FACT_ADDRESS%TYPE,
        p_NJP_NOTES              NSJ_PERSONS.NJP_NOTES%TYPE,
        p_NJP_NOTES_DT           NSJ_PERSONS.NJP_NOTES_DT%TYPE,
        p_HISTORY_STATUS         NSJ_PERSONS.HISTORY_STATUS%TYPE,
        p_HS                     NUMBER,
        p_New_Id             OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_NJP_ID, -1) < 0
        THEN
            INSERT INTO NSJ_PERSONS (NJP_ID,
                                     NJP_NSJ,
                                     NJP_TP,
                                     NJP_DT,
                                     NJP_FN,
                                     NJP_MN,
                                     NJP_LN,
                                     NJP_GENDER,
                                     NJP_BIRTH_DT,
                                     NJP_AGE,
                                     NJP_SC,
                                     NJP_RELATION_TP,
                                     NJP_IS_DISABLED,
                                     NJP_IS_CAPABLE,
                                     NJP_WORK_PLACE,
                                     NJP_PHONE,
                                     NJP_REG_ADDRESS,
                                     NJP_FACT_ADDRESS,
                                     NJP_NOTES,
                                     NJP_NOTES_DT,
                                     HISTORY_STATUS)
                 VALUES (0,
                         p_NJP_NSJ,
                         p_NJP_TP,
                         p_NJP_DT,
                         p_NJP_FN,
                         p_NJP_MN,
                         p_NJP_LN,
                         p_NJP_GENDER,
                         p_NJP_BIRTH_DT,
                         p_NJP_AGE,
                         p_NJP_SC,
                         p_NJP_RELATION_TP,
                         p_NJP_IS_DISABLED,
                         p_NJP_IS_CAPABLE,
                         p_NJP_WORK_PLACE,
                         p_NJP_PHONE,
                         p_NJP_REG_ADDRESS,
                         p_NJP_FACT_ADDRESS,
                         p_NJP_NOTES,
                         p_NJP_NOTES_DT,
                         p_HISTORY_STATUS)
              RETURNING NJP_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_NJP_ID;

            UPDATE NSJ_PERSONS t
               SET t.NJP_ID = p_NJP_ID,
                   t.NJP_NSJ = p_NJP_NSJ,
                   t.NJP_TP = p_NJP_TP,
                   t.NJP_DT = p_NJP_DT,
                   t.NJP_FN = p_NJP_FN,
                   t.NJP_MN = p_NJP_MN,
                   t.NJP_LN = p_NJP_LN,
                   t.NJP_GENDER = p_NJP_GENDER,
                   t.NJP_BIRTH_DT = p_NJP_BIRTH_DT,
                   t.NJP_AGE = p_NJP_AGE,
                   t.NJP_SC = p_NJP_SC,
                   t.NJP_RELATION_TP = p_NJP_RELATION_TP,
                   t.NJP_IS_DISABLED = p_NJP_IS_DISABLED,
                   t.NJP_IS_CAPABLE = p_NJP_IS_CAPABLE,
                   t.NJP_WORK_PLACE = p_NJP_WORK_PLACE,
                   t.NJP_PHONE = p_NJP_PHONE,
                   t.NJP_REG_ADDRESS = p_NJP_REG_ADDRESS,
                   t.NJP_FACT_ADDRESS = p_NJP_FACT_ADDRESS,
                   t.NJP_NOTES = p_NJP_NOTES,
                   t.NJP_NOTES_DT = p_NJP_NOTES_DT,
                   t.HISTORY_STATUS = p_HISTORY_STATUS,
                   t.NJP_HS_UPD = p_HS
             WHERE t.NJP_ID = p_NJP_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження інформації Основні ознаки та чинники функціонування особи/сім'ї
    --====================================================--
    PROCEDURE Save_NSJ_FEATURE (
        p_NJF_ID               NSJ_FEATURES.NJF_ID%TYPE,
        p_NJF_NSJ              NSJ_FEATURES.NJF_NSJ%TYPE,
        p_NJF_DT               NSJ_FEATURES.NJF_DT%TYPE,
        p_HISTORY_STATUS       NSJ_FEATURES.HISTORY_STATUS%TYPE,
        p_HS                   NUMBER,
        p_New_Id           OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_NJF_ID, -1) < 0
        THEN
            INSERT INTO NSJ_FEATURES (NJF_ID,
                                      NJF_NSJ,
                                      NJF_DT,
                                      HISTORY_STATUS)
                 VALUES (0,
                         p_NJF_NSJ,
                         p_NJF_DT,
                         p_HISTORY_STATUS)
              RETURNING NJF_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_NJF_ID;

            UPDATE NSJ_FEATURES t
               SET t.NJF_ID = p_NJF_ID,
                   t.NJF_NSJ = p_NJF_NSJ,
                   t.NJF_DT = p_NJF_DT,
                   t.HISTORY_STATUS = p_HISTORY_STATUS,
                   t.NJF_HS_UPD = p_HS
             WHERE t.NJF_ID = p_NJF_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження інформації Суб'єкти соціальної роботи, які працюють з особою/сім'єю
    --====================================================--
    PROCEDURE Save_NSJ_SUBJECT (
        p_NJS_ID                NSJ_SUBJECTS.NJS_ID%TYPE,
        p_NJS_NSJ               NSJ_SUBJECTS.NJS_NSJ%TYPE,
        p_NJS_DT                NSJ_SUBJECTS.NJS_DT%TYPE,
        p_NJS_NAME              NSJ_SUBJECTS.NJS_NAME%TYPE,
        p_NJS_SPEC_FN           NSJ_SUBJECTS.NJS_SPEC_FN%TYPE,
        p_NJS_SPEC_MN           NSJ_SUBJECTS.NJS_SPEC_MN%TYPE,
        p_NJS_SPEC_LN           NSJ_SUBJECTS.NJS_SPEC_LN%TYPE,
        p_NJS_SPEC_PHONE        NSJ_SUBJECTS.NJS_SPEC_PHONE%TYPE,
        p_NJS_SPEC_EMAIL        NSJ_SUBJECTS.NJS_SPEC_EMAIL%TYPE,
        p_NJS_PURPOSE           NSJ_SUBJECTS.NJS_PURPOSE%TYPE,
        p_NJS_ISSUED_DOCS       NSJ_SUBJECTS.NJS_ISSUED_DOCS%TYPE,
        p_NJS_NOTES             NSJ_SUBJECTS.NJS_NOTES%TYPE,
        p_HISTORY_STATUS        NSJ_SUBJECTS.HISTORY_STATUS%TYPE,
        p_HS                    NUMBER,
        p_New_Id            OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_NJS_ID, -1) < 0
        THEN
            INSERT INTO NSJ_SUBJECTS (NJS_ID,
                                      NJS_NSJ,
                                      NJS_DT,
                                      NJS_NAME,
                                      NJS_SPEC_FN,
                                      NJS_SPEC_MN,
                                      NJS_SPEC_LN,
                                      NJS_SPEC_PHONE,
                                      NJS_SPEC_EMAIL,
                                      NJS_PURPOSE,
                                      NJS_ISSUED_DOCS,
                                      NJS_NOTES,
                                      HISTORY_STATUS)
                 VALUES (0,
                         p_NJS_NSJ,
                         p_NJS_DT,
                         p_NJS_NAME,
                         p_NJS_SPEC_FN,
                         p_NJS_SPEC_MN,
                         p_NJS_SPEC_LN,
                         p_NJS_SPEC_PHONE,
                         p_NJS_SPEC_EMAIL,
                         p_NJS_PURPOSE,
                         p_NJS_ISSUED_DOCS,
                         p_NJS_NOTES,
                         p_HISTORY_STATUS)
              RETURNING NJS_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_NJS_ID;

            UPDATE NSJ_SUBJECTS t
               SET t.NJS_ID = p_NJS_ID,
                   t.NJS_NSJ = p_NJS_NSJ,
                   t.NJS_DT = p_NJS_DT,
                   t.NJS_NAME = p_NJS_NAME,
                   t.NJS_SPEC_FN = p_NJS_SPEC_FN,
                   t.NJS_SPEC_MN = p_NJS_SPEC_MN,
                   t.NJS_SPEC_LN = p_NJS_SPEC_LN,
                   t.NJS_SPEC_PHONE = p_NJS_SPEC_PHONE,
                   t.NJS_SPEC_EMAIL = p_NJS_SPEC_EMAIL,
                   t.NJS_PURPOSE = p_NJS_PURPOSE,
                   t.NJS_ISSUED_DOCS = p_NJS_ISSUED_DOCS,
                   t.NJS_NOTES = p_NJS_NOTES,
                   t.HISTORY_STATUS = p_HISTORY_STATUS,
                   t.NJS_HS_UPD = p_HS
             WHERE t.NJS_ID = p_NJS_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження інформації Журнал даних про особу/сім'ю в НСП
    --====================================================--
    PROCEDURE Save_NSP_SC_JOURNAL (
        p_NSJ_ID                 NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_NSJ_SC                 NSP_SC_JOURNAL.NSJ_SC%TYPE,
        p_NSJ_RNSPM              NSP_SC_JOURNAL.NSJ_RNSPM%TYPE,
        p_NSJ_NUM                NSP_SC_JOURNAL.NSJ_NUM%TYPE,
        p_NSJ_ADDRESS            NSP_SC_JOURNAL.NSJ_ADDRESS%TYPE,
        p_NSJ_PHONE              NSP_SC_JOURNAL.NSJ_PHONE%TYPE,
        p_NSJ_START_DT           NSP_SC_JOURNAL.NSJ_START_DT%TYPE,
        p_NSJ_START_REASON       NSP_SC_JOURNAL.NSJ_START_REASON%TYPE,
        p_NSJ_STOP_DT            NSP_SC_JOURNAL.NSJ_STOP_DT%TYPE,
        p_NSJ_STOP_REASON        NSP_SC_JOURNAL.NSJ_STOP_REASON%TYPE,
        p_NSJ_ST                 NSP_SC_JOURNAL.NSJ_ST%TYPE,
        p_NSJ_CASE_CLASS         NSP_SC_JOURNAL.NSJ_CASE_CLASS%TYPE,
        p_HS                     NUMBER,
        p_New_Id             OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_NSJ_ID, -1) < 0
        THEN
            INSERT INTO NSP_SC_JOURNAL (NSJ_ID,
                                        NSJ_SC,
                                        NSJ_RNSPM,
                                        NSJ_NUM,
                                        NSJ_ADDRESS,
                                        NSJ_PHONE,
                                        NSJ_START_DT,
                                        NSJ_START_REASON,
                                        NSJ_STOP_DT,
                                        NSJ_STOP_REASON,
                                        NSJ_ST,
                                        NSJ_CASE_CLASS)
                 VALUES (0,
                         p_NSJ_SC,
                         p_NSJ_RNSPM,
                         p_NSJ_NUM,
                         p_NSJ_ADDRESS,
                         p_NSJ_PHONE,
                         p_NSJ_START_DT,
                         p_NSJ_START_REASON,
                         p_NSJ_STOP_DT,
                         p_NSJ_STOP_REASON,
                         p_NSJ_ST,
                         p_NSJ_CASE_CLASS)
              RETURNING NSJ_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_NSJ_ID;

            UPDATE NSP_SC_JOURNAL t
               SET t.NSJ_ID = p_NSJ_ID,
                   t.NSJ_SC = p_NSJ_SC,
                   t.NSJ_RNSPM = p_NSJ_RNSPM,
                   t.NSJ_NUM = p_NSJ_NUM,
                   t.NSJ_ADDRESS = p_NSJ_ADDRESS,
                   t.NSJ_PHONE = p_NSJ_PHONE,
                   t.NSJ_START_DT = p_NSJ_START_DT,
                   t.NSJ_START_REASON = p_NSJ_START_REASON,
                   t.NSJ_STOP_DT = p_NSJ_STOP_DT,
                   t.NSJ_STOP_REASON = p_NSJ_STOP_REASON,
                   t.NSJ_ST = p_NSJ_ST,
                   t.NSJ_CASE_CLASS = p_NSJ_CASE_CLASS
             WHERE t.NSJ_ID = p_NSJ_ID;
        END IF;
    END;

    --========================================================--
    --   Збереження інформації Дані обліку надання послуг
    --========================================================--
    PROCEDURE Save_NSJ_ACCOUNTING (
        p_NJA_ID                     NSJ_ACCOUNTING.NJA_ID%TYPE,
        p_NJA_NSJ                    NSJ_ACCOUNTING.NJA_NSJ%TYPE,
        p_NJA_STAGE                  NSJ_ACCOUNTING.NJA_STAGE%TYPE,
        p_NJA_START_DT               NSJ_ACCOUNTING.NJA_START_DT%TYPE,
        p_NJA_STOP_DT                NSJ_ACCOUNTING.NJA_STOP_DT%TYPE,
        p_NJA_FACT                   NSJ_ACCOUNTING.NJA_FACT%TYPE,
        p_NJA_INVOLVED_PERSONS       NSJ_ACCOUNTING.NJA_INVOLVED_PERSONS%TYPE,
        p_NJA_NJE                    NSJ_ACCOUNTING.NJA_NJE%TYPE,
        p_NJA_RESULTS                NSJ_ACCOUNTING.NJA_RESULTS%TYPE,
        p_HISTORY_STATUS             NSJ_ACCOUNTING.HISTORY_STATUS%TYPE,
        p_NJA_NOTES                  NSJ_ACCOUNTING.NJA_NOTES%TYPE,
        p_HS                         NUMBER,
        p_New_Id                 OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_NJA_ID, -1) < 0
        THEN
            INSERT INTO NSJ_ACCOUNTING (NJA_ID,
                                        NJA_NSJ,
                                        NJA_STAGE,
                                        NJA_START_DT,
                                        NJA_STOP_DT,
                                        NJA_FACT,
                                        NJA_INVOLVED_PERSONS,
                                        NJA_NJE,
                                        NJA_RESULTS,
                                        HISTORY_STATUS,
                                        NJA_NOTES)
                 VALUES (0,
                         p_NJA_NSJ,
                         p_NJA_STAGE,
                         p_NJA_START_DT,
                         p_NJA_STOP_DT,
                         p_NJA_FACT,
                         p_NJA_INVOLVED_PERSONS,
                         p_NJA_NJE,
                         p_NJA_RESULTS,
                         p_HISTORY_STATUS,
                         p_NJA_NOTES)
              RETURNING NJA_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_NJA_ID;

            UPDATE NSJ_ACCOUNTING t
               SET t.NJA_ID = p_NJA_ID,
                   t.NJA_NSJ = p_NJA_NSJ,
                   t.NJA_STAGE = p_NJA_STAGE,
                   t.NJA_START_DT = p_NJA_START_DT,
                   t.NJA_STOP_DT = p_NJA_STOP_DT,
                   t.NJA_FACT = p_NJA_FACT,
                   t.NJA_INVOLVED_PERSONS = p_NJA_INVOLVED_PERSONS,
                   t.NJA_NJE = p_NJA_NJE,
                   t.NJA_RESULTS = p_NJA_RESULTS,
                   t.HISTORY_STATUS = p_HISTORY_STATUS,
                   t.NJA_NOTES = p_NJA_NOTES,
                   t.NJA_HS_UPD = p_HS
             WHERE t.NJA_ID = p_NJA_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження інформації Дані обліку іншої інформації, що стосується особи/сім'ї
    --====================================================--
    PROCEDURE Save_NSJ_OTHER_INFO (
        p_NJO_ID               NSJ_OTHER_INFO.NJO_ID%TYPE,
        p_NJO_NSJ              NSJ_OTHER_INFO.NJO_NSJ%TYPE,
        p_NJO_DT               NSJ_OTHER_INFO.NJO_DT%TYPE,
        p_NJO_INFO             NSJ_OTHER_INFO.NJO_INFO%TYPE,
        p_HISTORY_STATUS       NSJ_OTHER_INFO.HISTORY_STATUS%TYPE,
        p_NJO_NOTES            NSJ_OTHER_INFO.NJO_NOTES%TYPE,
        p_HS                   NUMBER,
        p_New_Id           OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_NJO_ID, -1) < 0
        THEN
            INSERT INTO NSJ_OTHER_INFO (NJO_ID,
                                        NJO_NSJ,
                                        NJO_DT,
                                        NJO_INFO,
                                        HISTORY_STATUS,
                                        NJO_NOTES,
                                        NJO_HS_UPD)
                 VALUES (0,
                         p_NJO_NSJ,
                         p_NJO_DT,
                         p_NJO_INFO,
                         p_HISTORY_STATUS,
                         p_NJO_NOTES,
                         p_HS)
              RETURNING NJO_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_NJO_ID;

            UPDATE NSJ_OTHER_INFO t
               SET t.NJO_ID = p_NJO_ID,
                   t.NJO_NSJ = p_NJO_NSJ,
                   t.NJO_DT = p_NJO_DT,
                   t.NJO_INFO = p_NJO_INFO,
                   t.HISTORY_STATUS = p_HISTORY_STATUS,
                   t.NJO_HS_UPD = p_HS,
                   t.NJO_NOTES = p_NJO_NOTES
             WHERE t.NJO_ID = p_NJO_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження інформації Ознака або чинник функціонування особи/сім'ї
    --====================================================--
    PROCEDURE Save_NSJ_FEATURE_DATA (
        p_NJFD_ID              NSJ_FEATURE_DATA.NJFD_ID%TYPE,
        p_NJFD_NJF             NSJ_FEATURE_DATA.NJFD_NJF%TYPE,
        p_NJFD_NFF             NSJ_FEATURE_DATA.NJFD_NFF%TYPE,
        p_HISTORY_STATUS       NSJ_FEATURE_DATA.HISTORY_STATUS%TYPE,
        p_HS                   NUMBER,
        p_New_Id           OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_NJFD_ID, -1) < 0
        THEN
            INSERT INTO NSJ_FEATURE_DATA (NJFD_ID,
                                          NJFD_NJF,
                                          NJFD_NFF,
                                          HISTORY_STATUS)
                 VALUES (0,
                         p_NJFD_NJF,
                         p_NJFD_NFF,
                         p_HISTORY_STATUS)
              RETURNING NJFD_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_NJFD_ID;

            UPDATE NSJ_FEATURE_DATA t
               SET t.NJFD_ID = p_NJFD_ID,
                   t.NJFD_NJF = p_NJFD_NJF,
                   t.NJFD_NFF = p_NJFD_NFF,
                   t.HISTORY_STATUS = p_HISTORY_STATUS
             WHERE t.NJFD_ID = p_NJFD_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження інформації Дані про залучених осіб щодо обліку надання послуг
    --====================================================--
    PROCEDURE Save_NSJ_INVOLVED_PERSON (
        p_NJI_ID               NSJ_INVOLVED_PERSONS.NJI_ID%TYPE,
        p_NJI_NJA              NSJ_INVOLVED_PERSONS.NJI_NJA%TYPE,
        p_NJI_NJP              NSJ_INVOLVED_PERSONS.NJI_NJP%TYPE,
        p_HISTORY_STATUS       NSJ_INVOLVED_PERSONS.HISTORY_STATUS%TYPE,
        p_HS                   NUMBER,
        p_New_Id           OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_NJI_ID, -1) < 0
        THEN
            INSERT INTO NSJ_INVOLVED_PERSONS (NJI_ID,
                                              NJI_NJA,
                                              NJI_NJP,
                                              HISTORY_STATUS)
                 VALUES (0,
                         p_NJI_NJA,
                         p_NJI_NJP,
                         p_HISTORY_STATUS)
              RETURNING NJI_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_NJI_ID;

            UPDATE NSJ_INVOLVED_PERSONS t
               SET t.NJI_ID = p_NJI_ID,
                   t.NJI_NJA = p_NJI_NJA,
                   t.NJI_NJP = p_NJI_NJP,
                   t.HISTORY_STATUS = p_HISTORY_STATUS
             WHERE t.NJI_ID = p_NJI_ID;
        END IF;
    END;



    --====================================================--
    --========================================================--
    --   Збереження інформації Фахівці, відповідальні за організацію роботи з особою/сім'єю
    --========================================================--
    --====================================================--
    PROCEDURE Save_NSJ_EXPERTS (
        p_NSJ_ID                      NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_NSJ_EXPERTS   IN OUT NOCOPY CMES$SC_JOURNAL.t_NSJ_EXPERTS)
    IS
        l_hs   NUMBER := tools.GetHistSessionCmes;
    BEGIN
        IF p_NSJ_EXPERTS IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_NSJ_EXPERTSS');

        FOR i IN 1 .. p_NSJ_EXPERTS.COUNT
        LOOP
            IF p_NSJ_EXPERTS (i).Deleted = 1
            THEN
                UPDATE NSJ_EXPERTS t
                   SET t.History_Status = 'H', t.nje_hs_del = l_hs
                 WHERE t.NJE_ID = p_NSJ_EXPERTS (i).NJE_ID;
            ELSE
                Save_NSJ_EXPERT (
                    p_NJE_ID           => p_NSJ_EXPERTS (i).NJE_ID,
                    p_NJE_NSJ          => p_NSJ_EXPERTS (i).NJE_NSJ,
                    p_NJE_START_DT     => p_NSJ_EXPERTS (i).NJE_START_DT,
                    p_NJE_FN           => p_NSJ_EXPERTS (i).NJE_FN,
                    p_NJE_MN           => p_NSJ_EXPERTS (i).NJE_MN,
                    p_NJE_LN           => p_NSJ_EXPERTS (i).NJE_LN,
                    p_NJE_PHONE        => p_NSJ_EXPERTS (i).NJE_PHONE,
                    p_NJE_EMAIL        => p_NSJ_EXPERTS (i).NJE_EMAIL,
                    p_NJE_STOP_DT      => p_NSJ_EXPERTS (i).NJE_STOP_DT,
                    p_NJE_NOTES        => p_NSJ_EXPERTS (i).NJE_NOTES,
                    p_HISTORY_STATUS   => 'A', --p_NSJ_EXPERTS(i).HISTORY_STATUS,
                    p_HS               => l_hs,
                    p_New_Id           => p_NSJ_EXPERTS (i).New_Id);
            END IF;
        END LOOP;
    END;

    --====================================================--
    --   Збереження інформації Відомості про членів сім'ї/особу
    --====================================================--
    PROCEDURE Save_NSJ_PERSONS (
        p_NSJ_ID                      NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_NSJ_PERSONS   IN OUT NOCOPY CMES$SC_JOURNAL.t_NSJ_PERSONS)
    IS
        l_hs   NUMBER := tools.GetHistSessionCmes;
    BEGIN
        IF p_NSJ_PERSONS IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_NSJ_PERSONSS');

        FOR i IN 1 .. p_NSJ_PERSONS.COUNT
        LOOP
            IF p_NSJ_PERSONS (i).Deleted = 1
            THEN
                UPDATE NSJ_PERSONS t
                   SET t.History_Status = 'H', t.njp_hs_del = l_hs
                 WHERE t.NJP_ID = p_NSJ_PERSONS (i).NJP_ID;
            ELSE
                Save_NSJ_PERSON (
                    p_NJP_ID             => p_NSJ_PERSONS (i).NJP_ID,
                    p_NJP_NSJ            => p_NSJ_PERSONS (i).NJP_NSJ,
                    p_NJP_TP             => p_NSJ_PERSONS (i).NJP_TP,
                    p_NJP_DT             => p_NSJ_PERSONS (i).NJP_DT,
                    p_NJP_FN             => p_NSJ_PERSONS (i).NJP_FN,
                    p_NJP_MN             => p_NSJ_PERSONS (i).NJP_MN,
                    p_NJP_LN             => p_NSJ_PERSONS (i).NJP_LN,
                    p_NJP_GENDER         => p_NSJ_PERSONS (i).NJP_GENDER,
                    p_NJP_BIRTH_DT       => p_NSJ_PERSONS (i).NJP_BIRTH_DT,
                    p_NJP_AGE            => p_NSJ_PERSONS (i).NJP_AGE,
                    p_NJP_SC             => p_NSJ_PERSONS (i).NJP_SC,
                    p_NJP_RELATION_TP    => p_NSJ_PERSONS (i).NJP_RELATION_TP,
                    p_NJP_IS_DISABLED    => p_NSJ_PERSONS (i).NJP_IS_DISABLED,
                    p_NJP_IS_CAPABLE     => p_NSJ_PERSONS (i).NJP_IS_CAPABLE,
                    p_NJP_WORK_PLACE     => p_NSJ_PERSONS (i).NJP_WORK_PLACE,
                    p_NJP_PHONE          => p_NSJ_PERSONS (i).NJP_PHONE,
                    p_NJP_REG_ADDRESS    => p_NSJ_PERSONS (i).NJP_REG_ADDRESS,
                    p_NJP_FACT_ADDRESS   => p_NSJ_PERSONS (i).NJP_FACT_ADDRESS,
                    p_NJP_NOTES          => p_NSJ_PERSONS (i).NJP_NOTES,
                    p_NJP_NOTES_DT       => p_NSJ_PERSONS (i).NJP_NOTES_DT,
                    p_HISTORY_STATUS     => 'A', --p_NSJ_PERSONS(i).HISTORY_STATUS,
                    p_HS                 => l_hs,
                    p_New_Id             => p_NSJ_PERSONS (i).New_Id);
            END IF;
        END LOOP;
    END;

    --====================================================--
    --   Збереження інформації Ознака або чинник функціонування особи/сім'ї
    --====================================================--
    PROCEDURE Save_NSJ_FEATURE_DATAS (
        p_NSJ_ID                           NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_NJFD_NJF                         NSJ_FEATURE_DATA.NJFD_NJF%TYPE,
        p_NSJ_FEATURE_DATA   IN OUT NOCOPY CMES$SC_JOURNAL.t_NSJ_FEATURE_DATA)
    IS
        l_hs   NUMBER := tools.GetHistSessionCmes;
    BEGIN
        IF p_NSJ_FEATURE_DATA IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_NSJ_FEATURE_DATAS');

        FOR i IN 1 .. p_NSJ_FEATURE_DATA.COUNT
        LOOP
            IF p_NSJ_FEATURE_DATA (i).Deleted = 1
            THEN
                UPDATE NSJ_FEATURE_DATA t
                   SET t.History_Status = 'H'
                 WHERE t.NJFD_ID = p_NSJ_FEATURE_DATA (i).NJFD_ID;
            ELSE
                Save_NSJ_FEATURE_DATA (
                    p_NJFD_ID          => p_NSJ_FEATURE_DATA (i).NJFD_ID,
                    p_NJFD_NJF         => p_NJFD_NJF, --p_NSJ_FEATURE_DATA(i).NJFD_NJF,
                    p_NJFD_NFF         => p_NSJ_FEATURE_DATA (i).NJFD_NFF,
                    p_HISTORY_STATUS   => 'A', --p_NSJ_FEATURE_DATA(i).HISTORY_STATUS,
                    p_HS               => l_hs,
                    p_New_Id           => p_NSJ_FEATURE_DATA (i).New_Id);
            END IF;
        END LOOP;
    END;

    --====================================================--
    --   Збереження інформації Основні ознаки та чинники функціонування особи/сім'ї
    --====================================================--
    PROCEDURE Save_NSJ_FEATURES (
        p_NSJ_ID                       NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_NSJ_FEATURES   IN OUT NOCOPY CMES$SC_JOURNAL.t_NSJ_FEATURES)
    IS
        l_hs             NUMBER := tools.GetHistSessionCmes;
        l_Feature_Data   CMES$SC_JOURNAL.t_NSJ_FEATURE_DATA;
    BEGIN
        IF p_NSJ_FEATURES IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_NSJ_FEATURESS');

        FOR i IN 1 .. p_NSJ_FEATURES.COUNT
        LOOP
            IF p_NSJ_FEATURES (i).Deleted = 1
            THEN
                UPDATE NSJ_FEATURES t
                   SET t.History_Status = 'H', t.njf_hs_del = l_hs
                 WHERE t.NJF_ID = p_NSJ_FEATURES (i).NJF_ID;
            ELSE
                Save_NSJ_FEATURE (
                    p_NJF_ID           => p_NSJ_FEATURES (i).NJF_ID,
                    p_NJF_NSJ          => p_NSJ_ID,
                    p_NJF_DT           => p_NSJ_FEATURES (i).NJF_DT,
                    p_HISTORY_STATUS   => 'A', --p_NSJ_FEATURES(i).HISTORY_STATUS,
                    p_HS               => l_hs,
                    p_New_Id           => p_NSJ_FEATURES (i).New_Id);

                IF p_NSJ_FEATURES (i).Feature_Data IS NOT NULL
                THEN
                    l_Feature_Data :=
                        Parse_FEATURE_DATA (p_NSJ_FEATURES (i).Feature_Data);

                    -- raise_application_error(-20000,  p_NSJ_FEATURES(i).New_Id);
                    --Зберігаємо ознаки
                    Save_NSJ_FEATURE_DATAS (p_NSJ_ID,
                                            p_NSJ_FEATURES (i).New_Id,
                                            l_Feature_Data);
                END IF;
            END IF;
        END LOOP;
    END;

    --====================================================--
    --   Збереження інформації Суб'єкти соціальної роботи, які працюють з особою/сім'єю
    --====================================================--
    PROCEDURE Save_NSJ_SUBJECTS (
        p_NSJ_ID                       NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_NSJ_SUBJECTS   IN OUT NOCOPY CMES$SC_JOURNAL.t_NSJ_SUBJECTS)
    IS
        l_hs   NUMBER := tools.GetHistSessionCmes;
    BEGIN
        IF p_NSJ_SUBJECTS IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_NSJ_SUBJECTSS');

        FOR i IN 1 .. p_NSJ_SUBJECTS.COUNT
        LOOP
            IF p_NSJ_SUBJECTS (i).Deleted = 1
            THEN
                UPDATE NSJ_SUBJECTS t
                   SET t.History_Status = 'H', t.NJS_HS_DEL = l_hs
                 WHERE t.NJS_ID = p_NSJ_SUBJECTS (i).NJS_ID;
            ELSE
                Save_NSJ_SUBJECT (
                    p_NJS_ID            => p_NSJ_SUBJECTS (i).NJS_ID,
                    p_NJS_NSJ           => NVL (p_NSJ_SUBJECTS (i).NJS_NSJ, p_NSJ_ID),
                    p_NJS_DT            => p_NSJ_SUBJECTS (i).NJS_DT,
                    p_NJS_NAME          => p_NSJ_SUBJECTS (i).NJS_NAME,
                    p_NJS_SPEC_FN       => p_NSJ_SUBJECTS (i).NJS_SPEC_FN,
                    p_NJS_SPEC_MN       => p_NSJ_SUBJECTS (i).NJS_SPEC_MN,
                    p_NJS_SPEC_LN       => p_NSJ_SUBJECTS (i).NJS_SPEC_LN,
                    p_NJS_SPEC_PHONE    => p_NSJ_SUBJECTS (i).NJS_SPEC_PHONE,
                    p_NJS_SPEC_EMAIL    => p_NSJ_SUBJECTS (i).NJS_SPEC_EMAIL,
                    p_NJS_PURPOSE       => p_NSJ_SUBJECTS (i).NJS_PURPOSE,
                    p_NJS_ISSUED_DOCS   => p_NSJ_SUBJECTS (i).NJS_ISSUED_DOCS,
                    p_NJS_NOTES         => p_NSJ_SUBJECTS (i).NJS_NOTES,
                    p_HISTORY_STATUS    => 'A', --p_NSJ_SUBJECTS(i).HISTORY_STATUS,
                    p_HS                => l_hs,
                    p_New_Id            => p_NSJ_SUBJECTS (i).New_Id);
            END IF;
        END LOOP;
    END;

    --====================================================--
    --   Збереження інформації Дані обліку надання послуг
    --====================================================--
    PROCEDURE Save_NSJ_ACCOUNTINGS (
        p_NSJ_ID                         NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_NSJ_ACCOUNTING   IN OUT NOCOPY CMES$SC_JOURNAL.t_NSJ_ACCOUNTING)
    IS
        l_hs   NUMBER := tools.GetHistSessionCmes;
    BEGIN
        IF p_NSJ_ACCOUNTING IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_NSJ_ACCOUNTINGS');

        FOR i IN 1 .. p_NSJ_ACCOUNTING.COUNT
        LOOP
            IF p_NSJ_ACCOUNTING (i).Deleted = 1
            THEN
                UPDATE NSJ_ACCOUNTING t
                   SET t.History_Status = 'H', t.NJA_HS_DEL = l_hs
                 WHERE t.NJA_ID = p_NSJ_ACCOUNTING (i).NJA_ID;
            ELSE
                Save_NSJ_ACCOUNTING (
                    p_NJA_ID           => p_NSJ_ACCOUNTING (i).NJA_ID,
                    p_NJA_NSJ          =>
                        NVL (p_NSJ_ACCOUNTING (i).NJA_NSJ, p_NSJ_ID),
                    p_NJA_STAGE        => p_NSJ_ACCOUNTING (i).NJA_STAGE,
                    p_NJA_START_DT     => p_NSJ_ACCOUNTING (i).NJA_START_DT,
                    p_NJA_STOP_DT      => p_NSJ_ACCOUNTING (i).NJA_STOP_DT,
                    p_NJA_FACT         => p_NSJ_ACCOUNTING (i).NJA_FACT,
                    p_NJA_INVOLVED_PERSONS   =>
                        p_NSJ_ACCOUNTING (i).NJA_INVOLVED_PERSONS,
                    p_NJA_NJE          => p_NSJ_ACCOUNTING (i).NJA_NJE,
                    p_NJA_RESULTS      => p_NSJ_ACCOUNTING (i).NJA_RESULTS,
                    p_HISTORY_STATUS   => 'A', --p_NSJ_ACCOUNTING(i).HISTORY_STATUS,
                    p_NJA_NOTES        => p_NSJ_ACCOUNTING (i).NJA_NOTES,
                    p_HS               => l_hs,
                    p_New_Id           => p_NSJ_ACCOUNTING (i).New_Id);
            END IF;
        END LOOP;
    END;

    --====================================================--
    --   Збереження інформації Дані обліку іншої інформації, що стосується особи/сім'ї
    --====================================================--
    PROCEDURE Save_NSJ_OTHER_INFOS (
        p_NSJ_ID                         NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_NSJ_OTHER_INFO   IN OUT NOCOPY CMES$SC_JOURNAL.t_NSJ_OTHER_INFO)
    IS
        l_hs   NUMBER := tools.GetHistSessionCmes;
    BEGIN
        IF p_NSJ_OTHER_INFO IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_NSJ_OTHER_INFOS');

        FOR i IN 1 .. p_NSJ_OTHER_INFO.COUNT
        LOOP
            IF p_NSJ_OTHER_INFO (i).Deleted = 1
            THEN
                UPDATE NSJ_OTHER_INFO t
                   SET t.History_Status = 'H', t.NJO_HS_DEL = l_hs
                 WHERE t.NJO_ID = p_NSJ_OTHER_INFO (i).NJO_ID;
            ELSE
                Save_NSJ_OTHER_INFO (
                    p_NJO_ID           => p_NSJ_OTHER_INFO (i).NJO_ID,
                    p_NJO_NSJ          =>
                        NVL (p_NSJ_OTHER_INFO (i).NJO_NSJ, p_NSJ_ID),
                    p_NJO_DT           => p_NSJ_OTHER_INFO (i).NJO_DT,
                    p_NJO_INFO         => p_NSJ_OTHER_INFO (i).NJO_INFO,
                    p_HISTORY_STATUS   => 'A', --p_NSJ_OTHER_INFO(i).HISTORY_STATUS,
                    p_HS               => l_hs,
                    p_NJO_NOTES        => p_NSJ_OTHER_INFO (i).NJO_NOTES,
                    p_New_Id           => p_NSJ_OTHER_INFO (i).New_Id);
            END IF;
        END LOOP;
    END;


    --====================================================--
    --   Збереження інформації Дані про залучених осіб щодо обліку надання послуг
    --====================================================--
    PROCEDURE Save_NSJ_INVOLVED_PERSONS (
        p_NSJ_ID                               NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_NSJ_INVOLVED_PERSONS   IN OUT NOCOPY CMES$SC_JOURNAL.t_NSJ_INVOLVED_PERSONS)
    IS
        l_hs   NUMBER := tools.GetHistSessionCmes;
    BEGIN
        IF p_NSJ_INVOLVED_PERSONS IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_NSJ_INVOLVED_PERSONSS');

        FOR i IN 1 .. p_NSJ_INVOLVED_PERSONS.COUNT
        LOOP
            IF p_NSJ_INVOLVED_PERSONS (i).Deleted = 1
            THEN
                UPDATE NSJ_INVOLVED_PERSONS t
                   SET t.History_Status = 'H'
                 WHERE t.NJI_ID = p_NSJ_INVOLVED_PERSONS (i).NJI_ID;
            ELSE
                Save_NSJ_INVOLVED_PERSON (
                    p_NJI_ID           => p_NSJ_INVOLVED_PERSONS (i).NJI_ID,
                    p_NJI_NJA          => p_NSJ_INVOLVED_PERSONS (i).NJI_NJA,
                    p_NJI_NJP          => p_NSJ_INVOLVED_PERSONS (i).NJI_NJP,
                    p_HISTORY_STATUS   => 'A', --p_NSJ_INVOLVED_PERSONS(i).HISTORY_STATUS,
                    p_HS               => l_hs,
                    p_New_Id           => p_NSJ_INVOLVED_PERSONS (i).New_Id);
            END IF;
        END LOOP;
    END;


    --====================================================--
    --   Збереження інформації Фахівці, відповідальні за організацію роботи з особою/сім'єю
    --====================================================--
    PROCEDURE Save_NSJ_EXPERTS (p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                p_Xml      IN CLOB)
    IS
        l_Arr   t_NSJ_EXPERTS;
    BEGIN
        l_Arr := Parse_EXPERTS (p_Xml);
        Save_NSJ_EXPERTS (p_NSJ_ID, l_Arr);
    END;

    --====================================================--
    --   Збереження інформації Відомості про членів сім'ї/особу
    --====================================================--
    PROCEDURE Save_NSJ_PERSONSS (p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                 p_Xml      IN CLOB)
    IS
        l_Arr   t_NSJ_PERSONS;
    BEGIN
        l_Arr := Parse_PERSONS (p_Xml);
        Save_NSJ_PERSONS (p_NSJ_ID, l_Arr);
    END;

    --====================================================--
    --   Збереження інформації Основні ознаки та чинники функціонування особи/сім'ї
    --====================================================--
    PROCEDURE Save_NSJ_FEATURES (p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                 p_Xml      IN CLOB)
    IS
        l_Arr   t_NSJ_FEATURES;
    BEGIN
        l_Arr := Parse_FEATURES (p_Xml);
        Save_NSJ_FEATURES (p_NSJ_ID, l_Arr);
    END;

    --====================================================--
    --   Збереження інформації Суб'єкти соціальної роботи, які працюють з особою/сім'єю
    --====================================================--
    PROCEDURE Save_NSJ_SUBJECTS (p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                 p_Xml      IN CLOB)
    IS
        l_Arr   t_NSJ_SUBJECTS;
    BEGIN
        l_Arr := Parse_SUBJECTS (p_Xml);
        Save_NSJ_SUBJECTS (p_NSJ_ID, l_Arr);
    END;

    --====================================================--
    --   Збереження інформації Дані обліку надання послуг
    --====================================================--
    PROCEDURE Save_NSJ_ACCOUNTINGS (p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                    p_Xml      IN CLOB)
    IS
        l_Arr   t_NSJ_ACCOUNTING;
    BEGIN
        l_Arr := Parse_ACCOUNTING (p_Xml);
        Save_NSJ_ACCOUNTINGS (p_NSJ_ID, l_Arr);
    END;

    --====================================================--
    --   Збереження інформації Дані обліку іншої інформації, що стосується особи/сім'ї
    --====================================================--
    PROCEDURE Save_NSJ_OTHER_INFOS (p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                    p_Xml      IN CLOB)
    IS
        l_Arr   t_NSJ_OTHER_INFO;
    BEGIN
        l_Arr := Parse_OTHER_INFO (p_Xml);
        Save_NSJ_OTHER_INFOS (p_NSJ_ID, l_Arr);
    END;

    --====================================================--
    --   Збереження інформації Ознака або чинник функціонування особи/сім'ї
    --====================================================--
    /*
      PROCEDURE Save_NSJ_FEATURE_DATAS(
                    p_NSJ_ID                NSP_SC_JOURNAL.NSJ_ID%TYPE,
                    p_Xml                IN CLOB
                    ) IS
        l_Arr t_NSJ_FEATURE_DATA;
      BEGIN
        l_Arr := Parse_FEATURE_DATA(p_Xml);
        Save_NSJ_FEATURE_DATAS(p_NSJ_ID, l_Arr);
      END;
    */
    --====================================================--
    --   Збереження інформації Дані про залучених осіб щодо обліку надання послуг
    --====================================================--
    PROCEDURE Save_NSJ_INVOLVED_PERSONS (
        p_NSJ_ID      NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_Xml      IN CLOB)
    IS
        l_Arr   t_NSJ_INVOLVED_PERSONS;
    BEGIN
        l_Arr := Parse_INVOLVED_PERSONS (p_Xml);
        Save_NSJ_INVOLVED_PERSONS (p_NSJ_ID, l_Arr);
    END;

    --====================================================--
    --   Отримання інформації по КАТОТТГ
    --====================================================--
    FUNCTION get_katottg_info (p_kaot_id NUMBER)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (4000);
    BEGIN
        SELECT RTRIM (
                      (CASE
                           WHEN l1_name IS NOT NULL AND l1_name != kaot_name
                           THEN
                               l1_name || ', '
                       END)
                   || (CASE
                           WHEN l2_name IS NOT NULL AND l2_name != kaot_name
                           THEN
                               l2_name || ', '
                       END)
                   || (CASE
                           WHEN l3_name IS NOT NULL AND l3_name != kaot_name
                           THEN
                               l3_name || ', '
                       END)
                   || (CASE
                           WHEN l4_name IS NOT NULL AND l4_name != kaot_name
                           THEN
                               l4_name || ', '
                       END)
                   || (CASE
                           WHEN l5_name IS NOT NULL AND l5_name != kaot_name
                           THEN
                               l5_name || ', '
                       END)
                   || name_temp,
                   ',')
          INTO v_res
          FROM (SELECT m.*,
                       (CASE
                            WHEN kaot_kaot_l1 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l1
                                        AND kaot_tp = dic_value)
                        END)                              AS l1_name,
                       (CASE
                            WHEN kaot_kaot_l2 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l2
                                        AND kaot_tp = dic_value)
                        END)                              AS l2_name,
                       (CASE
                            WHEN kaot_kaot_l3 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l3
                                        AND kaot_tp = dic_value)
                        END)                              AS l3_name,
                       (CASE
                            WHEN kaot_kaot_l4 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l4
                                        AND kaot_tp = dic_value)
                        END)                              AS l4_name,
                       (CASE
                            WHEN kaot_kaot_l5 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l5
                                        AND kaot_tp = dic_value)
                        END)                              AS l5_name,
                       t.dic_sname || ' ' || kaot_name    AS name_temp
                  FROM uss_ndi.v_ndi_katottg  m
                       JOIN uss_ndi.v_ddn_kaot_tp t ON t.dic_code = m.kaot_tp
                 WHERE m.kaot_id = p_kaot_id);

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --====================================================--
    --  Отримання інформації по вулиці
    --====================================================--
    FUNCTION get_street_info (p_ns_id NUMBER)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (4000);
    BEGIN
        SELECT    (SELECT nsrt_name || ' '
                     FROM uss_ndi.v_ndi_street_type
                    WHERE ns_nsrt = nsrt_id)
               || ns_name
          INTO v_res
          FROM uss_ndi.v_ndi_street
         WHERE ns_id = p_ns_id;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --====================================================--
    --  Адреса регістрації
    --====================================================--
    FUNCTION get_pers_reg_address (p_ap_id NUMBER, p_app_id NUMBER)
        RETURN VARCHAR2
    IS
        l_address   VARCHAR2 (1000);
    BEGIN
        SELECT RTRIM (
                   (   MAX (
                           CASE
                               WHEN     d.apd_ndt = 605
                                    AND da.apda_nda = 1489
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                   TRIM (da.apda_val_string) || ', '
                           END)
                    || (LTRIM (
                               MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 605
                                            AND da.apda_nda = 1488
                                       THEN
                                           COALESCE (
                                               (CASE
                                                    WHEN da.apda_val_id
                                                             IS NOT NULL
                                                    THEN
                                                        get_katottg_info (
                                                            da.apda_val_id)
                                                END),
                                               da.apda_val_string)
                                   END)
                            || ', ',
                            ', '))
                    || COALESCE (
                           LTRIM (
                                  MAX (
                                      CASE
                                          WHEN     d.apd_ndt = 605
                                               AND da.apda_nda = 1490
                                          THEN
                                              COALESCE (
                                                  (CASE
                                                       WHEN da.apda_val_id
                                                                IS NOT NULL
                                                       THEN
                                                           get_street_info (
                                                               da.apda_val_id)
                                                   END),
                                                  TRIM (da.apda_val_string))
                                      END)
                               || ', ',
                               ', '),
                           MAX (
                               CASE
                                   WHEN     d.apd_ndt = 605
                                        AND da.apda_nda = 1591
                                        AND TRIM (da.apda_val_string)
                                                IS NOT NULL
                                   THEN
                                          'вул. '
                                       || TRIM (da.apda_val_string)
                                       || ', '
                               END))
                    || MAX (
                           CASE
                               WHEN     d.apd_ndt = 605
                                    AND da.apda_nda = 1599
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                      'буд. '
                                   || TRIM (da.apda_val_string)
                                   || ', '
                           END)
                    || MAX (
                           CASE
                               WHEN     d.apd_ndt = 605
                                    AND da.apda_nda = 1605
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                      'корп. '
                                   || TRIM (da.apda_val_string)
                                   || ', '
                           END)
                    || MAX (
                           CASE
                               WHEN     d.apd_ndt = 605
                                    AND da.apda_nda = 1611
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                   'кв. ' || TRIM (da.apda_val_string)
                           END)),
                   ', ')    AS pers_reg_addr
          INTO l_address
          FROM v_ap_document  d
               JOIN v_ap_document_attr da
                   ON     da.apda_apd = d.apd_id
                      AND d.apd_app = p_app_id
                      AND da.apda_ap = d.apd_ap
                      AND da.apda_nda IN (1489,
                                          1488,
                                          1490,
                                          1591,
                                          1599,
                                          1605,
                                          1611)
                      AND da.history_status = 'A'
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = 605
               AND d.history_status = 'A';

        RETURN l_address;
    END;

    --====================================================--
    --  Адреса проживання
    --====================================================--
    FUNCTION get_pers_fact_address (p_ap_id NUMBER, p_app_id NUMBER)
        RETURN VARCHAR2
    IS
        l_address   VARCHAR2 (1000);
    BEGIN
        SELECT RTRIM (
                   (   MAX (
                           CASE
                               WHEN     da.apda_nda = 1625
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                   TRIM (da.apda_val_string) || ', '
                           END)
                    || (LTRIM (
                               MAX (
                                   CASE da.apda_nda
                                       WHEN 1618
                                       THEN
                                           COALESCE (
                                               (CASE
                                                    WHEN da.apda_val_id
                                                             IS NOT NULL
                                                    THEN
                                                        get_katottg_info (
                                                            da.apda_val_id)
                                                END),
                                               da.apda_val_string)
                                   END)
                            || ', ',
                            ', '))
                    || COALESCE (
                           LTRIM (
                                  MAX (
                                      CASE da.apda_nda
                                          WHEN 1632
                                          THEN
                                              COALESCE (
                                                  (CASE
                                                       WHEN da.apda_val_id
                                                                IS NOT NULL
                                                       THEN
                                                           get_street_info (
                                                               da.apda_val_id)
                                                   END),
                                                  TRIM (da.apda_val_string))
                                      END)
                               || ', ',
                               ', '),
                           MAX (
                               CASE
                                   WHEN     da.apda_nda = 1640
                                        AND TRIM (da.apda_val_string)
                                                IS NOT NULL
                                   THEN
                                          'вул. '
                                       || TRIM (da.apda_val_string)
                                       || ', '
                               END))
                    || MAX (
                           CASE
                               WHEN     da.apda_nda = 1648
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                      'буд. '
                                   || TRIM (da.apda_val_string)
                                   || ', '
                           END)
                    || MAX (
                           CASE
                               WHEN     da.apda_nda = 1654
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                      'корп. '
                                   || TRIM (da.apda_val_string)
                                   || ', '
                           END)
                    || MAX (
                           CASE
                               WHEN     da.apda_nda = 1659
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                   'кв. ' || TRIM (da.apda_val_string)
                           END)),
                   ', ')
          INTO l_address
          FROM v_ap_document  d
               JOIN v_ap_document_attr da
                   ON     da.apda_apd = d.apd_id
                      AND d.apd_app = p_app_id
                      AND da.apda_ap = d.apd_ap
                      AND da.apda_nda IN (1618,
                                          1625,
                                          1632,
                                          1640,
                                          1648,
                                          1654,
                                          1659)
                      AND da.history_status = 'A'
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = 605
               AND d.history_status = 'A';

        RETURN l_address;
    END;

    --#109643
    PROCEDURE set_nsj_num (p_nsj_id IN NUMBER, p_mode NUMBER DEFAULT 0)
    IS
        l_n     NUMBER;
        l_mm    VARCHAR2 (2);
        l_yy    VARCHAR2 (2);
        l_g     NUMBER;
        l_num   VARCHAR2 (100);
    BEGIN
        IF (p_mode = 1)
        THEN
            SELECT    SUBSTR (nsj_num, 0, LENGTH (nsj_num) - LENGTH (g_part))
                   || (TO_NUMBER (g_part) + 1)    AS new_num
              INTO l_num
              FROM (SELECT SUBSTR (a.nsj_num, INSTR (a.nsj_num, '-', -1) + 1)
                               AS g_part,
                           nsj_num
                      FROM (SELECT z.nsj_num
                              FROM nsp_sc_journal z
                             WHERE z.nsj_id = p_nsj_id) a) t;

            UPDATE nsp_sc_journal t
               SET t.nsj_num = l_num
             WHERE t.nsj_id = p_nsj_id;

            RETURN;
        END IF;

        SELECT TO_CHAR (t.nsj_start_dt, 'MM'),
               TO_CHAR (t.nsj_start_dt, 'YY'),
               (SELECT MAX (rn)
                  FROM (  SELECT ROW_NUMBER ()
                                     OVER (ORDER BY MIN (z.nsj_start_dt))
                                     AS rn,
                                 z.nsj_sc
                            FROM nsp_sc_journal z
                           WHERE z.nsj_rnspm = t.nsj_rnspm
                        GROUP BY z.nsj_sc) q
                 WHERE q.nsj_sc = t.nsj_sc)    AS n,
               (SELECT COUNT (*)
                  FROM nsp_sc_journal z
                 WHERE     z.nsj_sc = t.nsj_sc
                       AND z.nsj_rnspm = t.nsj_rnspm
                       AND z.nsj_st = 'KN')    AS g
          INTO l_mm,
               l_yy,
               l_n,
               l_g
          FROM nsp_sc_journal t
         WHERE t.nsj_id = p_nsj_id;

        UPDATE nsp_sc_journal t
           SET t.nsj_num =
                      TO_CHAR (l_n)
                   || '-'
                   || l_mm
                   || '-'
                   || l_yy
                   || '-'
                   || TO_CHAR (l_g)
         WHERE t.nsj_id = p_nsj_id;
    END;

    -----------------------------------------------------------
    -- Створення журналу по акту
    -----------------------------------------------------------
    -----------------------------------------------------------
    -- Створення журналу по акту PDSP
    -----------------------------------------------------------
    PROCEDURE Create_SC_JOURNAL (p_at_id act.at_id%TYPE)
    IS
        l_nsj_id   NUMBER (14);
    BEGIN
        SELECT MAX (nsj_id)
          INTO l_nsj_id
          FROM nsp_sc_journal  j
               JOIN act at
                   ON at.at_sc = j.nsj_sc AND at.at_rnspm = j.nsj_rnspm
         WHERE at_id = p_at_id AND j.nsj_st = 'KN';

        IF l_nsj_id IS NOT NULL
        THEN
            set_nsj_num (l_nsj_id, 1);
            RETURN;
        END IF;

        SELECT id_nsp_sc_journal (0) INTO l_nsj_id FROM DUAL;

        INSERT INTO nsp_sc_journal (nsj_id,
                                    nsj_sc,
                                    nsj_rnspm,
                                    nsj_num,
                                    nsj_address,
                                    nsj_phone,
                                    nsj_start_dt,
                                    nsj_start_reason,
                                    --nsj_stop_dt,
                                    --nsj_stop_reason,
                                    nsj_st,
                                    nsj_case_class)
            --#104519
            WITH
                dat
                AS
                    (SELECT MAX (zp.atp_fact_address)     AS adr,
                            MAX (zp.atp_phone)            AS phone,
                            MAX (z.at_case_class)         AS case_class
                       FROM act  q
                            JOIN act z ON (z.at_main_link = q.at_id)
                            JOIN at_person zp ON (zp.atp_at = z.at_id)
                      WHERE     q.at_id = p_at_id
                            AND z.at_tp IN ('APOP', 'OKS', 'ANPOE')
                            AND z.at_St IN ('AS', 'TP', 'XP')
                            AND zp.atp_sc = q.at_sc)
            SELECT l_nsj_id,
                   at.at_sc,
                   at.at_rnspm,
                   l_nsj_id,
                   d.adr,
                   d.phone,
                   TRUNC (SYSDATE),
                      --nvl(at.at_action_start_dt, trunc(SYSDATE)),
                      '№'
                   || at.at_num
                   || ' від '
                   || (SELECT MAX (TO_CHAR (a.atda_val_dt, 'DD.MM.YYYY'))
                         FROM at_document  d
                              JOIN at_document_attr a
                                  ON (a.atda_atd = d.atd_id)
                        WHERE     d.atd_at = at.at_id
                              AND d.atd_ndt = 850
                              AND a.atda_nda = 2934
                              AND a.history_status = 'A'),
                   -- at.at_action_stop_dt,
                   'KN',
                   d.case_class
              FROM act at LEFT JOIN dat d ON (1 = 1)
             WHERE at_id = p_at_id;

        --#109643
        set_nsj_num (l_nsj_id);

        INSERT INTO nsj_persons (njp_id,
                                 njp_nsj,
                                 njp_tp,
                                 njp_dt,
                                 njp_fn,
                                 njp_mn,
                                 njp_ln,
                                 njp_gender,
                                 njp_birth_dt,
                                 njp_age,
                                 njp_sc,
                                 njp_relation_tp,
                                 njp_is_disabled,
                                 njp_is_capable,
                                 njp_work_place,
                                 njp_phone,
                                 njp_reg_address,
                                 njp_fact_address,
                                 njp_notes,
                                 history_status)
            SELECT 0,
                   l_nsj_id,
                   atp.atp_tp,
                   TRUNC (SYSDATE, 'dd'),
                   atp.atp_fn,
                   atp.atp_mn,
                   atp.atp_ln,
                   atp.atp_sex,
                   atp.atp_birth_dt,
                   NVL (
                       TRUNC (
                           MONTHS_BETWEEN (SYSDATE, atp.atp_birth_dt) / 12,
                           0),
                       -1),
                   atp.atp_sc,
                   atp.atp_relation_tp,
                   atp.atp_is_disabled,
                   atp.atp_is_capable,
                   atp.atp_work_place,
                   atp.atp_phone,
                   CMES$SC_JOURNAL.get_pers_reg_address (app.app_ap,
                                                         app.app_id),
                   CMES$SC_JOURNAL.get_pers_fact_address (app.app_ap,
                                                          app.app_id),
                   atp.atp_notes,
                   'A'
              FROM act  at
                   JOIN at_person atp
                       ON atp.atp_at = at.at_id AND atp.history_status = 'A'
                   LEFT JOIN ap_person app
                       ON app.app_ap = at.at_ap AND app.history_status = 'A'
             WHERE atp_at = p_at_id;

        NULL;
    END;

    -----------------------------------------------------------
    -- #104519: Оновлення журналу по акту RSTOPSS
    -----------------------------------------------------------
    PROCEDURE Update_SC_JOURNAL (p_at_id act.at_id%TYPE)
    IS
        l_nsj_id   NUMBER (14);
    BEGIN
        SELECT MAX (nsj_id)
          INTO l_nsj_id
          FROM nsp_sc_journal  j
               JOIN act at
                   ON at.at_sc = j.nsj_sc AND at.at_rnspm = j.nsj_rnspm
         WHERE at_id = p_at_id AND j.nsj_st = 'KN';

        IF l_nsj_id IS NULL
        THEN
            RETURN;
        END IF;
    /*
        UPDATE nsp_sc_journal
        SET (nsj_stop_dt, nsj_stop_reason) =
        (SELECT trunc(SYSDATE),
               '№' || at.at_num || ' від ' ||
                ( SELECT MAX(to_char(a.atda_val_dt, 'DD.MM.YYYY'))
                    FROM at_document d
                    JOIN at_document_attr a ON (a.atda_atd = d.atd_id)
                   WHERE d.atd_at = at.at_id
                     AND d.atd_ndt = 860
                     AND a.atda_nda = 3080
                     AND a.history_status = 'A'
                )
          FROM act at
         WHERE at_id = p_at_id
        )
        WHERE nsj_id = l_nsj_id;*/
    END;

    PROCEDURE Close_SC_JOURNAL (p_nsj_id nsp_sc_journal.nsj_id%TYPE)
    IS
    BEGIN
        UPDATE nsp_sc_journal t
           SET nsj_st = 'KV'
         WHERE t.nsj_id = p_nsj_id;
    END;

    /*
    Створення картки 1005
    При встановленні акту PDSP статусу SA / O.SA, автоматично створювати Картку 1005 у статусі KN «Ведення випадку» і заповнювати дані:
    При встановленні акту PDSP статусу SA / O.SA, створювати Картку 1005 у статусі KN «Ведення випадку»
    і заповнювати дані (недоступні для редагування):
    - СОЦІАЛЬНА КАРТКА СІМ’Ї/ОСОБИ № – не доступні для редагування
    - Особа, якій надаються послуги
    - Місце проживання (адреса)
    - Контактний телефон
    - Розпочато – дата встановлення статусів SA/O.SA
    - Підстава – номер та дата рішення про надання СП
    - Завершено – дата ручного встановлення статусу KV (натискання КМом кнопки «Завершити»)
    - Підстава – номер та дата рішення про припинення надання СП
    - 3. Відомості про членів сім’ї/особу – заповнювати зі звернення (???)
    Всі інші дані КМ вносить вручну
    */
    --====================================================--
    --     Перевірка права по ролі
    --====================================================--
    FUNCTION Is_Role_Assigned (p_Cmes_Owner_Id   IN NUMBER,
                               p_Role            IN VARCHAR2,
                               p_Cu_Id           IN NUMBER DEFAULT NULL)
        RETURN BOOLEAN
    IS
    BEGIN
        IF p_Cu_Id IS NULL
        THEN
            RETURN Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                       p_Cr_Code         => p_Role);
        ELSE
            RETURN Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cu_Id           => p_Cu_Id,
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                       p_Cr_Code         => p_Role);
        END IF;
    END;

    --====================================================--
    --     Перевірка права доступу до журналу
    --====================================================--
    FUNCTION Check_Journal_Access (p_nsj_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Cu_Id       NUMBER;
        l_nsj_Sc      NUMBER;
        l_nsj_Rnspm   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        SELECT j.nsj_Rnspm, j.nsj_Sc
          INTO l_nsj_Rnspm, l_nsj_Sc
          FROM NSP_SC_JOURNAL j
         WHERE j.nsj_id = p_nsj_id;

        --Дозволено доступ до акту, якщо його закріплено за поточним користувачем
        IF l_nsj_Sc = Ikis_Rbm.Tools.Getcusc (l_Cu_Id)
        THEN
            RETURN TRUE;
        END IF;

        --Дозволено доступ до акту, якщо поточний користувач має роль "Уповноважений спеціаліст" в кабінеті надавача за яким закріплено акт
        IF --Is_Role_Assigned(p_Cu_Id => l_Cu_Id, p_Cmes_Owner_Id => l_nsj_Rnspm, p_Role => 'NSP_SPEC')
 --OR Is_Role_Assigned(p_Cu_Id => l_Cu_Id, p_Cmes_Owner_Id => l_nsj_Rnspm, p_Role => 'NSP_ADM')
         Is_Role_Assigned (p_Cu_Id           => l_Cu_Id,
                           p_Cmes_Owner_Id   => l_nsj_Rnspm,
                           p_Role            => 'NSP_CM')
        THEN
            RETURN TRUE;
        END IF;

        RETURN FALSE;
    END;

    --====================================================--
    --
    --====================================================--
    PROCEDURE Get_NSJ_LOG (p_NSJ_ID       NSP_SC_JOURNAL.NSJ_ID%TYPE,
                           p_Res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT t.NJL_ID,
                   t.NJL_NSJ,
                   t.NJL_HS,
                   t.NJL_ST,
                   st1.DIC_SNAME     AS NSJ_ST_NAME,
                   t.NJL_MESSAGE,
                   t.NJL_OLD_ST,
                   st2.DIC_SNAME     AS NJL_OLD_ST_NAME,
                   t.NJL_TP
              FROM NSJ_LOG  t
                   JOIN uss_ndi.V_DDN_NSJ_ST st1 ON st1.DIC_CODE = t.NJL_ST
                   JOIN uss_ndi.V_DDN_NSJ_ST st2
                       ON st2.DIC_CODE = t.NJL_OLD_ST
             WHERE t.NJL_NSJ = p_NSJ_ID;
    END;

    --====================================================--
    PROCEDURE Get_NSP_SC_JOURNAL (p_NSJ_ID       NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                  p_Res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT t.NSJ_ID,
                   --Отримувач
                   t.NSJ_SC,
                   Uss_Person.Api$sc_Tools.Get_Pib (t.NSJ_SC)
                       AS NSJ_Sc_Pib,
                   t.NSJ_RNSPM,
                   t.NSJ_NUM,
                   t.NSJ_ADDRESS,
                   t.NSJ_PHONE,
                   t.NSJ_START_DT,
                   t.NSJ_START_REASON,
                   t.NSJ_STOP_DT,
                   t.NSJ_STOP_REASON,
                   t.NSJ_ST,
                   st.DIC_SNAME
                       AS NSJ_ST_NAME,
                   t.NSJ_CASE_CLASS
              FROM NSP_SC_JOURNAL  t
                   JOIN uss_ndi.V_DDN_NSJ_ST st ON st.DIC_CODE = t.nsj_st
             WHERE t.NSJ_ID = p_NSJ_ID;
    END;

    --====================================================--
    PROCEDURE Get_NSJ_EXPERTS (p_NSJ_ID       NSP_SC_JOURNAL.NSJ_ID%TYPE,
                               p_Res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR SELECT t.NJE_ID,
                              t.NJE_NSJ,
                              t.NJE_START_DT,
                              t.NJE_FN,
                              t.NJE_MN,
                              t.NJE_LN,
                              t.NJE_PHONE,
                              t.NJE_EMAIL,
                              t.NJE_STOP_DT,
                              t.NJE_NOTES,
                              t.HISTORY_STATUS,
                              t.NJE_HS_UPD,
                              t.NJE_HS_DEL
                         FROM NSJ_EXPERTS t
                        WHERE t.NJE_NSJ = p_NSJ_ID AND t.HISTORY_STATUS = 'A';
    END;

    --====================================================--
    PROCEDURE Get_NSJ_PERSONS (p_NSJ_ID       NSP_SC_JOURNAL.NSJ_ID%TYPE,
                               p_Res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT t.NJP_ID,
                   t.NJP_NSJ,
                   t.NJP_TP,
                   t.NJP_DT,
                   t.NJP_FN,
                   t.NJP_MN,
                   t.NJP_LN,
                   t.NJP_GENDER,
                   t.NJP_BIRTH_DT,
                   t.NJP_AGE,
                   t.NJP_SC,
                   t.NJP_RELATION_TP,
                   t.NJP_IS_DISABLED,
                   t.NJP_IS_CAPABLE,
                   t.NJP_WORK_PLACE,
                   t.NJP_PHONE,
                   t.NJP_REG_ADDRESS,
                   t.NJP_FACT_ADDRESS,
                   t.NJP_NOTES,
                   t.NJP_NOTES_DT,
                   t.HISTORY_STATUS,
                   t.NJP_HS_UPD,
                   t.NJP_HS_DEL,
                   Rt.Dic_Name       AS NJP_RELATION_TP_Name,
                   Appt.Dic_Name     AS NJP_TP_Name
              FROM NSJ_PERSONS  t
                   LEFT JOIN Uss_Ndi.v_Ddn_Relation_Tp Rt
                       ON t.NJP_RELATION_TP = Rt.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_App_Tp Appt
                       ON t.NJP_Tp = Appt.Dic_Value
             WHERE t.NJP_NSJ = p_NSJ_ID AND t.HISTORY_STATUS = 'A';
    END;

    --====================================================--
    PROCEDURE Get_NSJ_FEATURES (p_NSJ_ID       NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                p_Res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR SELECT t.NJF_ID,
                              t.NJF_NSJ,
                              t.NJF_DT,
                              t.HISTORY_STATUS,
                              t.NJF_HS_UPD,
                              t.NJF_HS_DEL
                         FROM NSJ_FEATURES t
                        WHERE t.NJF_NSJ = p_NSJ_ID AND t.HISTORY_STATUS = 'A';
    END;

    --====================================================--
    PROCEDURE Get_NSJ_SUBJECTS (p_NSJ_ID       NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                p_Res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR SELECT t.NJS_ID,
                              t.NJS_NSJ,
                              t.NJS_DT,
                              t.NJS_NAME,
                              t.NJS_SPEC_FN,
                              t.NJS_SPEC_MN,
                              t.NJS_SPEC_LN,
                              t.NJS_SPEC_PHONE,
                              t.NJS_SPEC_EMAIL,
                              t.NJS_PURPOSE,
                              t.NJS_ISSUED_DOCS,
                              t.NJS_NOTES,
                              t.HISTORY_STATUS,
                              t.NJS_HS_UPD,
                              t.NJS_HS_DEL
                         FROM NSJ_SUBJECTS t
                        WHERE t.NJS_NSJ = p_NSJ_ID AND t.HISTORY_STATUS = 'A';
    END;

    --====================================================--
    PROCEDURE Get_NSJ_ACCOUNTING (p_NSJ_ID       NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                  p_Res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR SELECT t.NJA_ID,
                              t.NJA_NSJ,
                              t.NJA_STAGE,
                              t.NJA_START_DT,
                              t.NJA_STOP_DT,
                              t.NJA_FACT,
                              t.NJA_INVOLVED_PERSONS,
                              t.NJA_NJE,
                              t.NJA_RESULTS,
                              t.HISTORY_STATUS,
                              t.NJA_HS_UPD,
                              t.NJA_HS_DEL,
                              t.NJA_NOTES
                         FROM NSJ_ACCOUNTING t
                        WHERE t.NJA_NSJ = p_NSJ_ID AND t.HISTORY_STATUS = 'A';
    END;

    --====================================================--
    PROCEDURE Get_NSJ_OTHER_INFO (p_NSJ_ID       NSP_SC_JOURNAL.NSJ_ID%TYPE,
                                  p_Res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT t.NJO_ID,
                   t.NJO_NSJ,
                   t.NJO_DT,
                   t.NJO_INFO,
                   t.HISTORY_STATUS,
                   t.NJO_HS_UPD,
                   t.NJO_HS_DEL,
                   t.NJO_NOTES,
                   --Ким сформовано форму ведення випадку
                   --Посада
                   Api$act.Get_At_Spec_Position (hs.hs_wu, hs.hs_cu, NULL)
                       AS Spec_Position,
                   --15. Прізвище особи, яка сформувала --16. Ім’я особи, яка сформувала --17. По - батькові особи, яка сформувала
                   Api$act.Get_At_Spec_Name (hs.hs_wu, hs.hs_cu)
                       AS Spec_Name
              FROM NSJ_OTHER_INFO  t
                   LEFT JOIN histsession hs ON (hs.hs_id = t.njo_hs_upd)
             WHERE t.NJO_NSJ = p_NSJ_ID AND t.HISTORY_STATUS = 'A';
    END;

    --====================================================--
    PROCEDURE Get_NSJ_FEATURE_DATA (
        p_NSJ_ID       NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_Res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT t.NJFD_ID,
                   t.NJFD_NJF,
                   t.NJFD_NFF,
                   f.nff_sname     AS NJFD_NFF_NAME,
                   f.nff_tp,
                   t.HISTORY_STATUS
              FROM NSJ_FEATURE_DATA  t
                   LEFT JOIN uss_ndi.v_ndi_family_features f
                       ON f.nff_id = t.NJFD_NFF
             WHERE     t.HISTORY_STATUS = 'A'
                   AND EXISTS
                           (SELECT 1
                              FROM NSJ_FEATURES d
                             WHERE     d.NJF_NSJ = p_NSJ_ID
                                   AND t.NJFD_NJF = d.njf_id
                                   AND d.HISTORY_STATUS = 'A');
    END;

    --====================================================--
    PROCEDURE Get_NSJ_INVOLVED_PERSONS (
        p_NSJ_ID       NSP_SC_JOURNAL.NSJ_ID%TYPE,
        p_Res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT t.NJI_ID,
                   t.NJI_NJA,
                   t.NJI_NJP,
                   t.HISTORY_STATUS
              FROM NSJ_INVOLVED_PERSONS t
             WHERE     t.HISTORY_STATUS = 'A'
                   AND EXISTS
                           (SELECT 1
                              FROM NSJ_PERSONS p
                             WHERE     p.NJP_NSJ = p_NSJ_ID
                                   AND p.njp_id = t.nji_njp
                                   AND p.HISTORY_STATUS = 'A');
    END;

    --====================================================--
    -- Соціальної картки сім’ї/особи 1005 в кабінеті КМ
    --====================================================--
    PROCEDURE Get_JOURNAL_Card (
        p_nsj_id                 IN     NUMBER,
        p_NSP_SC_JOURNAL            OUT SYS_REFCURSOR,
        p_NSJ_PERSONS               OUT SYS_REFCURSOR,
        p_NSJ_EXPERTS               OUT SYS_REFCURSOR,
        p_NSJ_FEATURES              OUT SYS_REFCURSOR,
        p_NSJ_FEATURE_DATA          OUT SYS_REFCURSOR,
        p_NSJ_SUBJECTS              OUT SYS_REFCURSOR,
        p_NSJ_ACCOUNTING            OUT SYS_REFCURSOR,
        p_NSJ_OTHER_INFO            OUT SYS_REFCURSOR,
        p_NSJ_INVOLVED_PERSONS      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_JOURNAL_Card');
        Get_NSP_SC_JOURNAL (p_NSJ_ID, p_NSP_SC_JOURNAL);
        Get_NSJ_PERSONS (p_NSJ_ID, p_NSJ_PERSONS);
        Get_NSJ_EXPERTS (p_NSJ_ID, p_NSJ_EXPERTS);
        Get_NSJ_FEATURES (p_NSJ_ID, p_NSJ_FEATURES);
        Get_NSJ_FEATURE_DATA (p_NSJ_ID, p_NSJ_FEATURE_DATA);
        Get_NSJ_SUBJECTS (p_NSJ_ID, p_NSJ_SUBJECTS);
        Get_NSJ_ACCOUNTING (p_NSJ_ID, p_NSJ_ACCOUNTING);
        Get_NSJ_OTHER_INFO (p_NSJ_ID, p_NSJ_OTHER_INFO);
        Get_NSJ_INVOLVED_PERSONS (p_NSJ_ID, p_NSJ_INVOLVED_PERSONS);
    END;

    --====================================================--
    PROCEDURE Get_JOURNAL_LIST (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT t.NSJ_ID,
                   --Отримувач
                   t.NSJ_SC,
                   Uss_Person.Api$sc_Tools.Get_Pib (t.NSJ_SC)
                       AS NSJ_Sc_Pib,
                   t.NSJ_RNSPM,
                   t.NSJ_NUM,
                   t.NSJ_ADDRESS,
                   t.NSJ_PHONE,
                   t.NSJ_START_DT,
                   t.NSJ_START_REASON,
                   t.NSJ_STOP_DT,
                   t.NSJ_STOP_REASON,
                   t.NSJ_ST,
                   st.DIC_SNAME
                       AS NSJ_ST_NAME,
                   t.NSJ_CASE_CLASS
              FROM Tmp_Work_Ids  i
                   JOIN NSP_SC_JOURNAL t ON i.x_Id = t.nsj_id
                   JOIN uss_ndi.V_DDN_NSJ_ST st ON st.DIC_CODE = t.nsj_st;
    END;

    --====================================================--
    -- Перелік Соціальної картки сім’ї/особи 1005 в кабінеті КМ
    --====================================================--
    PROCEDURE Get_JOURNAL_LIST_CM (p_Dt_Start   IN     DATE,
                                   p_Dt_Stop    IN     DATE,
                                   p_Num        IN     VARCHAR2,
                                   p_St         IN     VARCHAR2,
                                   p_Ln         IN     VARCHAR2,
                                   p_Fn         IN     VARCHAR2,
                                   p_Mn         IN     VARCHAR2,
                                   p_sc_id      IN     NUMBER,
                                   p_Res           OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
        l_show    NUMBER;
        l_cnt     NUMBER;
        l_flag    NUMBER
            := CASE
                   WHEN    p_Fn IS NOT NULL
                        OR p_Ln IS NOT NULL
                        OR p_Mn IS NOT NULL
                   THEN
                       1
                   ELSE
                       0
               END;
    BEGIN
        Write_Audit ('Get_JOURNAL_LIST_CM');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        IF (l_flag = 1)
        THEN
            uss_person.api$socialcard.Search_Sc_By_Params (
                p_Inn          => NULL,
                p_Ndt_Id       => NULL,
                p_Doc_Num      => NULL,
                p_Fn           => p_Fn,
                p_Ln           => p_Ln,
                p_Mn           => p_Mn,
                p_Esr_Num      => NULL,
                p_Gender       => NULL,
                p_Show_Modal   => l_show,
                p_Found_Cnt    => l_cnt);
        END IF;

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, які закріплені за поточним користувачем
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT t.nsj_id
              FROM NSP_SC_JOURNAL  t
                   JOIN Ikis_Rbm.v_Cu_Users2roles r
                       ON     t.nsj_rnspm = r.Cu2r_Cmes_Owner_Id
                          AND r.cu2r_cr = 6                              -- КМ
             WHERE     r.Cu2r_Cu = l_Cu_Id
                   --Додаткові фільтри
                   AND t.nsj_start_dt BETWEEN NVL (p_Dt_Start,
                                                   t.nsj_start_dt)
                                          AND NVL (p_Dt_Stop, t.nsj_start_dt)
                   AND t.nsj_num LIKE p_Num || '%'
                   AND t.nsj_St = NVL (p_St, t.nsj_St)
                   AND t.nsj_sc = NVL (p_sc_id, t.nsj_sc)
                   AND (   l_flag = 0
                        OR     l_flag = 1
                           AND t.nsj_sc IN
                                   (SELECT x_id FROM uss_person.Tmp_Work_Ids));


        Get_JOURNAL_LIST (p_Res);
    END;

    --====================================================--

    -- побудова друкованої форми
    PROCEDURE get_form_file (p_nsj_id IN NUMBER, p_blob OUT BLOB)
    IS
    BEGIN
        p_blob := dnet$sc_journal_rpt.SOCIAL_CARD_1005 (p_nsj_id);
    END;

    -- список по зверненню
    PROCEDURE get_nsj_list (p_ap_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.NSJ_ID,
                   --Отримувач
                   t.NSJ_SC,
                   Uss_Person.Api$sc_Tools.Get_Pib (t.NSJ_SC)
                       AS NSJ_Sc_Pib,
                   t.NSJ_RNSPM,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (t.NSJ_RNSPM)
                       AS Nsj_Rnsp_Name,
                   t.NSJ_NUM,
                   --#111654
                   Uss_Person.Api$sc_Tools.Get_Full_Address_Text (t.NSJ_SC,
                                                                  '2')
                       NSJ_ADDRESS,
                   Uss_Person.Api$sc_Tools.get_phone_mob (t.NSJ_SC)
                       NSJ_PHONE,
                   --t.NSJ_ADDRESS,
                   --t.NSJ_PHONE,
                   t.NSJ_START_DT,
                   t.NSJ_START_REASON,
                   t.NSJ_STOP_DT,
                   t.NSJ_STOP_REASON,
                   t.NSJ_ST,
                   st.DIC_SNAME
                       AS NSJ_ST_NAME,
                   t.NSJ_CASE_CLASS
              FROM appeal  a
                   JOIN personalcase pc ON (pc.pc_id = a.ap_pc)
                   JOIN NSP_SC_JOURNAL t ON (t.nsj_sc = pc.pc_sc)
                   JOIN uss_ndi.V_DDN_NSJ_ST st ON st.DIC_CODE = t.nsj_st
             WHERE a.ap_id = p_ap_id;
    END;

    -- картка по зверненню та НСП
    PROCEDURE get_nsj_list_pr (p_ap_id           IN     NUMBER,
                               p_cmes_Owner_Id   IN     NUMBER,
                               res_cur              OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.NSJ_ID,
                   --Отримувач
                   t.NSJ_SC,
                   Uss_Person.Api$sc_Tools.Get_Pib (t.NSJ_SC)
                       AS NSJ_Sc_Pib,
                   t.NSJ_RNSPM,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (t.NSJ_RNSPM)
                       AS Nsj_Rnsp_Name,
                   t.NSJ_NUM,
                   --#111654
                   Uss_Person.Api$sc_Tools.Get_Full_Address_Text (t.NSJ_SC,
                                                                  '2')
                       NSJ_ADDRESS,
                   Uss_Person.Api$sc_Tools.get_phone_mob (t.NSJ_SC)
                       NSJ_PHONE,
                   --t.NSJ_ADDRESS,
                   --t.NSJ_PHONE,
                   t.NSJ_START_DT,
                   t.NSJ_START_REASON,
                   t.NSJ_STOP_DT,
                   t.NSJ_STOP_REASON,
                   t.NSJ_ST,
                   st.DIC_SNAME
                       AS NSJ_ST_NAME,
                   t.NSJ_CASE_CLASS
              FROM appeal  a
                   JOIN personalcase pc ON (pc.pc_id = a.ap_pc)
                   JOIN NSP_SC_JOURNAL t ON (t.nsj_sc = pc.pc_sc)
                   JOIN uss_ndi.V_DDN_NSJ_ST st ON st.DIC_CODE = t.nsj_st
             WHERE a.ap_id = p_ap_id AND t.nsj_rnspm = p_cmes_Owner_Id;
    END;
BEGIN
    NULL;
END CMES$SC_JOURNAL;
/