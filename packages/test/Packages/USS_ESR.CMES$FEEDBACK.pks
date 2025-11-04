/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$FEEDBACK
IS
    -- Author  : OLEKSII
    -- Created : 04.11.2023 20:08:02
    -- Purpose :

    TYPE r_FEEDBACK IS RECORD
    (
        FB_ID                FEEDBACK.FB_ID%TYPE,                 --Ід відгуку
        FB_SC                FEEDBACK.FB_SC%TYPE,       --Ід соціальної картки
        FB_RNSPM             FEEDBACK.FB_RNSPM%TYPE, --Ід реєстраційної картки надавача соціальних послуг
        FB_AT                FEEDBACK.FB_AT%TYPE,   --Ід рішення/договору/акту
        FB_ST                FEEDBACK.FB_ST%TYPE,                     --Статус
        FB_CU                FEEDBACK.FB_CU%TYPE, --Ід користувача кабінету соцпорталу
        FB_REG_NUM           FEEDBACK.FB_REG_NUM%TYPE,         --Номер відгуку
        FB_REG_DT            FEEDBACK.FB_REG_DT%TYPE,           --Дата відгуку
        FB_RNSPM_TP          FEEDBACK.FB_RNSPM_TP%TYPE,          --Тип закладу
        FB_IMPRESSION        FEEDBACK.FB_IMPRESSION%TYPE,  --Загальне враження
        FB_SRC               FEEDBACK.FB_SRC%TYPE,            --Cпособ відгуку
        FB_CONTACT_TP        FEEDBACK.FB_CONTACT_TP%TYPE,       --Тип контакту
        FB_CONTACT           FEEDBACK.FB_CONTACT%TYPE,               --Контакт
        FB_PROBLEM_DESC      FEEDBACK.FB_PROBLEM_DESC%TYPE,     --Тип проблеми
        FB_ANSWER            FEEDBACK.FB_ANSWER%TYPE,       --Надана відповідь
        FB_NDT               FEEDBACK.FB_NDT%TYPE, --Тип документу з параметрами опитування
        FB_CU_KM             FEEDBACK.FB_CU_KM%TYPE,                   --Ід КМ
        FB_REVIEW_PERSON     FEEDBACK.FB_REVIEW_PERSON%TYPE, --Про кого відгук, якщо це не КМ ОСП
        FB_RNSPA             FEEDBACK.FB_RNSPA%TYPE,           --Ід адреси НСП
        FB_REVIEW_ADDRESS    FEEDBACK.FB_REVIEW_ADDRESS%TYPE, --Адреса надання послуг
        FB_SC_PIB            FEEDBACK.FB_PIB%TYPE,      --ПІБ надавача відгуку
        New_Id               NUMBER
    );

    TYPE r_FB_SERVICE IS RECORD
    (
        FBS_ID            FB_SERVICE.FBS_ID%TYPE,                  --Ід запису
        FBS_FB            FB_SERVICE.FBS_FB%TYPE,                 --Ід відгуку
        FBS_NST           FB_SERVICE.FBS_NST%TYPE,           --Ід типу послуги
        HISTORY_STATUS    FB_SERVICE.HISTORY_STATUS%TYPE,     --history_status
        New_Id            NUMBER,
        Deleted           NUMBER
    );

    TYPE t_FB_SERVICE IS TABLE OF r_FB_SERVICE;

    TYPE r_FB_DOCUMENT IS RECORD
    (
        FBD_ID            FB_DOCUMENT.FBD_ID%TYPE,                 --Ід запису
        FBD_FB            FB_DOCUMENT.FBD_FB%TYPE,                --Ід відгуку
        FBD_DOC           FB_DOCUMENT.FBD_DOC%TYPE,         --Ід документу Е/А
        FBD_DH            FB_DOCUMENT.FBD_DH%TYPE,    --Ід зрізу документу Е/А
        FBD_NOTES         FB_DOCUMENT.FBD_NOTES%TYPE,               --коментар
        HISTORY_STATUS    FB_DOCUMENT.HISTORY_STATUS%TYPE,    --history_status
        FBD_NDT           FB_DOCUMENT.FBD_NDT%TYPE,        --Ід типу документу
        New_Id            NUMBER,
        Deleted           NUMBER
    );

    TYPE t_FB_DOCUMENT IS TABLE OF r_FB_DOCUMENT;

    TYPE r_FB_QUESTION IS RECORD
    (
        FBQ_ID            FB_QUESTION.FBQ_ID%TYPE,                 --Ід запису
        FBQ_FB            FB_QUESTION.FBQ_FB%TYPE,                --Ід відгуку
        FBQ_NDA           FB_QUESTION.FBQ_NDA%TYPE,    --Ід атрибуту документу
        FBQ_FEATURE       FB_QUESTION.FBQ_FEATURE%TYPE,             --Значення
        FBQ_NOTES         FB_QUESTION.FBQ_NOTES%TYPE,         --Коментар/назва
        HISTORY_STATUS    FB_QUESTION.HISTORY_STATUS%TYPE,    --history_status
        New_Id            NUMBER,
        Deleted           NUMBER
    );

    TYPE t_FB_QUESTION IS TABLE OF r_FB_QUESTION;

    PROCEDURE Get_Rec_Cm_List (p_Rnspm_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Rnsp_Svc_Adresses (p_Rnspm_Id   IN     NUMBER,
                                     p_Res           OUT SYS_REFCURSOR);


    --====================================================--
    -- Збереження відгуку
    --====================================================--
    PROCEDURE Save_FEEDBACK (p_fb_Id         IN OUT NUMBER,
                             p_fb_Src        IN     VARCHAR2,
                             p_FEEDBACK      IN     CLOB,
                             p_fb_Service    IN     CLOB,
                             p_fb_Question   IN     CLOB,
                             p_fb_Document   IN     CLOB);

    FUNCTION Get_Rnsp_Addr_Text (p_Rnspa_Id IN NUMBER)
        RETURN VARCHAR2;


    --====================================================--
    -- Перелік відгуків ОСП
    --====================================================--
    PROCEDURE get_feedback_Rc (p_dt_start   IN     DATE,
                               p_dt_stop    IN     DATE,
                               p_fb_num     IN     VARCHAR2,
                               p_cm_pib     IN     VARCHAR2,
                               res_cur         OUT SYS_REFCURSOR);

    --====================================================--
    -- Перелік відгуків НСП
    --====================================================--
    PROCEDURE get_feedback_Pr (p_owner_id   IN     NUMBER,
                               p_dt_start   IN     DATE,
                               p_dt_stop    IN     DATE,
                               p_impres     IN     NUMBER,
                               p_cm_pib     IN     VARCHAR2,
                               res_cur         OUT SYS_REFCURSOR);

    -------------------------------------
    ------------ Кейс менеджер ----------

    -- журнал КМ
    PROCEDURE get_journal_cm (p_dt_start   IN     DATE,
                              p_dt_stop    IN     DATE,
                              p_fb_num     IN     VARCHAR2,
                              res_cur         OUT SYS_REFCURSOR);

    -- картка відгуку Кейс менеджера
    PROCEDURE get_card_cm (p_fb_id       IN     NUMBER,
                           p_main           OUT SYS_REFCURSOR,
                           p_services       OUT SYS_REFCURSOR,
                           p_questions      OUT SYS_REFCURSOR,
                           p_docs           OUT SYS_REFCURSOR,
                           p_files          OUT SYS_REFCURSOR);

    -- картка відгуку
    PROCEDURE get_card (p_fb_id       IN     NUMBER,
                        p_main           OUT SYS_REFCURSOR,
                        p_services       OUT SYS_REFCURSOR,
                        p_questions      OUT SYS_REFCURSOR,
                        p_docs           OUT SYS_REFCURSOR,
                        p_files          OUT SYS_REFCURSOR);


    -- відповідь кейс менеджера
    PROCEDURE set_answer_cm (p_fb_id IN NUMBER, p_fb_answer IN VARCHAR2);

    -----------------------------------------------------------
    --     ПЕРЕВІРКА НАЯВНОСТІ ДОСТУПУ ДО ФАЙЛУ
    -----------------------------------------------------------
    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_cmes_id IN NUMBER)
        RETURN VARCHAR2;
END CMES$FEEDBACK;
/


GRANT EXECUTE ON USS_ESR.CMES$FEEDBACK TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.CMES$FEEDBACK TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$FEEDBACK TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.CMES$FEEDBACK TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$FEEDBACK
IS
    Pkg   VARCHAR2 (50) := 'CMES$FEEDBACK';

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
    --   Парсинг Відгук
    --====================================================--
    FUNCTION Parse_FEEDBACK (p_Xml IN CLOB)
        RETURN r_FEEDBACK
    IS
        l_Result   r_FEEDBACK;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;


        EXECUTE IMMEDIATE Parse ('R_FEEDBACK')
            INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Відгук: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    --   Парсинг Прикладені документи та фото
    --====================================================--
    FUNCTION Parse_DOCUMENT (p_Xml IN CLOB)
        RETURN t_FB_DOCUMENT
    IS
        l_Result   t_FB_DOCUMENT;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('t_FB_DOCUMENT')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Прикладені документи та фото: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    --   Парсинг Опитуваня отримувача
    --====================================================--
    FUNCTION Parse_QUESTION (p_Xml IN CLOB)
        RETURN t_FB_QUESTION
    IS
        l_Result   t_FB_QUESTION;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('t_FB_QUESTION')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Опитуваня отримувача: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    --   Парсинг Найменування послуги
    --====================================================--
    FUNCTION Parse_SERVICE (p_Xml IN CLOB)
        RETURN t_FB_SERVICE
    IS
        l_Result   t_FB_SERVICE;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('t_FB_SERVICE')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Найменування послуги: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    --   Збереження інформації Відгук
    --====================================================--
    PROCEDURE Save_FEEDBACK (
        p_FB_ID                   FEEDBACK.FB_ID%TYPE,
        p_FB_SC                   FEEDBACK.FB_SC%TYPE,
        p_FB_RNSPM                FEEDBACK.FB_RNSPM%TYPE,
        p_FB_AT                   FEEDBACK.FB_AT%TYPE,
        p_FB_ST                   FEEDBACK.FB_ST%TYPE,
        p_FB_CU                   FEEDBACK.FB_CU%TYPE,
        p_FB_REG_NUM              FEEDBACK.FB_REG_NUM%TYPE,
        p_FB_REG_DT               FEEDBACK.FB_REG_DT%TYPE,
        p_FB_RNSPM_TP             FEEDBACK.FB_RNSPM_TP%TYPE,
        p_FB_IMPRESSION           FEEDBACK.FB_IMPRESSION%TYPE,
        p_FB_SRC                  FEEDBACK.FB_SRC%TYPE,
        p_FB_CONTACT_TP           FEEDBACK.FB_CONTACT_TP%TYPE,
        p_FB_CONTACT              FEEDBACK.FB_CONTACT%TYPE,
        p_FB_PROBLEM_DESC         FEEDBACK.FB_PROBLEM_DESC%TYPE,
        p_FB_ANSWER               FEEDBACK.FB_ANSWER%TYPE,
        p_FB_NDT                  FEEDBACK.FB_NDT%TYPE,
        p_FB_CU_KM                FEEDBACK.FB_CU_KM%TYPE,
        p_FB_REVIEW_PERSON        FEEDBACK.FB_REVIEW_PERSON%TYPE,
        p_FB_RNSPA                FEEDBACK.FB_RNSPA%TYPE,
        p_FB_REVIEW_ADDRESS       FEEDBACK.FB_REVIEW_ADDRESS%TYPE,
        p_FB_SC_PIB               FEEDBACK.FB_PIB%TYPE,
        p_New_Id              OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_FB_ID, -1) < 0
        THEN
            SELECT id_feedback (0) INTO p_New_Id FROM DUAL;

            INSERT INTO FEEDBACK (FB_ID,
                                  FB_SC,
                                  FB_RNSPM,
                                  FB_AT,
                                  FB_ST,
                                  FB_CU,
                                  FB_REG_NUM,
                                  FB_REG_DT,
                                  FB_RNSPM_TP,
                                  FB_IMPRESSION,
                                  FB_SRC,
                                  FB_CONTACT_TP,
                                  FB_CONTACT,
                                  FB_PROBLEM_DESC,
                                  FB_ANSWER,
                                  FB_NDT,
                                  FB_CU_KM,
                                  FB_REVIEW_PERSON,
                                  FB_RNSPA,
                                  FB_REVIEW_ADDRESS,
                                  FB_PIB)
                 VALUES (p_New_Id,
                         p_FB_SC,
                         p_FB_RNSPM,
                         p_FB_AT,
                         p_FB_ST,
                         p_FB_CU,
                         p_New_Id,
                         p_FB_REG_DT,
                         p_FB_RNSPM_TP,
                         p_FB_IMPRESSION,
                         p_FB_SRC,
                         p_FB_CONTACT_TP,
                         p_FB_CONTACT,
                         p_FB_PROBLEM_DESC,
                         p_FB_ANSWER,
                         p_FB_NDT,
                         p_FB_CU_KM,
                         p_FB_REVIEW_PERSON,
                         p_FB_RNSPA,
                         p_FB_REVIEW_ADDRESS,
                         P_FB_SC_PIB)
              RETURNING FB_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_FB_ID;

            UPDATE FEEDBACK t
               SET t.FB_SC = p_FB_SC,
                   t.FB_RNSPM = p_FB_RNSPM,
                   t.FB_AT = p_FB_AT,
                   t.FB_ST = p_FB_ST,
                   t.FB_CU = p_FB_CU,
                   --t.FB_REG_NUM            = p_FB_REG_NUM,
                   --t.FB_REG_DT             = p_FB_REG_DT,
                   t.FB_RNSPM_TP = p_FB_RNSPM_TP,
                   t.FB_IMPRESSION = p_FB_IMPRESSION,
                   --t.FB_SRC                = p_FB_SRC,
                   t.FB_CONTACT_TP = p_FB_CONTACT_TP,
                   t.FB_CONTACT = p_FB_CONTACT,
                   t.FB_PROBLEM_DESC = p_FB_PROBLEM_DESC,
                   t.FB_ANSWER = p_FB_ANSWER,
                   t.FB_NDT = p_FB_NDT,
                   t.FB_CU_KM = P_FB_CU_KM,
                   t.FB_REVIEW_PERSON = P_FB_REVIEW_PERSON,
                   t.FB_RNSPA = P_FB_RNSPA,
                   t.FB_REVIEW_ADDRESS = P_FB_REVIEW_ADDRESS,
                   t.FB_PIB = P_FB_SC_PIB
             WHERE t.FB_ID = p_FB_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження інформації Найменування послуги
    --====================================================--
    PROCEDURE Save_FB_SERVICE (
        p_FBS_ID               FB_SERVICE.FBS_ID%TYPE,
        p_FBS_FB               FB_SERVICE.FBS_FB%TYPE,
        p_FBS_NST              FB_SERVICE.FBS_NST%TYPE,
        p_HISTORY_STATUS       FB_SERVICE.HISTORY_STATUS%TYPE,
        p_New_Id           OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_FBS_ID, -1) < 0
        THEN
            INSERT INTO FB_SERVICE (FBS_ID,
                                    FBS_FB,
                                    FBS_NST,
                                    HISTORY_STATUS)
                 VALUES (0,
                         p_FBS_FB,
                         p_FBS_NST,
                         'A')
              RETURNING FBS_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_FBS_ID;

            UPDATE FB_SERVICE t
               SET t.FBS_ID = p_FBS_ID,
                   t.FBS_FB = p_FBS_FB,
                   t.FBS_NST = p_FBS_NST                                   --,
             --            t.HISTORY_STATUS        = p_HISTORY_STATUS
             WHERE t.FBS_ID = p_FBS_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження інформації Прикладені документи та фото
    --====================================================--
    PROCEDURE Save_FB_DOCUMENT (
        p_FBD_ID               FB_DOCUMENT.FBD_ID%TYPE,
        p_FBD_FB               FB_DOCUMENT.FBD_FB%TYPE,
        p_FBD_DOC              FB_DOCUMENT.FBD_DOC%TYPE,
        p_FBD_DH               FB_DOCUMENT.FBD_DH%TYPE,
        p_FBD_NOTES            FB_DOCUMENT.FBD_NOTES%TYPE,
        p_HISTORY_STATUS       FB_DOCUMENT.HISTORY_STATUS%TYPE,
        p_FBD_NDT              FB_DOCUMENT.FBD_NDT%TYPE,
        p_New_Id           OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_FBD_ID, -1) < 0
        THEN
            INSERT INTO FB_DOCUMENT (FBD_ID,
                                     FBD_FB,
                                     FBD_DOC,
                                     FBD_DH,
                                     FBD_NOTES,
                                     HISTORY_STATUS,
                                     FBD_NDT)
                 VALUES (0,
                         p_FBD_FB,
                         p_FBD_DOC,
                         p_FBD_DH,
                         p_FBD_NOTES,
                         'A',
                         p_FBD_NDT)
              RETURNING FBD_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_FBD_ID;

            UPDATE FB_DOCUMENT t
               SET t.FBD_ID = p_FBD_ID,
                   t.FBD_FB = p_FBD_FB,
                   t.FBD_DOC = p_FBD_DOC,
                   t.FBD_DH = p_FBD_DH,
                   t.FBD_NOTES = p_FBD_NOTES,
                   t.HISTORY_STATUS = p_HISTORY_STATUS,
                   t.FBD_NDT = p_FBD_NDT
             WHERE t.FBD_ID = p_FBD_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження інформації Опитуваня отримувача
    --====================================================--
    PROCEDURE Save_FB_QUESTION (
        p_FBQ_ID               FB_QUESTION.FBQ_ID%TYPE,
        p_FBQ_FB               FB_QUESTION.FBQ_FB%TYPE,
        p_FBQ_NDA              FB_QUESTION.FBQ_NDA%TYPE,
        p_FBQ_FEATURE          FB_QUESTION.FBQ_FEATURE%TYPE,
        p_FBQ_NOTES            FB_QUESTION.FBQ_NOTES%TYPE,
        p_HISTORY_STATUS       FB_QUESTION.HISTORY_STATUS%TYPE,
        p_New_Id           OUT NUMBER)
    IS
    BEGIN
        IF NVL (p_FBQ_ID, -1) < 0
        THEN
            INSERT INTO FB_QUESTION (FBQ_ID,
                                     FBQ_FB,
                                     FBQ_NDA,
                                     FBQ_FEATURE,
                                     FBQ_NOTES,
                                     HISTORY_STATUS)
                 VALUES (0,
                         p_FBQ_FB,
                         p_FBQ_NDA,
                         p_FBQ_FEATURE,
                         p_FBQ_NOTES,
                         'A')
              RETURNING FBQ_ID
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_FBQ_ID;

            UPDATE FB_QUESTION t
               SET t.FBQ_ID = p_FBQ_ID,
                   t.FBQ_FB = p_FBQ_FB,
                   t.FBQ_NDA = p_FBQ_NDA,
                   t.FBQ_FEATURE = p_FBQ_FEATURE,
                   t.FBQ_NOTES = p_FBQ_NOTES                               --,
             --            t.HISTORY_STATUS        = p_HISTORY_STATUS
             WHERE t.FBQ_ID = p_FBQ_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження інформації Найменування послуги
    --====================================================--
    PROCEDURE Save_FB_SERVICES (
        p_FB_ID                      FEEDBACK.FB_ID%TYPE,
        p_FB_SERVICE   IN OUT NOCOPY CMES$FEEDBACK.t_FB_SERVICE)
    IS
    BEGIN
        IF p_FB_SERVICE IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_FB_SERVICES');

        FOR i IN 1 .. p_FB_SERVICE.COUNT
        LOOP
            IF p_FB_SERVICE (i).Deleted = 1
            THEN
                UPDATE FB_SERVICE t
                   SET t.History_Status = 'H'
                 WHERE t.FBS_ID = p_FB_SERVICE (i).FBS_ID;
            ELSE
                Save_FB_SERVICE (
                    p_FBS_ID           => p_FB_SERVICE (i).FBS_ID,
                    p_FBS_FB           => p_FB_ID,
                    p_FBS_NST          => p_FB_SERVICE (i).FBS_NST,
                    p_HISTORY_STATUS   => p_FB_SERVICE (i).HISTORY_STATUS,
                    p_New_Id           => p_FB_SERVICE (i).New_Id);
            END IF;
        END LOOP;
    END;

    --====================================================--
    --   Збереження інформації Прикладені документи та фото
    --====================================================--
    PROCEDURE Save_FB_DOCUMENTS (
        p_FB_ID                       FEEDBACK.FB_ID%TYPE,
        p_FB_DOCUMENT   IN OUT NOCOPY CMES$FEEDBACK.t_FB_DOCUMENT)
    IS
    BEGIN
        IF p_FB_DOCUMENT IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_FB_DOCUMENTS');

        FOR i IN 1 .. p_FB_DOCUMENT.COUNT
        LOOP
            IF p_FB_DOCUMENT (i).Deleted = 1
            THEN
                UPDATE FB_DOCUMENT t
                   SET t.History_Status = 'H'
                 WHERE t.FBD_ID = p_FB_DOCUMENT (i).FBD_ID;
            ELSE
                Save_FB_DOCUMENT (
                    p_FBD_ID           => p_FB_DOCUMENT (i).FBD_ID,
                    p_FBD_FB           => p_FB_ID,
                    p_FBD_DOC          => p_FB_DOCUMENT (i).FBD_DOC,
                    p_FBD_DH           => p_FB_DOCUMENT (i).FBD_DH,
                    p_FBD_NOTES        => p_FB_DOCUMENT (i).FBD_NOTES,
                    p_HISTORY_STATUS   => p_FB_DOCUMENT (i).HISTORY_STATUS,
                    p_FBD_NDT          => p_FB_DOCUMENT (i).FBD_NDT,
                    p_New_Id           => p_FB_DOCUMENT (i).New_Id);
            END IF;
        END LOOP;
    END;

    --====================================================--
    --   Збереження інформації Опитуваня отримувача
    --====================================================--
    PROCEDURE Save_FB_QUESTIONS (
        p_FB_ID                       FEEDBACK.FB_ID%TYPE,
        p_FB_QUESTION   IN OUT NOCOPY CMES$FEEDBACK.t_FB_QUESTION)
    IS
    BEGIN
        IF p_FB_QUESTION IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_FB_QUESTIONS');

        FOR i IN 1 .. p_FB_QUESTION.COUNT
        LOOP
            IF p_FB_QUESTION (i).Deleted = 1
            THEN
                UPDATE FB_QUESTION t
                   SET t.History_Status = 'H'
                 WHERE t.FBQ_ID = p_FB_QUESTION (i).FBQ_ID;
            ELSE
                Save_FB_QUESTION (
                    p_FBQ_ID           => p_FB_QUESTION (i).FBQ_ID,
                    p_FBQ_FB           => p_FB_ID,
                    p_FBQ_NDA          => p_FB_QUESTION (i).FBQ_NDA,
                    p_FBQ_FEATURE      => p_FB_QUESTION (i).FBQ_FEATURE,
                    p_FBQ_NOTES        => p_FB_QUESTION (i).FBQ_NOTES,
                    p_HISTORY_STATUS   => p_FB_QUESTION (i).HISTORY_STATUS,
                    p_New_Id           => p_FB_QUESTION (i).New_Id);
            END IF;
        END LOOP;
    END;

    --====================================================--
    -- Отримання переліку кейс-менеджерів з яким
    -- взаємодіяв ОСП
    --====================================================--
    PROCEDURE Get_Rec_Cm_List (p_Rnspm_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
        l_Sc_Id                   NUMBER;
        l_Rnsp_Is_Stuff_Publish   USS_RNSP.V_RNSP.RNSPS_IS_STUFF_PUBLISH%TYPE;
    BEGIN
        SELECT a.RNSPS_IS_STUFF_PUBLISH
          INTO l_Rnsp_Is_Stuff_Publish
          FROM USS_RNSP.V_RNSP a
         WHERE rnspm_id = p_Rnspm_Id;

        --todo: дописати вібірку з історії актів(якщо така колись з'явиться)
        IF l_Rnsp_Is_Stuff_Publish = 'F'
        THEN
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

            OPEN p_Res FOR
                SELECT DISTINCT a.At_Cu AS Cu_Id, u.Cu_Pib
                  FROM Act  a
                       JOIN Ikis_Rbm.v_Cmes_Users u ON a.At_Cu = u.Cu_Id
                 WHERE     a.At_Sc = l_Sc_Id
                       AND a.At_Rnspm = p_Rnspm_Id
                       AND Ikis_Rbm.Tools.Getcurrentcu IS NOT NULL;
        ELSE
            USS_RNSP.CMES$RNSP.Get_Rec_Cm_List (p_Rnspm_Id   => p_Rnspm_Id,
                                                p_Res        => p_Res);
        END IF;
    END;

    --====================================================--
    -- Отримання переліку адрес для надання соцполсуг
    -- по надавачу
    --====================================================--
    PROCEDURE Get_Rnsp_Svc_Adresses (p_Rnspm_Id   IN     NUMBER,
                                     p_Res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.Rnspa_Id, Get_Rnsp_Addr_Text (a.Rnspa_Id) AS Rnspa_Text
              FROM Uss_Rnsp.v_Rnsp_State  s
                   JOIN Uss_Rnsp.v_Rnsp2address t
                       ON s.Rnsps_Id = t.Rnsp2a_Rnsps
                   JOIN Uss_Rnsp.v_Rnsp_Address a
                       ON t.Rnsp2a_Rnspa = a.Rnspa_Id AND a.Rnspa_Tp = 'S'
             WHERE s.Rnsps_Rnspm = p_Rnspm_Id AND s.History_Status = 'A';
    END;

    --====================================================--
    -- Збереження відгуку
    --====================================================--
    PROCEDURE Save_FEEDBACK (p_fb_Id         IN OUT NUMBER,
                             p_fb_Src        IN     VARCHAR2,
                             p_FEEDBACK      IN     CLOB,
                             p_fb_Service    IN     CLOB,
                             p_fb_Question   IN     CLOB,
                             p_fb_Document   IN     CLOB)
    IS
        l_Cu_Id       NUMBER;
        l_Sc_Id       NUMBER;
        l_Fb_Cu       NUMBER;
        l_fb_St_Old   VARCHAR2 (10);
        --    l_Already_Exist NUMBER;
        l_Feedback    CMES$FEEDBACK.r_FEEDBACK;
        l_Services    CMES$FEEDBACK.t_FB_SERVICE;
        l_Questions   CMES$FEEDBACK.t_FB_QUESTION;
        l_Documents   CMES$FEEDBACK.t_FB_DOCUMENT;
    BEGIN
        /*
        FN - нові;
        FP - переглянуті;
        FR - непідтверджені;
        */
        Write_Audit ('Save_FEEDBACK');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Sc_Id := Ikis_Rbm.Tools.GetCuSc (l_Cu_Id);

        l_Feedback := Parse_Feedback (p_Feedback);

        /*
            IF l_Feedback.fb_Rnspm IS NOT NULL
               AND NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned(p_Cmes_Id       => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                                                               p_Cmes_Owner_Id => l_Feedback.fb_Rnspm,
                                                               p_Cr_Code       => 'NSP_SPEC')
               AND NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned(p_Cmes_Id       => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                                                               p_Cmes_Owner_Id => l_Feedback.fb_Rnspm,
                                                               p_Cr_Code       => 'NSP_CM') THEN
              Raise_Application_Error(-20000, 'Некоректно вакзано надавача');
            END IF;
        */

        --Редагування акту
        IF NVL (p_fb_Id, -1) > 0
        THEN
            SELECT a.fb_Cu, a.fb_St
              INTO l_fb_Cu, l_fb_St_Old
              FROM Feedback a
             WHERE a.fb_Id = p_fb_Id;

            IF l_fb_Cu IS NULL OR l_fb_Cu <> NVL (l_Cu_Id, -1)
            THEN
                Api$act.Raise_Unauthorized;
                NULL;
            END IF;

            IF NVL (l_fb_St_Old, '-') <> 'XN'
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування відгуку в поточному статусі заборонено');
                NULL;
            END IF;
        END IF;

        IF l_Feedback.FB_AT IS NULL AND l_Feedback.FB_RNSPM IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не вказано надавача СП');
            NULL;
        END IF;

        IF l_Feedback.FB_AT IS NOT NULL AND l_Feedback.FB_RNSPM IS NULL
        THEN
            SELECT a.at_rnspm
              INTO l_Feedback.FB_RNSPM
              FROM act a
             WHERE a.at_id = l_Feedback.FB_AT;
        END IF;


        --ПАРСИНГ
        l_Services := CMES$FEEDBACK.Parse_SERVICE (p_fb_Service);
        l_Questions := CMES$FEEDBACK.Parse_QUESTION (p_fb_Question);
        l_Documents := CMES$FEEDBACK.Parse_DOCUMENT (p_fb_Document);

        Save_FEEDBACK (p_FB_ID               => l_Feedback.FB_ID,
                       p_FB_SC               => l_Sc_Id,
                       p_FB_RNSPM            => l_Feedback.FB_RNSPM,
                       p_FB_AT               => l_Feedback.FB_AT,
                       p_FB_ST               => 'FN',
                       p_FB_CU               => l_Feedback.FB_Cu,
                       p_FB_REG_NUM          => l_Feedback.FB_REG_NUM,
                       p_FB_REG_DT           => SYSDATE,
                       p_FB_RNSPM_TP         => l_Feedback.FB_RNSPM_TP,
                       p_FB_IMPRESSION       => l_Feedback.FB_IMPRESSION,
                       p_FB_SRC              => NVL (l_Feedback.FB_SRC, p_fb_Src),
                       p_FB_CONTACT_TP       => l_Feedback.FB_CONTACT_TP,
                       p_FB_CONTACT          => l_Feedback.FB_CONTACT,
                       p_FB_PROBLEM_DESC     => l_Feedback.FB_PROBLEM_DESC,
                       p_FB_ANSWER           => l_Feedback.FB_ANSWER,
                       p_FB_NDT              => '',       --l_Feedback.FB_NDT,
                       p_FB_CU_KM            => l_Feedback.FB_CU_KM,
                       p_FB_REVIEW_PERSON    => l_Feedback.FB_REVIEW_PERSON,
                       p_FB_RNSPA            => l_Feedback.FB_RNSPA,
                       p_FB_REVIEW_ADDRESS   => l_Feedback.FB_REVIEW_ADDRESS,
                       p_FB_SC_PIB           => l_Feedback.FB_SC_PIB,
                       p_New_Id              => p_fb_Id    --l_Feedback.New_Id
                                                       );

        Save_fb_Services (p_fb_Id, l_Services);
        Save_fb_Questions (p_fb_Id, l_Questions);
        Save_fb_Documents (p_fb_Id, l_Documents);
    END;

    FUNCTION Get_Rnsp_Addr_Text (p_Rnspa_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        IF p_Rnspa_Id IS NULL
        THEN
            RETURN NULL;
        END IF;

        SELECT    uss_ndi.api$dic_common.Get_Kaot_Region (a.Rnspa_Kaot)
               || ' обл., '
               || CASE
                      WHEN uss_ndi.api$dic_common.Get_Kaot_District (
                               a.Rnspa_Kaot)
                               IS NOT NULL
                      THEN
                             uss_ndi.api$dic_common.Get_Kaot_District (
                                 a.Rnspa_Kaot)
                          || ' район, '
                  END
               || CASE
                      WHEN uss_ndi.api$dic_common.Get_Kaot_City (
                               a.Rnspa_Kaot)
                               IS NOT NULL
                      THEN
                             uss_ndi.api$dic_common.Get_Kaot_City_Tp (
                                 a.Rnspa_Kaot)
                          || ' '
                          || uss_ndi.api$dic_common.Get_Kaot_City (
                                 a.Rnspa_Kaot)
                          || ','
                  END
               || a.Rnspa_Street
               || ' '
               || a.Rnspa_Building
               || CASE
                      WHEN a.Rnspa_Korp IS NOT NULL
                      THEN
                          ', корп. ' || a.Rnspa_Korp
                  END
               || CASE
                      WHEN a.Rnspa_Appartement IS NOT NULL
                      THEN
                          ', кв. ' || a.Rnspa_Appartement
                  END
          INTO l_Result
          FROM uss_rnsp.v_Rnsp_Address a
         WHERE a.Rnspa_Id = p_Rnspa_Id;

        RETURN l_Result;
    END;

    --====================================================--
    -- Перелік відгуків
    --====================================================--
    PROCEDURE get_feedback (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT f.*,
                   NVL (f.fb_pib, uss_person.api$sc_tools.GET_PIB (f.fb_sc))
                       AS fb_sc_pib,
                   uss_rnsp.api$find.Get_Nsp_Name (f.fb_rnspm)
                       AS fb_rnspm_name,
                   a.at_num
                       AS fb_at_name,
                   --Ikis_Rbm.Tools.Getcupib(a.at_cu) AS at_cu_pib,
                   Ikis_Rbm.Tools.Getcupib (NVL (f.fb_cu, a.at_cu))
                       AS at_cu_pib,
                   tp.DIC_NAME
                       AS Fb_Contact_Tp_Name,
                   rtp.DIC_NAME
                       AS Fb_Rnspm_Tp_Name,
                   st.dic_name
                       AS fb_st_name,
                   Get_Rnsp_Addr_Text (f.fb_rnspa)
                       AS Fb_Rnspa_Text,
                   Ikis_Rbm.Tools.Getcupib (f.fb_cu_km)
                       AS Fb_Cu_Km_Pib,
                   NVL (fs.DIC_NAME, f.fb_src)
                       Fb_src_name
              FROM Tmp_Work_Ids  t
                   JOIN feedback f ON f.fb_Id = t.x_Id
                   LEFT JOIN v_act a ON (a.at_id = f.fb_at)
                   LEFT JOIN uss_ndi.v_ddn_fb_st st
                       ON (st.dic_value = f.fb_st)
                   LEFT JOIN uss_ndi.v_ddn_FB_CONTACT_TP tp
                       ON (tp.dic_value = f.fb_contact_tp)
                   LEFT JOIN uss_ndi.v_ddn_FB_RNSPM_TP rtp
                       ON (rtp.dic_value = f.fb_rnspm_tp)
                   LEFT JOIN uss_ndi.v_ddn_fb_src fs
                       ON (fs.DIC_VALUE = f.fb_src);
    END;

    --====================================================--
    -- Перелік відгуків ОСП
    -- 1. Дата подання оцінки з
    -- 2. Дата подання оцінки по
    -- 3. Номер оцінки
    -- 4. Надавач соціальної послуги
    -- 5. ПІБ кейс - менеджера
    --====================================================--
    PROCEDURE get_feedback_Rc (p_dt_start   IN     DATE,
                               p_dt_stop    IN     DATE,
                               p_fb_num     IN     VARCHAR2,
                               p_cm_pib     IN     VARCHAR2,
                               res_cur         OUT SYS_REFCURSOR)
    IS
        l_1310    VARCHAR2 (10) := CHR (13) || CHR (10);
        l_Cu_Id   NUMBER;
        l_Sc_Id   NUMBER;
    BEGIN
        Write_Audit ('get_feedback_Rc');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Sc_Id := Ikis_Rbm.Tools.GetCuSc (l_Cu_Id);

        LOG (
            'get_feedback_Rc',
               'p_dt_start='
            || p_dt_start
            || l_1310
            || 'p_dt_stop='
            || p_dt_stop
            || l_1310
            || 'p_cm_pib='
            || p_cm_pib
            || l_1310
            || 'p_cm_pib='
            || p_cm_pib);

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі відгуки, які закріплені за поточним користувачем
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT f.fb_id
              FROM feedback f
             WHERE     f.fb_sc = l_sc_Id                   --f.fb_cu = l_Cu_Id
                   AND (p_dt_start IS NULL OR p_dt_start <= f.fb_reg_dt)
                   AND (p_dt_stop IS NULL OR p_dt_stop >= f.fb_reg_dt)
                   AND (p_fb_num IS NULL OR f.fb_reg_num LIKE p_fb_num || '%');

        IF p_cm_pib IS NOT NULL
        THEN
            DELETE FROM Tmp_Work_Ids t
                  WHERE NOT EXISTS
                            (SELECT 1
                               FROM feedback  f
                                    JOIN v_act a ON (a.at_id = f.fb_at)
                              WHERE     f.fb_Id = t.x_Id
                                    AND Ikis_Rbm.Tools.Getcupib (a.at_cu) LIKE
                                            p_cm_pib || '%');
        END IF;

        get_feedback (res_cur);
    END;

    --====================================================--
    -- Перелік відгуків НСП
    -- 1. Дата подання оцінки з
    -- 2. Дата подання оцінки по
    -- 3. Номер оцінки
    -- 4. ПІБ кейс - менеджера
    --====================================================--
    PROCEDURE get_feedback_Pr (p_owner_id   IN     NUMBER,
                               p_dt_start   IN     DATE,
                               p_dt_stop    IN     DATE,
                               p_impres     IN     NUMBER,
                               p_cm_pib     IN     VARCHAR2,
                               res_cur         OUT SYS_REFCURSOR)
    IS
        l_1310    VARCHAR2 (10) := CHR (13) || CHR (10);
        l_Cu_Id   NUMBER;
    BEGIN
        LOG (
            'get_feedback_Pr',
               'p_owner_id='
            || p_owner_id
            || l_1310
            || 'p_dt_start='
            || p_dt_start
            || l_1310
            || 'p_dt_stop='
            || p_dt_stop
            || l_1310
            || 'p_impres='
            || p_impres
            || l_1310
            || 'p_cm_pib='
            || p_cm_pib);

        Write_Audit ('get_feedback_Rc');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі відгуки, які закріплені за поточним користувачем
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT f.fb_id
              FROM feedback f
             WHERE     f.fb_rnspm = p_owner_id
                   AND (p_dt_start IS NULL OR p_dt_start <= f.fb_reg_dt)
                   AND (p_dt_stop IS NULL OR p_dt_stop >= f.fb_reg_dt)
                   AND (p_impres IS NULL OR f.fb_impression = p_impres);

        IF p_cm_pib IS NOT NULL
        THEN
            DELETE FROM Tmp_Work_Ids t
                  WHERE NOT EXISTS
                            (SELECT 1
                               FROM feedback  f
                                    JOIN v_act a ON (a.at_id = f.fb_at)
                              WHERE     f.fb_Id = t.x_Id
                                    AND Ikis_Rbm.Tools.Getcupib (a.at_cu) LIKE
                                            p_cm_pib || '%');
        END IF;

        get_feedback (res_cur);
    END;

    -------------------------------------
    ------------ Кейс менеджер ----------

    -- журнал КМ
    PROCEDURE get_journal_cm (p_dt_start   IN     DATE,
                              p_dt_stop    IN     DATE,
                              p_fb_num     IN     VARCHAR2,
                              res_cur         OUT SYS_REFCURSOR)
    IS
        l_1310   VARCHAR2 (10) := CHR (13) || CHR (10);
        l_cu     NUMBER := ikis_rbm.tools.GetCurrentCu;
    BEGIN
        LOG (
            'get_journal_cm',
               'p_dt_start='
            || p_dt_start
            || l_1310
            || 'p_dt_stop='
            || p_dt_stop
            || l_1310
            || 'p_fb_num='
            || p_fb_num);

        OPEN res_cur FOR
            SELECT t.*,
                   NVL (t.fb_pib, uss_person.api$sc_tools.GET_PIB (t.fb_sc))
                       AS fb_sc_pib,
                   uss_rnsp.api$find.Get_Nsp_Name (t.fb_rnspm)
                       AS fb_rnspm_name,
                   a.at_num
                       AS fb_at_name,
                   tp.DIC_NAME
                       AS Fb_Contact_Tp_Name,
                   rtp.DIC_NAME
                       AS Fb_Rnspm_Tp_Name,
                   st.dic_name
                       AS fb_st_name,
                   NVL (fs.DIC_NAME, t.fb_src)
                       Fb_src_name
              FROM feedback  t
                   LEFT JOIN v_act a ON (a.at_id = t.fb_at)
                   LEFT JOIN uss_ndi.v_ddn_fb_st st
                       ON (st.dic_value = t.fb_st)
                   LEFT JOIN uss_ndi.v_ddn_FB_CONTACT_TP tp
                       ON (tp.dic_value = t.fb_contact_tp)
                   LEFT JOIN uss_ndi.v_ddn_FB_RNSPM_TP rtp
                       ON (rtp.dic_value = t.fb_rnspm_tp)
                   LEFT JOIN uss_ndi.v_ddn_fb_src fs
                       ON (fs.DIC_VALUE = t.fb_src)
             WHERE     t.fb_cu_km = l_cu
                   AND (p_dt_start IS NULL OR p_dt_start <= t.fb_reg_dt)
                   AND (p_dt_stop IS NULL OR p_dt_stop >= t.fb_reg_dt)
                   AND (p_fb_num IS NULL OR t.fb_reg_num LIKE p_fb_num || '%');
    END;

    -- info:   Выбор информации об документах (файлы)
    PROCEDURE GET_DOCS_FILES (P_FB_ID IN NUMBER, P_RES OUT SYS_REFCURSOR)
    IS
    BEGIN
        USS_DOC.API$DOCUMENTS.CLEAR_TMP_WORK_IDS;

        INSERT INTO USS_DOC.TMP_WORK_IDS (X_ID)
            SELECT DISTINCT D.FBD_DH
              FROM fb_document D
             WHERE d.fbd_fb = p_fb_id;

        --отримуємо дані файлів з електронного архіву
        USS_DOC.API$DOCUMENTS.Get_Signed_Attachments (P_RES => P_RES);
    END;

    -- картка відгуку Кейс менеджера
    PROCEDURE get_card_cm (p_fb_id       IN     NUMBER,
                           p_main           OUT SYS_REFCURSOR,
                           p_services       OUT SYS_REFCURSOR,
                           p_questions      OUT SYS_REFCURSOR,
                           p_docs           OUT SYS_REFCURSOR,
                           p_files          OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_main FOR
            SELECT t.*,
                   NVL (t.fb_pib, uss_person.api$sc_tools.GET_PIB (t.fb_sc))
                       AS fb_sc_pib,
                   uss_rnsp.api$find.Get_Nsp_Name (t.fb_rnspm)
                       AS fb_rnspm_name,
                   a.at_num
                       AS fb_at_name,
                   tp.DIC_NAME
                       AS Fb_Contact_Tp_Name,
                   rtp.DIC_NAME
                       AS Fb_Rnspm_Tp_Name,
                   st.dic_name
                       AS fb_st_name,
                   Ikis_Rbm.Tools.Getcupib (NVL (t.fb_cu, a.at_cu))
                       AS cu_pib,
                   Get_Rnsp_Addr_Text (t.fb_rnspa)
                       AS Fb_Rnspa_Text,
                   Ikis_Rbm.Tools.Getcupib (t.fb_cu_km)
                       AS Fb_Cu_Km_Pib,
                   NVL (fs.DIC_NAME, t.fb_src)
                       Fb_src_name
              FROM feedback  t
                   LEFT JOIN v_act a ON (a.at_id = t.fb_at)
                   LEFT JOIN uss_ndi.v_ddn_fb_st st
                       ON (st.dic_value = t.fb_st)
                   LEFT JOIN uss_ndi.v_ddn_FB_CONTACT_TP tp
                       ON (tp.dic_value = t.fb_contact_tp)
                   LEFT JOIN uss_ndi.v_ddn_FB_RNSPM_TP rtp
                       ON (rtp.dic_value = t.fb_rnspm_tp)
                   LEFT JOIN uss_ndi.v_ddn_fb_src fs
                       ON (fs.DIC_VALUE = t.fb_src)
             WHERE t.fb_id = p_fb_id;

        OPEN p_services FOR
            SELECT t.*, s.nst_name AS fbs_nst_name
              FROM fb_service  t
                   JOIN uss_ndi.v_Ndi_Service_Type s
                       ON (s.nst_id = t.fbs_nst)
             WHERE t.fbs_fb = p_fb_id AND t.history_status = 'A';

        OPEN p_questions FOR
            SELECT t.*, s.nda_name AS fbq_nda_name
              FROM fb_question  t
                   JOIN uss_ndi.v_ndi_document_attr s
                       ON (s.nda_id = t.fbq_nda)
             WHERE t.fbq_fb = p_fb_id AND t.history_status = 'A';

        OPEN p_docs FOR
            SELECT t.*, s.ndt_name AS fbd_ndt_name
              FROM fb_document  t
                   JOIN uss_ndi.v_ndi_document_type s
                       ON (s.ndt_id = t.fbd_ndt)
             WHERE t.fbd_fb = p_fb_id AND t.history_status = 'A';

        GET_DOCS_FILES (p_fb_id, p_files);
    END;


    -- картка відгуку
    PROCEDURE get_card (p_fb_id       IN     NUMBER,
                        p_main           OUT SYS_REFCURSOR,
                        p_services       OUT SYS_REFCURSOR,
                        p_questions      OUT SYS_REFCURSOR,
                        p_docs           OUT SYS_REFCURSOR,
                        p_files          OUT SYS_REFCURSOR)
    IS
    BEGIN
        get_card_cm (p_fb_id,
                     p_main,
                     p_services,
                     p_questions,
                     p_docs,
                     p_files);
    END;


    -- відповідь кейс менеджера
    PROCEDURE set_answer_cm (p_fb_id IN NUMBER, p_fb_answer IN VARCHAR2)
    IS
    BEGIN
        UPDATE feedback t
           SET t.fb_answer = p_fb_answer
         WHERE t.fb_id = p_fb_id;
    END;


    FUNCTION Check_Fb_Access (p_Fb_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Cu_Id        NUMBER;
        l_Cu_Sc        NUMBER;
        l_At_Cu        NUMBER;
        l_At_Rnspm     NUMBER;
        l_At_Sc        NUMBER;
        l_At_Ap        NUMBER;
        l_Is_Allowed   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        SELECT a.fb_cu, a.fb_rnspm, a.fb_sc
          INTO l_At_Cu, l_At_Rnspm, l_At_Sc
          FROM feedback a
         WHERE a.fb_id = p_Fb_Id;

        --Дозволено доступ до акту, якщо його закріплено за поточним користувачем
        IF l_At_Cu = l_Cu_Id
        THEN
            RETURN TRUE;
        END IF;

        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (l_Cu_Id);

        --Дозволено доступ до акту, якщо поточний користувач є отримувачем СП
        IF l_At_Sc = l_Cu_Sc
        THEN
            RETURN TRUE;
        END IF;

        --Дозволено доступ до акту, якщо поточний користувач має роль "Уповноважений спеціаліст" в кабінеті надавача за яким закріплено акт
        IF Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
               p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
               p_Cu_Id           => l_Cu_Id,
               p_Cmes_Owner_Id   => l_At_Rnspm,
               p_Cr_Code         => 'NSP_CM')
        THEN
            RETURN TRUE;
        END IF;

        RETURN FALSE;
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА НАЯВНОСТІ ДОСТУПУ ДО ФАЙЛУ
    -----------------------------------------------------------
    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_cmes_id IN NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        Write_Audit ('Check_File_Access');

        FOR Rec
            IN (SELECT                                                /*At.**/
                       fb.fb_id
                  FROM Uss_Doc.v_Files  f
                       JOIN Uss_Doc.v_Doc_Attachments a
                           ON f.File_Id IN (a.Dat_File, a.Dat_Sign_File)
                       JOIN fb_document d ON a.Dat_Dh = d.fbd_dh
                       JOIN feedback fb ON d.fbd_fb = fb.fb_id
                 WHERE f.File_Code = p_File_Code)
        LOOP
            IF Check_Fb_Access (Rec.Fb_Id)
            THEN
                RETURN 'T';
            END IF;
        END LOOP;

        RETURN 'F';
    --RETURN Cmes$act.Check_File_Access(p_File_Code => p_File_Code, p_Cmes_Id => p_cmes_id);
    END;
BEGIN
    NULL;
END CMES$FEEDBACK;
/