/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.CMES$ORGANIZATION
IS
    -- Author  : BOGDAN
    -- Created : 13.11.2023 17:18:06
    -- Purpose : API - Кадрове забезпечення надавача соцпослуг

    TYPE r_employee IS RECORD
    (
        Em_Id             NUMBER (14),                         --ІД працівника
        Em_Ln             VARCHAR2 (100),                           --Прізвище
        Em_Fn             VARCHAR2 (50),                                --Ім'я
        Em_Mn             VARCHAR2 (100),                        --По батькові
        Em_Birthday_Dt    DATE,                              --День народження
        Em_Iin            VARCHAR2 (12),                              --РНОКПП
        Em_Gender         VARCHAR2 (10),                               --стать
        Em_Start_dt       DATE,                   --дата призначення на посаду
        Em_Stop_Dt        DATE,                     --дата звільнення з посади
        --History_Status   VARCHAR2(10), --Актуальність
        New_Id            NUMBER (14)
    );

    TYPE r_em_training IS RECORD
    (
        Emt_Id            NUMBER (14),                             --Ід запису
        Emt_Em            NUMBER (14),                         --ІД працівника
        Emt_Tp            VARCHAR2 (10),                        --тип навчання
        Emt_Form          VARCHAR2 (10),   --форма навчання  Дистанційно, Очно
        Emt_Topic         VARCHAR2 (250),                        --Тема заходу
        Emt_Amounttime    NUMBER (10),                        --Кількість часу
        Emt_Doc_Tp        VARCHAR2 (10),            --Тип документа про освіту
        Emt_Doc_Dt        DATE,                        --дата видачі документу
        Emt_Doc_Num       VARCHAR2 (100),                    --номер документу
        --HISTORY_STATUS    VARCHAR2(10), --Актуальність
        Deleted           NUMBER
    --New_Id           NUMBER(14)
    );

    TYPE t_em_training IS TABLE OF r_em_training;

    TYPE r_em_supervision IS RECORD
    (
        Emv_Id         NUMBER (14),                                --Ід запису
        Emv_Em         NUMBER (14),                            --ІД працівника
        Emv_Date_Dt    DATE,                                --дата проходження
        Emv_Place      VARCHAR2 (250),                     --місце проходження
        Emv_Topic      VARCHAR2 (250),                           --Тема заходу
        Deleted        NUMBER
    );

    TYPE t_em_supervision IS TABLE OF r_em_supervision;

    TYPE r_em_staff IS RECORD
    (
        Emf_Id              NUMBER (14),                           --Ід запису
        Emf_Ost             NUMBER (14),                  --id штатної одиниці
        Emf_Em              NUMBER (14),                       --ІД працівника
        Emf_Subcontract     VARCHAR2 (10),           --Договір підряду  так/ні
        Emf_Servcontract    VARCHAR2 (10),    --Договір надання послуг  так/ні
        Emf_Oss             NUMBER (14),                    --id спеціалізації
        Deleted             NUMBER
    );

    TYPE t_em_staff IS TABLE OF r_em_staff;

    TYPE r_em_service IS RECORD
    (
        Ems_Id     NUMBER (14),                                    --Ід запису
        Ems_Em     NUMBER (14),                                --ІД працівника
        Ems_Nst    NUMBER (14),                              --Ід соц. послуги
        Deleted    NUMBER
    );

    TYPE t_em_service IS TABLE OF r_em_service;

    TYPE r_em_education IS RECORD
    (
        Eme_Id         NUMBER (14),                                --Ід запису
        Eme_Em         NUMBER (14),                            --ІД працівника
        Eme_Ose        NUMBER (14),                          --id рівня освіти
        Eme_Doc_Num    VARCHAR2 (50),             --номер документа про освіту
        Eme_Doc_Dt     DATE,                --дата видачі документа про освіту
        Eme_Name       VARCHAR2 (250),                            --назва вузу
        Deleted        NUMBER
    );

    TYPE t_em_education IS TABLE OF r_em_education;

    -------------------------------------------------------
    ---                     ОРГСТРУКТУРА
    -------------------------------------------------------

    -- Список оргструктури НСП
    PROCEDURE GET_OS_LIST (p_OS_RNSPM IN NUMBER, p_res OUT SYS_REFCURSOR);

    -- Картка оргструктури
    PROCEDURE GET_OS_CARD (p_os_id   IN     ORGSTRUCTURE.OS_ID%TYPE,
                           p_res        OUT SYS_REFCURSOR);

    -- Зберегти оргструктуру НСП
    PROCEDURE SET_OS_CARD (
        p_OS_ID           IN     ORGSTRUCTURE.OS_ID%TYPE,
        p_OS_OS           IN     ORGSTRUCTURE.OS_OS%TYPE,
        p_OS_NAME         IN     ORGSTRUCTURE.OS_NAME%TYPE,
        p_OS_SHORT_NAME   IN     ORGSTRUCTURE.OS_SHORT_NAME%TYPE,
        p_OS_ADDRESS      IN     ORGSTRUCTURE.OS_ADDRESS%TYPE,
        p_OS_PHONE        IN     ORGSTRUCTURE.OS_PHONE%TYPE,
        p_OS_TP           IN     ORGSTRUCTURE.OS_TP%TYPE,
        p_OS_RNSPM        IN     ORGSTRUCTURE.OS_RNSPM%TYPE,
        p_new_id             OUT ORGSTRUCTURE.OS_ID%TYPE);

    -- Видалити оргструктуру НСП
    PROCEDURE DELETE_OS_CARD (p_os_id ORGSTRUCTURE.OS_ID%TYPE);

    -------------------------------------------------------
    ---                Штатний розклад
    -------------------------------------------------------

    -- Список штатного розкладу за НСП
    PROCEDURE GET_OST_LIST (p_rnspm_id IN NUMBER, p_res OUT SYS_REFCURSOR);

    -- Картка штатного розкладу за НСП
    PROCEDURE GET_OST_CARD (p_ost_id   IN     OS_STAFF.OST_ID%TYPE,
                            p_res         OUT SYS_REFCURSOR);

    -- Зберегти штатний розклад НСП
    PROCEDURE SET_OST_CARD (p_OST_ID    IN     OS_STAFF.OST_ID%TYPE,
                            p_OST_CNT   IN     OS_STAFF.OST_CNT%TYPE,
                            p_OST_OS    IN     OS_STAFF.OST_OS%TYPE,
                            p_OST_OSP   IN     OS_STAFF.OST_OSP%TYPE,
                            p_new_id       OUT OS_STAFF.OST_ID%TYPE);

    -- Видалити штатний розклад за НСП
    PROCEDURE DELETE_OST_CARD (p_ost_id OS_STAFF.OST_ID%TYPE);

    -------------------------------------------------------
    ---                 Працівник
    -------------------------------------------------------

    -- Список працівників НСП
    PROCEDURE GET_EMPLOYEE_LIST (p_rnspm_id   IN     NUMBER,
                                 p_res           OUT SYS_REFCURSOR);

    -- Картка працівника НСП
    PROCEDURE GET_EMPLOYEE_CARD (p_em_id           IN     EMPLOEE.EM_ID%TYPE,
                                 p_emp_cur            OUT SYS_REFCURSOR,
                                 p_em_staff_cur       OUT SYS_REFCURSOR,
                                 p_em_serv_cur        OUT SYS_REFCURSOR,
                                 p_em_train_cur       OUT SYS_REFCURSOR,
                                 p_em_edu_cur         OUT SYS_REFCURSOR,
                                 p_em_superv_cur      OUT SYS_REFCURSOR);

    -- Картка працівника НСП, збереження
    PROCEDURE SET_EMPLOYEE_CARD (p_emp_xml         IN     CLOB,
                                 p_em_staff_xml    IN     CLOB,
                                 p_em_serv_xml     IN     CLOB,
                                 p_em_train_xml    IN     CLOB,
                                 p_em_edu_xml      IN     CLOB,
                                 p_em_superv_xml   IN     CLOB,
                                 p_new_id             OUT NUMBER);

    -- Видалити картку працівника
    PROCEDURE DELETE_EMPLOYEE (p_em_id EMPLOEE.EM_ID%TYPE);
END CMES$ORGANIZATION;
/


GRANT EXECUTE ON USS_RNSP.CMES$ORGANIZATION TO II01RC_USS_RNSP_PORTAL
/


/* Formatted on 8/12/2025 5:58:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.CMES$ORGANIZATION
IS
    Pkg   VARCHAR2 (50) := 'CMES$ORGANIZATION';

    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    PROCEDURE LOG (p_src VARCHAR2, --p_obj_tp         VARCHAR2,
                                   --p_obj_id         NUMBER,
                                   p_regular_params VARCHAR2)
    IS
        l_Cu_Id   NUMBER;
        l_Sc_Id   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        BEGIN
            l_Sc_Id := Ikis_Rbm.Tools.GetCuSc (l_Cu_Id);
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        tools.LOG (
            Pkg || '.' || UPPER (p_src),
            NULL,                                                  --p_obj_tp,
            NULL,                                                  --p_obj_id,
               'cu_Id='
            || l_Cu_Id
            || CHR (13)
            || CHR (10)
            || 'sc_Id='
            || l_Sc_Id
            || CHR (13)
            || CHR (10)
            || p_regular_params);
    END;

    -------------------------------------------------------
    ---                     ОРГСТРУКТУРА
    -------------------------------------------------------

    -- Список оргструктури НСП
    PROCEDURE GET_OS_LIST (p_OS_RNSPM IN NUMBER, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('GET_OS_LIST');

        OPEN p_res FOR
            SELECT t.*
              FROM ORGSTRUCTURE t
             WHERE t.os_rnspm = p_os_rnspm AND t.history_status = 'A';
    END;

    -- Картка оргструктури
    PROCEDURE GET_OS_CARD (p_os_id   IN     ORGSTRUCTURE.OS_ID%TYPE,
                           p_res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('GET_OS_CARD');

        OPEN p_res FOR
            SELECT t.*, tp.DIC_NAME AS os_tp_name
              FROM ORGSTRUCTURE  t
                   JOIN uss_ndi.v_ddn_os_tp tp ON (tp.DIC_VALUE = t.os_tp)
             WHERE OS_ID = p_os_id;
    END;

    -- Зберегти оргструктуру НСП
    PROCEDURE SET_OS_CARD (
        p_OS_ID           IN     ORGSTRUCTURE.OS_ID%TYPE,
        p_OS_OS           IN     ORGSTRUCTURE.OS_OS%TYPE,
        p_OS_NAME         IN     ORGSTRUCTURE.OS_NAME%TYPE,
        p_OS_SHORT_NAME   IN     ORGSTRUCTURE.OS_SHORT_NAME%TYPE,
        p_OS_ADDRESS      IN     ORGSTRUCTURE.OS_ADDRESS%TYPE,
        p_OS_PHONE        IN     ORGSTRUCTURE.OS_PHONE%TYPE,
        p_OS_TP           IN     ORGSTRUCTURE.OS_TP%TYPE,
        p_OS_RNSPM        IN     ORGSTRUCTURE.OS_RNSPM%TYPE,
        p_new_id             OUT ORGSTRUCTURE.OS_ID%TYPE)
    IS
    BEGIN
        Write_Audit ('SET_OS_CARD');

        IF p_OS_ID IS NULL
        THEN
            INSERT INTO ORGSTRUCTURE (OS_OS,
                                      OS_NAME,
                                      HISTORY_STATUS,
                                      OS_SHORT_NAME,
                                      OS_ADDRESS,
                                      OS_PHONE,
                                      OS_TP,
                                      OS_RNSPM)
                 VALUES (p_OS_OS,
                         p_OS_NAME,
                         'A',
                         p_OS_SHORT_NAME,
                         p_OS_ADDRESS,
                         p_OS_PHONE,
                         p_OS_TP,
                         p_OS_RNSPM)
              RETURNING OS_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_OS_ID;

            UPDATE ORGSTRUCTURE
               SET OS_OS = p_OS_OS,
                   OS_NAME = p_OS_NAME,
                   OS_SHORT_NAME = p_OS_SHORT_NAME,
                   OS_ADDRESS = p_OS_ADDRESS,
                   OS_PHONE = p_OS_PHONE,
                   OS_TP = p_OS_TP
             WHERE OS_ID = p_OS_ID;
        END IF;
    END;

    -- Видалити оргструктуру НСП
    PROCEDURE DELETE_OS_CARD (p_os_id ORGSTRUCTURE.OS_ID%TYPE)
    IS
    BEGIN
        Write_Audit ('DELETE_OS_CARD');

        UPDATE ORGSTRUCTURE t
           SET t.history_status = 'H'
         WHERE OS_ID = p_os_id;
    END;

    -------------------------------------------------------
    ---                Штатний розклад
    -------------------------------------------------------


    -- Список штатного розкладу за НСП
    PROCEDURE GET_OST_LIST (p_rnspm_id IN NUMBER, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('GET_OST_LIST');

        OPEN p_res FOR
            SELECT t.*, s.os_name AS ost_os_name, p.osp_name AS ost_osp_name
              FROM OS_STAFF  t
                   JOIN orgstructure s ON (s.os_id = t.ost_os)
                   JOIN uss_ndi.v_ndi_os_position p ON (p.osp_id = t.ost_osp)
             WHERE s.os_rnspm = p_rnspm_id AND t.history_status = 'A';
    END;

    -- Картка штатного розкладу за НСП
    PROCEDURE GET_OST_CARD (p_ost_id   IN     OS_STAFF.OST_ID%TYPE,
                            p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('GET_OST_CARD');

        OPEN p_res FOR
            SELECT t.*, s.os_name AS ost_os_name, p.osp_name AS ost_osp_name
              FROM OS_STAFF  t
                   JOIN orgstructure s ON (s.os_id = t.ost_os)
                   JOIN uss_ndi.v_ndi_os_position p ON (p.osp_id = t.ost_osp)
             WHERE t.ost_id = p_ost_id;
    END;

    -- Зберегти штатний розклад НСП
    PROCEDURE SET_OST_CARD (p_OST_ID    IN     OS_STAFF.OST_ID%TYPE,
                            p_OST_CNT   IN     OS_STAFF.OST_CNT%TYPE,
                            p_OST_OS    IN     OS_STAFF.OST_OS%TYPE,
                            p_OST_OSP   IN     OS_STAFF.OST_OSP%TYPE,
                            p_new_id       OUT OS_STAFF.OST_ID%TYPE)
    IS
    BEGIN
        Write_Audit ('SET_OST_CARD');

        IF p_OST_ID IS NULL
        THEN
            INSERT INTO OS_STAFF (HISTORY_STATUS,
                                  OST_CNT,
                                  OST_OS,
                                  OST_OSP)
                 VALUES ('A',
                         p_OST_CNT,
                         p_OST_OS,
                         p_OST_OSP)
              RETURNING OST_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_OST_ID;

            UPDATE OS_STAFF
               SET OST_CNT = p_OST_CNT,
                   OST_OS = p_OST_OS,
                   OST_OSP = p_OST_OSP
             WHERE OST_ID = p_OST_ID;
        END IF;
    END;

    -- Видалити штатний розклад за НСП
    PROCEDURE DELETE_OST_CARD (p_ost_id OS_STAFF.OST_ID%TYPE)
    IS
    BEGIN
        Write_Audit ('DELETE_OST_CARD');

        UPDATE OS_STAFF t
           SET t.history_status = 'H'
         WHERE OST_ID = p_ost_id;
    END;

    -------------------------------------------------------
    ---                 Працівник
    -------------------------------------------------------

    --====================================================--
    --   Парсинг
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
    --   Парсинг Працівника
    --====================================================--
    FUNCTION Parse_Employee (p_Xml IN CLOB)
        RETURN cmes$organization.r_employee
    IS
        l_Result   cmes$organization.r_employee;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('R_EMPLOYEE')
            INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу працівника: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    --   Парсинг навчання працівника
    --====================================================--
    FUNCTION Parse_Training (p_Xml IN CLOB)
        RETURN cmes$organization.t_em_training
    IS
        l_Result   cmes$organization.t_em_training;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('T_EM_TRAINING')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу навчання працівника: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    --   Парсинг супервізій працівника
    --====================================================--
    FUNCTION Parse_Supervision (p_Xml IN CLOB)
        RETURN cmes$organization.t_em_supervision
    IS
        l_Result   cmes$organization.t_em_supervision;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('T_EM_SUPERVISION')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу супервізій працівника: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    --   Парсинг ШО працівника
    --====================================================--
    FUNCTION Parse_Staff (p_Xml IN CLOB)
        RETURN cmes$organization.t_em_staff
    IS
        l_Result   cmes$organization.t_em_staff;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('T_EM_STAFF')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу ШО працівника: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    --   Парсинг послуг працівника
    --====================================================--
    FUNCTION Parse_Service (p_Xml IN CLOB)
        RETURN cmes$organization.t_em_service
    IS
        l_Result   cmes$organization.t_em_service;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('T_EM_SERVICE')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу послуг працівника: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    --   Парсинг освіти працівника
    --====================================================--
    FUNCTION Parse_Education (p_Xml IN CLOB)
        RETURN cmes$organization.t_em_education
    IS
        l_Result   cmes$organization.t_em_education;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('T_EM_EDUCATION')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу освіти працівника: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -- Збереження працівника
    PROCEDURE SET_EMPLOYEE (p_epmloyee       cmes$organization.r_employee,
                            p_new_id     OUT NUMBER)
    IS
    BEGIN
        IF p_epmloyee.Em_Id IS NULL
        THEN
            INSERT INTO EMPLOEE (EM_LN,
                                 EM_FN,
                                 EM_MN,
                                 EM_BIRTHDAY_DT,
                                 EM_IIN,
                                 EM_GENDER,
                                 EM_START_DT,
                                 EM_STOP_DT,
                                 HISTORY_STATUS)
                 VALUES (p_epmloyee.EM_LN,
                         p_epmloyee.EM_FN,
                         p_epmloyee.EM_MN,
                         p_epmloyee.EM_BIRTHDAY_DT,
                         p_epmloyee.EM_IIN,
                         p_epmloyee.EM_GENDER,
                         p_epmloyee.EM_START_DT,
                         p_epmloyee.EM_STOP_DT,
                         'A')
              RETURNING EM_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_epmloyee.EM_ID;

            UPDATE EMPLOEE
               SET EM_LN = p_epmloyee.EM_LN,
                   EM_FN = p_epmloyee.EM_FN,
                   EM_MN = p_epmloyee.EM_MN,
                   EM_BIRTHDAY_DT = p_epmloyee.EM_BIRTHDAY_DT,
                   EM_IIN = p_epmloyee.EM_IIN,
                   EM_GENDER = p_epmloyee.EM_GENDER,
                   EM_START_DT = p_epmloyee.EM_START_DT,
                   EM_STOP_DT = p_epmloyee.EM_STOP_DT
             WHERE EM_ID = p_epmloyee.EM_ID;
        END IF;
    END;

    -- Збереження навчання працівника
    PROCEDURE SET_EM_TRAINING (
        p_em_id         IN NUMBER,
        p_em_training      cmes$organization.r_em_training)
    IS
    BEGIN
        IF p_em_training.EMT_ID IS NULL OR p_em_training.Emt_Id < 0
        THEN
            INSERT INTO EM_TRAINING (EMT_EM,
                                     EMT_TP,
                                     EMT_FORM,
                                     EMT_TOPIC,
                                     EMT_AMOUNTTIME,
                                     EMT_DOC_TP,
                                     EMT_DOC_DT,
                                     EMT_DOC_NUM,
                                     HISTORY_STATUS)
                 VALUES (p_em_id,
                         p_em_training.EMT_TP,
                         p_em_training.EMT_FORM,
                         p_em_training.EMT_TOPIC,
                         p_em_training.EMT_AMOUNTTIME,
                         p_em_training.EMT_DOC_TP,
                         p_em_training.EMT_DOC_DT,
                         p_em_training.EMT_DOC_NUM,
                         'A');
        ELSE
            UPDATE EM_TRAINING
               SET EMT_TP = p_em_training.EMT_TP,
                   EMT_FORM = p_em_training.EMT_FORM,
                   EMT_TOPIC = p_em_training.EMT_TOPIC,
                   EMT_AMOUNTTIME = p_em_training.EMT_AMOUNTTIME,
                   EMT_DOC_TP = p_em_training.EMT_DOC_TP,
                   EMT_DOC_DT = p_em_training.EMT_DOC_DT,
                   EMT_DOC_NUM = p_em_training.EMT_DOC_NUM
             WHERE EMT_ID = p_em_training.EMT_ID;
        END IF;
    END;

    -- Збереження супервізії працівника
    PROCEDURE SET_EM_SUPERVISION (
        p_em_id            IN NUMBER,
        p_em_supervision      cmes$organization.r_em_supervision)
    IS
    BEGIN
        IF p_em_supervision.Emv_Id IS NULL OR p_em_supervision.Emv_Id < 0
        THEN
            INSERT INTO EM_SUPERVISION (EMV_EM,
                                        EMV_DATE_DT,
                                        EMV_PLACE,
                                        EMV_TOPIC,
                                        HISTORY_STATUS)
                 VALUES (p_em_id,
                         p_em_supervision.EMV_DATE_DT,
                         p_em_supervision.EMV_PLACE,
                         p_em_supervision.EMV_TOPIC,
                         'A');
        ELSE
            UPDATE EM_SUPERVISION
               SET EMV_DATE_DT = p_em_supervision.EMV_DATE_DT,
                   EMV_PLACE = p_em_supervision.EMV_PLACE,
                   EMV_TOPIC = p_em_supervision.EMV_TOPIC
             WHERE EMV_ID = p_em_supervision.EMV_ID;
        END IF;
    END;

    -- Збереження ШО працівника
    PROCEDURE SET_EM_STAFF (p_em_id      IN NUMBER,
                            p_em_staff      cmes$organization.r_em_staff)
    IS
    BEGIN
        IF p_em_staff.EMF_ID IS NULL
        THEN
            INSERT INTO EM_STAFF (EMF_OST,
                                  EMF_EM,
                                  EMF_SUBCONTRACT,
                                  EMF_SERVCONTRACT,
                                  EMF_OSS,
                                  HISTORY_STATUS)
                 VALUES (p_em_staff.EMF_OST,
                         p_em_id,
                         p_em_staff.EMF_SUBCONTRACT,
                         p_em_staff.EMF_SERVCONTRACT,
                         p_em_staff.EMF_OSS,
                         'A');
        ELSE
            UPDATE EM_STAFF
               SET EMF_OST = p_em_staff.EMF_OST,
                   EMF_SUBCONTRACT = p_em_staff.EMF_SUBCONTRACT,
                   EMF_SERVCONTRACT = p_em_staff.EMF_SERVCONTRACT,
                   EMF_OSS = p_em_staff.EMF_OSS
             WHERE EMF_ID = p_em_staff.EMF_ID;
        END IF;
    END;

    -- Збереження послуги до якої залучено працівника
    PROCEDURE SET_EM_SERVICE (
        p_em_id        IN NUMBER,
        p_em_service      cmes$organization.r_em_service)
    IS
    BEGIN
        IF p_em_service.Ems_Id IS NULL OR p_em_service.Ems_Id < 0
        THEN
            INSERT INTO EM_SERVICE (EMS_EM, EMS_NST, HISTORY_STATUS)
                 VALUES (p_em_id, p_em_service.EMS_NST, 'A');
        ELSE
            UPDATE EM_SERVICE
               SET EMS_NST = p_em_service.EMS_NST
             WHERE EMS_ID = p_em_service.EMS_ID;
        END IF;
    END;

    -- Збереження освіти працівника
    PROCEDURE SET_EM_EDUCATION (
        p_em_id          IN NUMBER,
        p_em_education      cmes$organization.r_em_education)
    IS
    BEGIN
        IF p_em_education.Eme_Id IS NULL OR p_em_education.Eme_Id < 0
        THEN
            INSERT INTO EM_EDUCATION (EME_EM,
                                      EME_OSE,
                                      EME_DOC_NUM,
                                      EME_DOC_DT,
                                      EME_NAME,
                                      HISTORY_STATUS)
                 VALUES (p_em_id,
                         p_em_education.EME_OSE,
                         p_em_education.EME_DOC_NUM,
                         p_em_education.EME_DOC_DT,
                         p_em_education.EME_NAME,
                         'A');
        ELSE
            UPDATE EM_EDUCATION
               SET EME_OSE = p_em_education.EME_OSE,
                   EME_DOC_NUM = p_em_education.EME_DOC_NUM,
                   EME_DOC_DT = p_em_education.EME_DOC_DT,
                   EME_NAME = p_em_education.EME_NAME
             WHERE EME_ID = p_em_education.EME_ID;
        END IF;
    END;

    -- Збереження списку навчань працівника
    PROCEDURE SET_EM_TRAININGS (
        p_em_id         IN NUMBER,
        p_em_training      cmes$organization.t_em_training)
    IS
    BEGIN
        IF (p_em_training.COUNT = 0)
        THEN
            RETURN;
        END IF;

        FOR xx IN p_em_training.FIRST () .. p_em_training.LAST ()
        LOOP
            IF (p_em_training (xx).deleted = 1)
            THEN
                UPDATE em_training t
                   SET t.history_status = 'H'
                 WHERE t.emt_id = p_em_training (xx).emt_id;

                CONTINUE;
            END IF;

            SET_EM_TRAINING (p_em_id, p_em_training (xx));
        END LOOP;
    END;

    -- Збереження списку супервізій працівника
    PROCEDURE SET_EM_SUPERVISIONS (
        p_em_id            IN NUMBER,
        p_em_supervision      cmes$organization.t_em_supervision)
    IS
    BEGIN
        IF (p_em_supervision.COUNT = 0)
        THEN
            RETURN;
        END IF;

        FOR xx IN p_em_supervision.FIRST () .. p_em_supervision.LAST ()
        LOOP
            IF (p_em_supervision (xx).deleted = 1)
            THEN
                UPDATE em_supervision t
                   SET t.history_status = 'H'
                 WHERE t.emv_id = p_em_supervision (xx).emv_id;

                CONTINUE;
            END IF;

            SET_EM_SUPERVISION (p_em_id, p_em_supervision (xx));
        END LOOP;
    END;

    -- Збереження ШО працівника
    PROCEDURE SET_EM_STAFFS (p_em_id      IN NUMBER,
                             p_em_staff      cmes$organization.t_em_staff)
    IS
    BEGIN
        IF (p_em_staff.COUNT = 0)
        THEN
            RETURN;
        END IF;

        FOR xx IN p_em_staff.FIRST () .. p_em_staff.LAST ()
        LOOP
            IF (p_em_staff (xx).deleted = 1)
            THEN
                UPDATE em_staff t
                   SET t.history_status = 'H'
                 WHERE t.emf_id = p_em_staff (xx).emf_id;

                CONTINUE;
            END IF;

            SET_EM_STAFF (p_em_id, p_em_staff (xx));
        END LOOP;
    END;

    -- Збереження послуг до яких залучено працівника
    PROCEDURE SET_EM_SERVICES (
        p_em_id         IN NUMBER,
        p_em_services      cmes$organization.t_em_service)
    IS
    BEGIN
        IF (p_em_services.COUNT = 0)
        THEN
            RETURN;
        END IF;

        FOR xx IN p_em_services.FIRST () .. p_em_services.LAST ()
        LOOP
            IF (p_em_services (xx).deleted = 1)
            THEN
                UPDATE em_service t
                   SET t.history_status = 'H'
                 WHERE t.ems_id = p_em_services (xx).ems_id;

                CONTINUE;
            END IF;

            SET_EM_SERVICE (p_em_id, p_em_services (xx));
        END LOOP;
    END;

    -- Збереження освіти працівника
    PROCEDURE SET_EM_EDUCATIONS (
        p_em_id           IN NUMBER,
        p_em_educations      cmes$organization.t_em_education)
    IS
    BEGIN
        IF (p_em_educations.COUNT = 0)
        THEN
            RETURN;
        END IF;

        FOR xx IN p_em_educations.FIRST () .. p_em_educations.LAST ()
        LOOP
            IF (p_em_educations (xx).deleted = 1)
            THEN
                UPDATE em_education t
                   SET t.history_status = 'H'
                 WHERE t.eme_id = p_em_educations (xx).eme_id;

                CONTINUE;
            END IF;

            SET_EM_EDUCATION (p_em_id, p_em_educations (xx));
        END LOOP;
    END;



    -- Список працівників НСП
    PROCEDURE GET_EMPLOYEE_LIST (p_rnspm_id   IN     NUMBER,
                                 p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('GET_EMPLOYEE_LIST');

        OPEN p_res FOR
            SELECT t.*, f.*
              FROM EMPLOEE  t
                   JOIN em_staff f ON (f.emf_em = t.em_id)
                   JOIN os_staff ost ON (ost.ost_id = f.emf_ost)
                   JOIN orgstructure s ON (s.os_id = ost.ost_os)
             WHERE s.os_rnspm = p_rnspm_id AND t.history_status = 'A';
    END;

    -- Картка працівника НСП
    PROCEDURE GET_EMPLOYEE_CARD (p_em_id           IN     EMPLOEE.EM_ID%TYPE,
                                 p_emp_cur            OUT SYS_REFCURSOR,
                                 p_em_staff_cur       OUT SYS_REFCURSOR,
                                 p_em_serv_cur        OUT SYS_REFCURSOR,
                                 p_em_train_cur       OUT SYS_REFCURSOR,
                                 p_em_edu_cur         OUT SYS_REFCURSOR,
                                 p_em_superv_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('GET_EMPLOYEE_CARD');

        OPEN p_emp_cur FOR
            SELECT t.*, g.DIC_NAME AS em_gender_name
              FROM EMPLOEE  t
                   LEFT JOIN uss_ndi.v_ddn_gender g
                       ON (g.DIC_VALUE = t.em_gender)
             WHERE t.em_id = p_em_id;

        OPEN p_em_staff_cur FOR
            SELECT t.*,
                   p.oss_name     AS emf_oss_name,
                   o.os_name,
                   op.OSP_NAME
              FROM em_staff  t
                   LEFT JOIN os_staff s ON (s.ost_id = t.emf_ost)
                   LEFT JOIN Orgstructure o ON (o.os_id = s.ost_os)
                   LEFT JOIN uss_ndi.v_ndi_os_position op
                       ON (op.OSP_ID = s.ost_osp)
                   LEFT JOIN uss_ndi.v_ndi_os_specialization p
                       ON (p.oss_id = t.emf_oss)
             WHERE t.emf_em = p_em_id AND t.history_status = 'A';

        OPEN p_em_serv_cur FOR
            SELECT t.*, s.nst_name AS ems_nst_name
              FROM em_service  t
                   LEFT JOIN uss_ndi.v_ndi_service_type s
                       ON (s.nst_id = t.ems_nst)
             WHERE t.ems_em = p_em_id AND t.history_status = 'A';

        OPEN p_em_train_cur FOR
            SELECT t.*,
                   tp.DIC_NAME     AS emt_tp_name,
                   f.DIC_NAME      AS emt_form_name
              FROM em_training  t
                   LEFT JOIN uss_ndi.v_ddn_emt_tp tp
                       ON (tp.DIC_VALUE = t.emt_tp)
                   LEFT JOIN uss_ndi.v_ddn_emt_form f
                       ON (f.DIC_VALUE = t.emt_form)
             WHERE t.emt_em = p_em_id AND t.history_status = 'A';

        OPEN p_em_edu_cur FOR
            SELECT t.*, l.ose_name AS eme_ose_name
              FROM em_education  t
                   LEFT JOIN uss_ndi.v_ndi_os_education_lv l
                       ON (l.ose_id = t.eme_ose)
             WHERE t.eme_em = p_em_id AND t.history_status = 'A';

        OPEN p_em_superv_cur FOR
            SELECT t.*
              FROM em_supervision t
             WHERE t.emv_em = p_em_id AND t.history_status = 'A';
    END;

    -- Картка працівника НСП, збереження
    PROCEDURE SET_EMPLOYEE_CARD (p_emp_xml         IN     CLOB,
                                 p_em_staff_xml    IN     CLOB,
                                 p_em_serv_xml     IN     CLOB,
                                 p_em_train_xml    IN     CLOB,
                                 p_em_edu_xml      IN     CLOB,
                                 p_em_superv_xml   IN     CLOB,
                                 p_new_id             OUT NUMBER)
    IS
        l_employee          cmes$organization.r_employee;
        l_emp_training      cmes$organization.t_em_training;
        l_emp_supervision   cmes$organization.t_em_supervision;
        l_emp_staff         cmes$organization.t_em_staff;
        l_emp_service       cmes$organization.t_em_service;
        l_emp_education     cmes$organization.t_em_education;
    BEGIN
        Write_Audit ('SET_EMPLOYEE_CARD');

        l_employee := Parse_Employee (p_emp_xml);
        SET_EMPLOYEE (l_employee, p_new_id);

        l_emp_training := Parse_Training (p_em_train_xml);
        l_emp_supervision := Parse_Supervision (p_em_superv_xml);
        l_emp_staff := Parse_Staff (p_em_staff_xml);
        l_emp_service := Parse_Service (p_em_serv_xml);
        l_emp_education := Parse_Education (p_em_edu_xml);

        SET_EM_TRAININGS (p_new_id, l_emp_training);
        SET_EM_SUPERVISIONS (p_new_id, l_emp_supervision);
        SET_EM_STAFFS (p_new_id, l_emp_staff);
        SET_EM_SERVICES (p_new_id, l_emp_service);
        SET_EM_EDUCATIONS (p_new_id, l_emp_education);
    END;



    -- Видалити картку працівника
    PROCEDURE DELETE_EMPLOYEE (p_em_id EMPLOEE.EM_ID%TYPE)
    IS
    BEGIN
        Write_Audit ('DELETE_EMPLOYEE');

        UPDATE emploee t
           SET t.history_status = 'H'
         WHERE t.em_id = p_em_id;
    END;
BEGIN
    NULL;
END CMES$ORGANIZATION;
/