/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$AP_PROCESSING
IS
    -- Author  : VANO
    -- Created : 11.06.2021 18:28:03
    -- Purpose : Функції обробки звереннь

    --
    TYPE Type_Rec_Apda IS RECORD
    (
        Rec_Nda           Ap_Document_Attr.Apda_Nda%TYPE,
        Rec_Val_Int       Ap_Document_Attr.Apda_Val_Int%TYPE,
        Rec_Val_Sum       Ap_Document_Attr.Apda_Val_Sum%TYPE,
        Rec_Val_Id        Ap_Document_Attr.Apda_Val_Id%TYPE,
        Rec_Val_Dt        Ap_Document_Attr.Apda_Val_Dt%TYPE,
        Rec_Val_String    Ap_Document_Attr.Apda_Val_String%TYPE
    );

    TYPE Type_Table_Apda IS TABLE OF Type_Rec_Apda;

    FUNCTION Recalc_ap_st (p_Ap_id IN Appeal.Ap_id%TYPE)
        RETURN VARCHAR2;

    PROCEDURE Write_Log_at (p_Apl_Ap        IN Ap_Log.Apl_Ap%TYPE,
                            p_Apl_St        IN Ap_Log.Apl_St%TYPE,
                            p_Apl_Message   IN Ap_Log.Apl_Message%TYPE,
                            p_Apl_St_Old    IN Ap_Log.Apl_St_Old%TYPE,
                            p_Apl_Tp        IN Ap_Log.Apl_Tp%TYPE,
                            p_Wu            IN histsession.hs_wu%TYPE);

    PROCEDURE Write_Log (p_Apl_Ap        IN Ap_Log.Apl_Ap%TYPE,
                         p_Apl_St        IN Ap_Log.Apl_St%TYPE,
                         p_Apl_Message   IN Ap_Log.Apl_Message%TYPE,
                         p_Apl_St_Old    IN Ap_Log.Apl_St_Old%TYPE,
                         p_Apl_Tp        IN Ap_Log.Apl_Tp%TYPE,
                         p_Wu            IN Histsession.Hs_Wu%TYPE,
                         p_Pd_Nst        IN NUMBER DEFAULT NULL,
                         p_Pd_St         IN VARCHAR2 DEFAULT NULL,
                         p_pd_dt         IN DATE DEFAULT NULL,
                         p_pd_start_dt   IN DATE DEFAULT NULL,
                         p_pd_end_dt     IN DATE DEFAULT NULL,
                         p_pd_sum        IN NUMBER DEFAULT NULL);

    PROCEDURE Collect_Ap_For_Execute;

    --#81418
    --У візіті картку заяви надавача, по якій було прийнято рішення «Про повернення на доопрацювання поданих документів»,
    --після проходження 5 робочих днів автоматично переводити у статус «Відхилено».
    PROCEDURE Collect_Ap_For_Close;

    --Передача даних зверненнь до системи ЄСР
    --PROCEDURE Copy_Appeals_To_Esr;--#106772
    PROCEDURE Copy_Full_Ap_To_Esr;

    --Передача даних зверненнь до системи ЄСР за допомогою
    PROCEDURE Copy_Appeals_To_Esr_Schedule (p_Hs Histsession.Hs_Id%TYPE);

    --Передача даних зверненнь до системи ЄСР за допомогою
    PROCEDURE Copy_Appeals_To_Rnsp_Schedule (p_Hs Histsession.Hs_Id%TYPE);

    --Повернення Звернення на довведення
    PROCEDURE Return_Appeal_To_Editing (
        p_Ap_Id       Appeal.Ap_Id%TYPE,
        p_Message     Ap_Log.Apl_Tp%TYPE:= NULL,
        p_Esr_Hs_Wu   Histsession.Hs_Wu%TYPE:= NULL);

    --Повернення Звернення на відхилення
    PROCEDURE return_appeal_to_reject (
        p_ap_id       appeal.ap_id%TYPE,
        p_message     ap_log.apl_tp%TYPE:= NULL,
        p_esr_hs_wu   histsession.hs_wu%TYPE:= NULL);

    --Повернення Звернення на статус "виконано"
    PROCEDURE Return_Appeal_To_Done (
        p_Ap_Id       Appeal.Ap_Id%TYPE,
        p_Message     Ap_Log.Apl_Tp%TYPE:= NULL,
        p_Esr_Hs_Wu   Histsession.Hs_Wu%TYPE:= NULL);

    --Повернення документа "рішення"
    PROCEDURE Create_Document (p_Ap_Id     Appeal.Ap_Id%TYPE,
                               p_Apd_Ndt   Ap_Document.Apd_Ndt%TYPE,
                               p_Apd_Doc   Ap_Document.Apd_Doc%TYPE,
                               p_Apd_Dh    Ap_Document.Apd_Dh%TYPE,
                               p_Com_Wu    Appeal.Com_Wu%TYPE,
                               p_Doc_Atr   SYS_REFCURSOR);

    /*
      --Повернення документа "рішення" для печати
      PROCEDURE Create_Document730(p_Ap_Id   Appeal.Ap_Id%TYPE,
                                   p_Apd_Doc Ap_Document.Apd_Doc%TYPE,
                                   p_Apd_Dh  Ap_Document.Apd_Dh%TYPE,
                                   p_Com_Wu  Appeal.Com_Wu%TYPE,
                                   p_Num     Ap_Document_Attr.Apda_Val_Int%TYPE,
                                   p_Regdate Ap_Document_Attr.Apda_Val_Dt%TYPE);
    */
    PROCEDURE Create_Document730 (p_Ap_Id     Appeal.Ap_Id%TYPE,
                                  p_Apd_Doc   Ap_Document.Apd_Doc%TYPE,
                                  p_Apd_Dh    Ap_Document.Apd_Dh%TYPE,
                                  p_Com_Wu    Appeal.Com_Wu%TYPE,
                                  p_Doc_Atr   SYS_REFCURSOR);

    PROCEDURE Update_Document_Pdf (p_Apd_Id    Ap_Document.Apd_Id%TYPE,
                                   p_Apd_Doc   Ap_Document.Apd_Doc%TYPE,
                                   p_Apd_Dh    Ap_Document.Apd_Dh%TYPE);


    -- info:   Створення документа-рішення
    -- params: p_ap_id - ідентифікатор звернення
    --         p_doc_id - ідентифікатор документа в Е/А
    --         p_dh_id - ідентифікатор зрізу документа в Е/А
    -- note:   #77050
    FUNCTION Create_Decision_Doc (p_Ap_Id    IN Appeal.Ap_Id%TYPE,
                                  p_Doc_Id   IN Ap_Document.Apd_Doc%TYPE,
                                  p_Dh_Id    IN Ap_Document.Apd_Dh%TYPE)
        RETURN NUMBER;

    -- info:   додавання атрибутів документа-рішення
    -- params: p_ap_id - ідентифікатор звернення
    --         p_apd_id - ідентифікатор документа-рішення
    -- note:   #82581
    FUNCTION Add_Decision_Attr (
        p_Ap_Id             Appeal.Ap_Id%TYPE,
        p_Apd_Id            Ap_Document.Apd_Id%TYPE,
        p_Apda_Nda          Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_Int      Ap_Document_Attr.Apda_Val_Int%TYPE,
        p_Apda_Val_Dt       Ap_Document_Attr.Apda_Val_Dt%TYPE,
        p_Apda_Val_String   Ap_Document_Attr.Apda_Val_String%TYPE,
        p_Apda_Val_Id       Ap_Document_Attr.Apda_Val_Id%TYPE,
        p_Apda_Val_Sum      Ap_Document_Attr.Apda_Val_Sum%TYPE)
        RETURN Ap_Document_Attr.Apda_Id%TYPE;

    FUNCTION Get_Visit2esr_Html (p_Ap NUMBER)
        RETURN XMLTYPE;

    -- скасування звернення з превіркою на стан для Є-допомоги
    FUNCTION Cancel_Appeals (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN;

    PROCEDURE Send_Ap_St_Notification (p_Ap_Id     IN NUMBER,
                                       p_Ap_St     IN VARCHAR2,
                                       p_Message   IN VARCHAR2 DEFAULT NULL);
END Api$ap_Processing;
/


GRANT EXECUTE ON USS_VISIT.API$AP_PROCESSING TO II01RC_USS_VISIT_INT
/

GRANT EXECUTE ON USS_VISIT.API$AP_PROCESSING TO IKIS_RBM
/

GRANT EXECUTE ON USS_VISIT.API$AP_PROCESSING TO USS_ESR
/

GRANT EXECUTE ON USS_VISIT.API$AP_PROCESSING TO USS_PERSON
/

GRANT EXECUTE ON USS_VISIT.API$AP_PROCESSING TO USS_RNSP
/

GRANT EXECUTE ON USS_VISIT.API$AP_PROCESSING TO USS_RPT
/


/* Formatted on 8/12/2025 5:59:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$AP_PROCESSING
IS
    FUNCTION Recalc_ap_st (p_Ap_id IN Appeal.Ap_id%TYPE)
        RETURN VARCHAR2
    IS
        l_cnt_R   PLS_INTEGER;
        l_cnt_V   PLS_INTEGER;
        l_cnt_P   PLS_INTEGER;
        l_ap_st   VARCHAR2 (10);
    BEGIN
        SELECT SUM (CASE s.aps_st WHEN 'R' THEN 1 ELSE 0 END)     AS cnt_R,
               SUM (CASE s.aps_st WHEN 'V' THEN 1 ELSE 0 END)     AS cnt_V,
               SUM (CASE s.aps_st WHEN 'P' THEN 1 ELSE 0 END)     AS cnt_P
          INTO l_cnt_R, l_cnt_V, l_cnt_P
          FROM ap_service s JOIN appeal a ON s.aps_ap = a.ap_id
         WHERE     s.aps_ap = p_ap_id
               AND s.history_status = 'A'
               AND (   a.ap_src != 'DIIA'
                    OR (a.ap_src = 'DIIA' AND s.aps_nst != 781))      --#92900
                                                                ;

        CASE
            WHEN l_cnt_R != 0
            THEN
                RETURN NULL;
            WHEN l_cnt_V > 0 AND l_cnt_P > 0
            THEN
                l_ap_st := 'PV';
            WHEN l_cnt_V = 0 AND l_cnt_P > 0
            THEN
                l_ap_st := 'V';
            WHEN l_cnt_V > 0 AND l_cnt_P = 0
            THEN
                l_ap_st := 'D';
            ELSE
                RETURN NULL;
        END CASE;

           UPDATE appeal
              SET ap_st =
                      CASE
                          WHEN l_ap_st = 'D' AND ap_tp = 'IA' THEN 'X'
                          ELSE l_ap_st
                      END
            WHERE ap_id = p_Ap_id
        RETURNING ap_st
             INTO l_ap_st;

        UPDATE uss_esr.appeal
           SET ap_st =
                   CASE
                       WHEN l_ap_st = 'D' AND ap_tp = 'IA' THEN 'X'
                       ELSE l_ap_st
                   END
         WHERE ap_id = p_Ap_id;

        RETURN l_ap_st;
    END;

    PROCEDURE Write_Log_at (p_Apl_Ap        IN Ap_Log.Apl_Ap%TYPE,
                            p_Apl_St        IN Ap_Log.Apl_St%TYPE,
                            p_Apl_Message   IN Ap_Log.Apl_Message%TYPE,
                            p_Apl_St_Old    IN Ap_Log.Apl_St_Old%TYPE,
                            p_Apl_Tp        IN Ap_Log.Apl_Tp%TYPE,
                            p_Wu            IN histsession.hs_wu%TYPE)
    IS
        l_hs      histsession.hs_id%TYPE;
        l_wu      histsession.hs_wu%TYPE;
        --appeal_count  NUMBER;
        l_ap_st   VARCHAR2 (10);
        l_ap_tp   VARCHAR2 (10);
        l_IsPFU   PLS_INTEGER;
    BEGIN
        IF p_wu IS NULL
        THEN
            SELECT MAX (h.hs_wu)
              INTO l_WU
              FROM VISIT2ESR_ACTIONS  vea
                   JOIN histsession h ON h.hs_id = vea.vea_hs_ins
             WHERE vea.vea_ap = p_apl_ap AND vea_hs_exec = -1;
        ELSE
            l_wu := p_wu;
        END IF;

        l_hs := TOOLS.GetHistSession (p_WU);

        SELECT MAX (ap_tp)
          INTO l_ap_tp
          FROM appeal
         WHERE ap_id = p_Apl_Ap;

        IF l_ap_tp IS NULL
        THEN
            RETURN;
        END IF;

        IF p_Apl_Message LIKE CHR (38) || '153#%'
        THEN
            UPDATE appeal
               SET ap_st = 'V'
             WHERE ap_id = p_Apl_Ap;

            UPDATE uss_esr.appeal
               SET ap_st = 'V'
             WHERE ap_id = p_Apl_Ap;
        END IF;



        api$appeal.Write_Log (p_Apl_Ap,
                              l_hs,
                              NVL (l_ap_st, p_Apl_St),
                              p_Apl_Message,
                              p_Apl_St_Old,
                              p_Apl_Tp);
    END;

    PROCEDURE Write_Log (p_Apl_Ap        IN Ap_Log.Apl_Ap%TYPE,
                         p_Apl_St        IN Ap_Log.Apl_St%TYPE,
                         p_Apl_Message   IN Ap_Log.Apl_Message%TYPE,
                         p_Apl_St_Old    IN Ap_Log.Apl_St_Old%TYPE,
                         p_Apl_Tp        IN Ap_Log.Apl_Tp%TYPE,
                         p_Wu            IN histsession.hs_wu%TYPE,
                         p_pd_nst        IN NUMBER DEFAULT NULL,
                         p_pd_st         IN VARCHAR2 DEFAULT NULL,
                         p_pd_dt         IN DATE DEFAULT NULL,
                         p_pd_start_dt   IN DATE DEFAULT NULL,
                         p_pd_end_dt     IN DATE DEFAULT NULL,
                         p_pd_sum        IN NUMBER DEFAULT NULL)
    IS
        l_hs      histsession.hs_id%TYPE;
        l_wu      histsession.hs_wu%TYPE;
        --appeal_count  NUMBER;
        l_ap_st   VARCHAR2 (10);
        l_ap_tp   VARCHAR2 (10);
        l_IsPFU   PLS_INTEGER;
    BEGIN
        --l_hs := COALESCE( p_Apl_Hs, TOOLS.GetHistSession(p_WU));
        IF p_wu IS NULL
        THEN
            SELECT MAX (h.hs_wu)
              INTO l_WU
              FROM VISIT2ESR_ACTIONS  vea
                   JOIN histsession h ON h.hs_id = vea.vea_hs_ins
             WHERE vea.vea_ap = p_apl_ap AND vea_hs_exec = -1;
        ELSE
            l_wu := p_wu;
        END IF;

        l_hs := TOOLS.GetHistSession (p_WU);

        SELECT MAX (ap_tp)
          INTO l_ap_tp
          FROM appeal
         WHERE ap_id = p_Apl_Ap;

        IF l_ap_tp IS NULL
        THEN
            RETURN;
        END IF;

        IF p_pd_nst IS NOT NULL AND NVL (p_pd_st, '-1') IN ('AM')
        THEN
               UPDATE appeal
                  SET ap_st = 'NS'
                WHERE ap_id = p_Apl_Ap
            RETURNING ap_st
                 INTO l_ap_st;

            UPDATE uss_esr.appeal
               SET ap_st = 'NS'
             WHERE ap_id = p_Apl_Ap;
        ELSIF p_pd_nst IN (1141) AND NVL (p_pd_st, '-') IN ('P')
        THEN
            UPDATE ap_service
               SET aps_st = 'P'                                   --Призначено
             WHERE aps_ap = p_Apl_Ap AND history_status = 'A';

            UPDATE uss_esr.ap_service
               SET aps_st = 'P'                                   --Призначено
             WHERE aps_ap = p_Apl_Ap AND history_status = 'A';

            l_ap_st := Recalc_ap_st (p_Apl_Ap);
        ELSIF     l_ap_tp IN ('R.OS', 'R.GS')
              AND NVL (p_pd_st, '-1') IN ('S', 'F')
        THEN
            UPDATE ap_service
               SET aps_st =
                       (CASE
                            WHEN p_pd_st IN ('F') THEN 'V'       -- Відмовлено
                            WHEN p_pd_st IN ('S') THEN 'P'        --Призначено
                        END)
             WHERE                    /*aps_nst = p_pd_nst
                                      AND*/
                   aps_ap = p_Apl_Ap AND history_status = 'A';

            UPDATE uss_esr.ap_service
               SET aps_st =
                       (CASE
                            WHEN p_pd_st IN ('F') THEN 'V'       -- Відмовлено
                            WHEN p_pd_st IN ('S') THEN 'P'        --Призначено
                        END)
             WHERE                    /*aps_nst = p_pd_nst
                                      AND*/
                   aps_ap = p_Apl_Ap AND history_status = 'A';

            l_ap_st := Recalc_ap_st (p_Apl_Ap);
        ELSIF l_ap_tp IN ('R.OS') AND p_Apl_Message LIKE CHR (38) || '153#%'
        THEN
            --#111840
            UPDATE appeal
               SET ap_st = 'V'
             WHERE ap_id = p_Apl_Ap;

            UPDATE uss_esr.appeal
               SET ap_st = 'V'
             WHERE ap_id = p_Apl_Ap;
        ELSIF     p_pd_nst IS NOT NULL
              AND l_ap_tp = 'SS'
              AND NVL (p_pd_st, '-1') IN ('V',
                                          'O.V',
                                          'P',
                                          'O.P',
                                          'S')
        THEN
            UPDATE ap_service
               SET aps_st =
                       (CASE
                            WHEN p_pd_st IN ('V', 'O.V') THEN 'V' -- Відмовлено
                            WHEN p_pd_st IN ('P', 'O.P', 'S') THEN 'P' --Призначено
                        END)
             WHERE     aps_nst = p_pd_nst
                   AND aps_ap = p_Apl_Ap
                   AND history_status = 'A';

            UPDATE uss_esr.ap_service
               SET aps_st =
                       (CASE
                            WHEN p_pd_st IN ('V', 'O.V') THEN 'V' -- Відмовлено
                            WHEN p_pd_st IN ('P', 'O.P', 'S') THEN 'P' --Призначено
                        END)
             WHERE     aps_nst = p_pd_nst
                   AND aps_ap = p_Apl_Ap
                   AND history_status = 'A';

            l_ap_st := Recalc_ap_st (p_Apl_Ap);
        ELSIF     p_pd_nst IS NOT NULL
              AND l_ap_tp != 'O'
              AND NVL (p_pd_st, '-1') IN ('V',
                                          'O.V',
                                          'O.P',
                                          'S')
        THEN
            UPDATE ap_service
               SET aps_st =
                       (CASE
                            WHEN p_pd_st IN ('V', 'O.V') THEN 'V' -- Відмовлено
                            WHEN p_pd_st IN ('P', 'O.P', 'S') THEN 'P' --Призначено
                        END)
             WHERE     aps_nst = p_pd_nst
                   AND aps_ap = p_Apl_Ap
                   AND history_status = 'A';

            UPDATE uss_esr.ap_service
               SET aps_st =
                       (CASE
                            WHEN p_pd_st IN ('V', 'O.V') THEN 'V' -- Відмовлено
                            WHEN p_pd_st IN ('O.P', 'S') THEN 'P' --Призначено
                        END)
             WHERE     aps_nst = p_pd_nst
                   AND aps_ap = p_Apl_Ap
                   AND history_status = 'A';

            l_ap_st := Recalc_ap_st (p_Apl_Ap);
        ELSIF     p_pd_nst IS NOT NULL
              AND l_ap_tp = 'O'
              AND NVL (p_pd_st, '-1') IN ('PS')
        THEN
            UPDATE ap_service
               SET aps_st = 'P'                                   --Призначено
             WHERE     aps_nst = 642
                   AND aps_ap = p_Apl_Ap
                   AND history_status = 'A';

            UPDATE uss_esr.ap_service
               SET aps_st = 'P'                                   --Призначено
             WHERE     aps_nst = 642
                   AND aps_ap = p_Apl_Ap
                   AND history_status = 'A';

            l_ap_st := Recalc_ap_st (p_Apl_Ap);
        ELSIF     p_pd_nst IS NOT NULL
              AND l_ap_tp = 'O'
              AND NVL (p_pd_st, '-1') IN ('S')
        THEN
            UPDATE ap_service
               SET aps_st = 'P'                                   --Призначено
             WHERE                         /*aps_nst = 641
                                           AND*/
                   aps_ap = p_Apl_Ap AND history_status = 'A';

            UPDATE uss_esr.ap_service
               SET aps_st = 'P'                                   --Призначено
             WHERE                         /*aps_nst = 641
                                           AND*/
                   aps_ap = p_Apl_Ap AND history_status = 'A';

            l_ap_st := Recalc_ap_st (p_Apl_Ap);
        /*
            ELSIF p_pd_nst IS NOT NULL AND nvl(p_pd_st,'-1') IN ('PS')  THEN

                UPDATE ap_service SET
                       aps_st = 'P' --Призначено
                WHERE aps_nst = 642
                      AND aps_ap = p_Apl_Ap
                      AND history_status = 'A';

                UPDATE uss_esr.ap_service SET
                       aps_st = 'P' --Призначено
                WHERE aps_nst = 642
                      AND aps_ap = p_Apl_Ap
                      AND history_status = 'A';

                l_ap_st := Recalc_ap_st(p_Apl_Ap);
        */
        END IF;

        IF l_ap_st IN ('V', 'D')
        THEN
            uss_visit.dnet$community.Reg_Appeal_Status_Send (p_Apl_Ap);
        END IF;

        --Відправляємо в Дію запит про зміну статуса
        Dnet$appeal_Ext.Reg_Diia_Status_Send_Req (
            p_Ap_Id         => p_Apl_Ap,
            p_Ap_St         => NVL (l_ap_st, p_Apl_St),
            p_Message       => p_Apl_Message,
            p_Decision_Dt   => p_pd_dt,
            p_Start_Dt      => p_pd_start_dt,
            p_Stop_Dt       => p_pd_end_dt,
            p_Sum           => p_pd_sum);
        --Відправляємо в ДРАЦС запит про зміну статуса
        Dnet$exch_Mju.Reg_Dracs_Application_Result_Req (
            p_Ap_Id     => p_Apl_Ap,
            p_Ap_St     => NVL (l_ap_st, p_Apl_St),
            p_Message   => p_Apl_Message);
        --Відправляємо заявнику повідомлення про зміну статуса
        Send_Ap_St_Notification (p_Ap_Id     => p_Apl_Ap,
                                 p_Ap_St     => l_ap_st,
                                 p_message   => p_Apl_Message);

        --Для відправки в ПФУ

        SELECT COUNT (1)
          INTO l_IsPFU
          FROM uss_visit.appeal, uss_visit.ap_service
         WHERE     aps_ap = ap_id
               AND AP_TP = 'D'
               AND aps_nst = 981
               AND ap_id = p_Apl_Ap;

        IF l_IsPFU > 0
        THEN
            api$appeal.Write_Log (
                p_Apl_Ap,
                l_hs,
                NVL (l_ap_st, p_Apl_St),
                'uss_visit.dnet$exch_uss2ikis.Reg_Appeal_Bnf01_Send(p_ap_id =>p_Apl_Ap);',
                p_Apl_St_Old,
                p_Apl_Tp);
            uss_visit.dnet$exch_uss2ikis.Reg_Appeal_Bnf01_Send (
                p_ap_id   => p_Apl_Ap);
        END IF;

        api$appeal.Write_Log (p_Apl_Ap,
                              l_hs,
                              NVL (l_ap_st, p_Apl_St),
                              p_Apl_Message,
                              p_Apl_St_Old,
                              p_Apl_Tp);
    /*
    Якщо для послуги рішення по послузі набуло статусу V (відмовлено) таблиця V_DDN_PD_ST, то статус послуги=V (відмовлено) таблиця V_DDN_APS_ST;
    Якщо для послуги рішення по послузі набуло статусу S (нараховано) таблиця V_DDN_PD_ST, то статус послуги=P (призначено) таблиця V_DDN_APS_ST;

    Якщо у зверненні з типом "Допомога" всі послуги набули значення V і Р, то звернення переводити у статус V (Виконано) таблиця V_DDN_AP_S
    */

    END;

    PROCEDURE collect_ap_for_execute
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --#78995 2022.08.01
        IF ikis_sys.ikis_parameter_util.getparameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT ap_id
              FROM appeal
             WHERE ap_st = 'VO' AND ap_tp = 'D' AND ap_src IN ('USS');

        IF SQL%ROWCOUNT > 0
        THEN
            UPDATE appeal
               SET ap_st = 'FD'
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE ap_id = x_id);

            l_hs := tools.gethistsession ();

            INSERT INTO ap_log (apl_id,
                                apl_ap,
                                apl_hs,
                                apl_st,
                                apl_st_old,
                                apl_message,
                                apl_tp)
                SELECT 0,
                       ap_id,
                       l_hs,
                       ap_st,
                       'VO',
                       CHR (38) || '5',
                       'SYS'
                  FROM appeal, tmp_work_ids
                 WHERE ap_id = x_id;

            FOR rec
                IN (SELECT aps_id     AS x_aps,
                           app_id     AS x_app,
                           nrc_id     AS x_nrc,
                           app_inn,
                           app_doc_num,
                           app_ln,
                           app_fn,
                           app_mn,
                           app_sc,
                           nrc_remote_code
                      FROM tmp_work_ids,
                           appeal,
                           ap_person                     app,
                           ap_service                    aps,
                           uss_ndi.v_ndi_request_config  nrc
                     WHERE     ap_id = x_id
                           AND app_ap = ap_id
                           AND aps_ap = ap_id
                           AND aps_nst = nrc_nst
                           AND nrc_tp = 'EDOV'
                           AND ap_tp = nrc_ap_tp
                           AND app_tp = nrc_app_tp
                           AND app.history_status = 'A'
                           AND aps.history_status = 'A')
            LOOP
                DECLARE
                    l_ape_id   ap_execution.ape_id%TYPE;
                BEGIN
                    SELECT MAX (ape_id)
                      INTO l_ape_id
                      FROM ap_execution
                     WHERE     ape_app = rec.x_app
                           AND ape_aps = rec.x_aps
                           AND ape_nrc = rec.x_nrc;

                    IF l_ape_id IS NULL
                    THEN
                        INSERT INTO ap_execution (ape_id,
                                                  ape_aps,
                                                  ape_app,
                                                  ape_nrc,
                                                  ape_st)
                             VALUES (0,
                                     rec.x_aps,
                                     rec.x_app,
                                     rec.x_nrc,
                                     'R')
                          RETURNING ape_id
                               INTO l_ape_id;
                    ELSE
                        UPDATE ap_execution
                           SET ape_ext_ident = NULL, ape_st = 'R'
                         WHERE ape_id = l_ape_id;
                    END IF;

                    --Реєструємо запит на реєстрацію звернення в ПФУ
                    dnet$exch_uss2ikis.reg_visit_req (
                        p_ur_ext_id    => l_ape_id,
                        p_sc_id        => rec.app_sc,
                        p_visit_tp     => rec.nrc_remote_code,
                        p_numident     => rec.app_inn,
                        p_ln           => rec.app_ln,
                        p_fn           => rec.app_fn,
                        p_mn           => rec.app_mn,
                        p_doc_number   => rec.app_doc_num);
                END;
            END LOOP;

            FOR xx
                IN (SELECT x_id,
                           ap_st,
                           (SELECT COUNT (*)
                              FROM ap_service, ap_execution
                             WHERE ape_aps = aps_id AND aps_ap = x_id)    AS cnt
                      FROM tmp_work_ids JOIN appeal ON ap_id = x_id
                     --звернення не передається на виконання в РНСП
                     WHERE NOT EXISTS
                               (SELECT 1
                                  FROM ap_service
                                 WHERE     aps_ap = x_id
                                       AND aps_nst = 701
                                       AND history_status = 'A'))
            LOOP
                IF xx.cnt = 0
                THEN
                    UPDATE appeal
                       SET ap_st = 'V'
                     WHERE ap_id = xx.x_id;

                    --#73983 2021.12.09
                    api$appeal.write_log (p_apl_ap        => xx.x_id,
                                          p_apl_hs        => l_hs,
                                          p_apl_st        => 'V',
                                          p_apl_message   => CHR (38) || '10',
                                          p_apl_st_old    => xx.ap_st);
                /*
                        INSERT INTO ap_log (apl_id, apl_ap, apl_hs, apl_st, apl_st_old, apl_message, apl_tp)
                          SELECT 0, ap_id, l_hs, ap_st, 'FD', CHR(38)||'10', 'SYS'
                          FROM appeal
                          WHERE ap_id = xx.x_id;
                */
                END IF;
            END LOOP;
        END IF;
    END;

    --#81418
    --У візіті картку заяви надавача, по якій було прийнято рішення «Про повернення на доопрацювання поданих документів»,
    --після проходження 5 робочих днів автоматично переводити у статус «Відхилено».
    PROCEDURE collect_ap_for_Close
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --#78995 2022.08.01
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT ap_id
              FROM (  SELECT ap_id, MAX (h.hs_dt) hs_dt
                        FROM appeal
                             JOIN ap_log l
                                 ON l.apl_ap = ap_id AND l.apl_st = 'B'
                             JOIN histsession h ON h.hs_id = l.apl_hs
                       WHERE ap_st = 'B' AND ap_tp = 'G'
                    GROUP BY ap_id)
             WHERE (SELECT COUNT (1)
                      FROM uss_ndi.v_ndi_calendar_base ncb
                     WHERE     ncb.ncb_work_tp = 'W'
                           AND ncb.ncb_dt BETWEEN TRUNC (hs_dt)
                                              AND TRUNC (SYSDATE)) >
                   5;

        IF SQL%ROWCOUNT > 0
        THEN
            l_hs := TOOLS.GetHistSession ();

            UPDATE uss_visit.appeal
               SET ap_st = 'X'
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE ap_id = x_id);

            /*
                  UPDATE uss_esr.appeal SET
                    ap_st = 'X'
                  WHERE EXISTS (SELECT 1 FROM tmp_work_ids WHERE ap_id = x_id);
            */
            UPDATE uss_rnsp.appeal
               SET ap_st = 'X'
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE ap_id = x_id);

            INSERT INTO ap_log (apl_id,
                                apl_ap,
                                apl_hs,
                                apl_st,
                                apl_st_old,
                                apl_message,
                                apl_tp)
                SELECT 0,
                       ap_id,
                       l_hs,
                       ap_st,
                       'B',
                       CHR (38) || '133',
                       'SYS'
                  FROM appeal JOIN tmp_work_ids ON ap_id = x_id;
        END IF;

        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT ap_id
              FROM (  SELECT ap_id, MAX (h.hs_dt) hs_dt
                        FROM appeal
                             JOIN ap_log l
                                 ON l.apl_ap = ap_id AND l.apl_st = 'B'
                             JOIN histsession h ON h.hs_id = l.apl_hs
                       WHERE ap_st = 'B' AND ap_tp = 'SS'
                    GROUP BY ap_id)
             WHERE SYSDATE - hs_dt > 30;

        IF SQL%ROWCOUNT > 0
        THEN
            l_hs := NVL (l_hs, TOOLS.GetHistSession ());

            UPDATE uss_visit.appeal
               SET ap_st = 'X'
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE ap_id = x_id);

            UPDATE uss_esr.appeal
               SET ap_st = 'X'
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE ap_id = x_id);

            INSERT INTO ap_log (apl_id,
                                apl_ap,
                                apl_hs,
                                apl_st,
                                apl_st_old,
                                apl_message,
                                apl_tp)
                SELECT 0,
                       ap_id,
                       l_hs,
                       ap_st,
                       'B',
                       CHR (38) || '147',
                       'SYS'
                  FROM appeal JOIN tmp_work_ids ON ap_id = x_id;
        END IF;
    END;


    PROCEDURE copy_full_ap_to_esr
    IS
        l_xmldata   XMLTYPE;
    BEGIN
        BEGIN
            DELETE FROM tmp_work_ids1
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids1 (x_id)
                SELECT ap_vf     AS x_vf
                  FROM tmp_work_ids, appeal
                 WHERE x_id = ap_id
                UNION
                SELECT app_vf
                  FROM tmp_work_ids, ap_person
                 WHERE x_id = app_ap AND history_status = 'A'
                UNION
                SELECT apd_vf
                  FROM tmp_work_ids, ap_document
                 WHERE x_id = apd_ap AND history_status = 'A';


            FOR xx IN (SELECT x_id FROM tmp_work_ids1)
            LOOP
                MERGE INTO uss_esr.verification
                     USING (    SELECT vf_id
                                           AS x_vf_id,
                                       vf_vf_main
                                           AS x_vf_vf_main,
                                       vf_tp
                                           AS x_vf_tp,
                                       vf_st
                                           AS x_vf_st,
                                       vf_start_dt
                                           AS x_vf_start_dt,
                                       vf_stop_dt
                                           AS x_vf_stop_dt,
                                       vf_expected_stop_dt
                                           AS x_vf_expected_stop_dt,
                                       vf_nvt
                                           AS x_vf_nvt,
                                       vf_obj_tp
                                           AS x_vf_obj_tp,
                                       vf_obj_id
                                           AS x_vf_obj_id,
                                       vf_hs
                                           AS x_vf_hs,
                                       vf_hs_rewrite
                                           AS x_vf_hs_rewrite,
                                       vf_own_st
                                           AS x_vf_own_st,
                                       vf_plan_dt
                                           AS x_vf_plan_dt
                                  FROM verification
                            START WITH vf_id = xx.x_id
                            CONNECT BY PRIOR vf_id = vf_vf_main)
                        ON (vf_id = x_vf_id)
                WHEN MATCHED
                THEN
                    UPDATE SET vf_vf_main = x_vf_vf_main,
                               vf_tp = x_vf_tp,
                               vf_st = x_vf_st,
                               vf_start_dt = x_vf_start_dt,
                               vf_stop_dt = x_vf_stop_dt,
                               vf_expected_stop_dt = x_vf_expected_stop_dt,
                               vf_nvt = x_vf_nvt,
                               vf_obj_tp = x_vf_obj_tp,
                               vf_obj_id = x_vf_obj_id,
                               vf_hs = x_vf_hs,
                               vf_hs_rewrite = x_vf_hs_rewrite,
                               vf_own_st = x_vf_own_st,
                               vf_plan_dt = x_vf_plan_dt
                WHEN NOT MATCHED
                THEN
                    INSERT     (vf_id,
                                vf_vf_main,
                                vf_tp,
                                vf_st,
                                vf_start_dt,
                                vf_stop_dt,
                                vf_expected_stop_dt,
                                vf_nvt,
                                vf_obj_tp,
                                vf_obj_id,
                                vf_hs,
                                vf_hs_rewrite,
                                vf_own_st,
                                vf_plan_dt)
                        VALUES (x_vf_id,
                                x_vf_vf_main,
                                x_vf_tp,
                                x_vf_st,
                                x_vf_start_dt,
                                x_vf_stop_dt,
                                x_vf_expected_stop_dt,
                                x_vf_nvt,
                                x_vf_obj_tp,
                                x_vf_obj_id,
                                x_vf_hs,
                                x_vf_hs_rewrite,
                                x_vf_own_st,
                                x_vf_plan_dt);

                MERGE INTO uss_esr.vf_log
                     USING (SELECT vfl_id          AS x_vfl_id,
                                   vfl_vf          AS x_vfl_vf,
                                   vfl_message     AS x_vfl_message,
                                   vfl_tp          AS x_vfl_tp,
                                   vfl_hs          AS x_vfl_hs,
                                   vfl_dt          AS x_vfl_dt
                              FROM vf_log,
                                   (    SELECT vf_id     AS x_vf_id
                                          FROM verification
                                    START WITH vf_id = xx.x_id
                                    CONNECT BY PRIOR vf_id = vf_vf_main)
                             WHERE vfl_vf = x_vf_id)
                        ON (vfl_id = x_vfl_id)
                WHEN MATCHED
                THEN
                    UPDATE SET vfl_vf = x_vfl_vf,
                               vfl_message = x_vfl_message,
                               vfl_tp = x_vfl_tp,
                               vfl_hs = x_vfl_hs,
                               vfl_dt = x_vfl_dt
                WHEN NOT MATCHED
                THEN
                    INSERT     (vfl_id,
                                vfl_vf,
                                vfl_message,
                                vfl_tp,
                                vfl_hs,
                                vfl_dt)
                        VALUES (x_vfl_id,
                                x_vfl_vf,
                                x_vfl_message,
                                x_vfl_tp,
                                x_vfl_hs,
                                x_vfl_dt);
            END LOOP;
        --  EXCEPTION
        --    WHEN others THEN
        --      NULL;
        END;

        MERGE INTO uss_esr.appeal
             USING (SELECT ap_id                AS x_ap_id,
                           ap_id                AS x_ap_src_id,
                           ap_num               AS x_ap_num,
                           ap_reg_dt            AS x_ap_reg_dt,
                           ap_src               AS x_ap_src,
                           --CASE --#106929
                           --WHEN (SELECT COUNT(1) FROM ap_service aps WHERE aps_ap = ap_id AND aps_nst = 1201 AND aps.history_status = 'A') > 0
                           --  THEN 'WD'
                           --ELSE
                           --  'O'
                           --END AS x_ap_st,
                           'O'                  AS x_ap_st,
                           CASE                                      -- #94398
                               WHEN (SELECT MAX (t.org_to)
                                       FROM v_opfu t
                                      WHERE     t.org_st = 'A'
                                            AND t.org_id = com_org) =
                                    35
                               THEN
                                   ap_dest_org
                               ELSE
                                   com_org
                           END                  AS v_com_org,
                           --com_org AS v_com_org,
                           ap_is_second         AS x_ap_is_second,
                           com_wu               AS v_com_wu,
                           ap_tp                AS x_ap_tp,
                           ap_sub_tp            AS x_ap_sub_tp,
                           ap_ext_ident         AS x_ap_ext_ident,
                           ap_vf                AS x_ap_vf,
                           ap_is_ext_process    AS x_ap_is_ext_process,
                           ap_ext_ident2        AS x_ap_ext_ident2,
                           ap_dest_org          AS x_ap_dest_org,
                           ap_cu                AS x_ap_cu,
                           ap_create_dt         AS x_ap_create_dt,
                           ap_ap_main           AS x_ap_ap_main
                      /*,
                      (SELECT MAX(pc_id)
                       FROM uss_esr.v_personalcase, ap_person zz
                       WHERE app_ap = ap_id
                         AND app_sc = pc_sc
                         AND zz.history_status = 'A'
                         AND app_tp IN ('Z', 'O')) AS x_ap_pc*/
                      --!!!Якщо не знайдено - повинні одразу створитись після копіювання зверненнь - людина звернулась в перший раз
                      FROM appeal, tmp_work_ids
                     WHERE ap_id = x_id)
                ON (ap_id = x_ap_id)
        WHEN MATCHED
        THEN
            UPDATE SET                                      --ap_pc = x_ap_pc,
                       ap_src_id = x_ap_src_id,
                       ap_tp = x_ap_tp,
                       ap_sub_tp = x_ap_sub_tp,
                       ap_reg_dt = x_ap_reg_dt,
                       ap_src = x_ap_src,
                       ap_st = x_ap_st,
                       com_org = v_com_org,
                       ap_is_second = x_ap_is_second,
                       com_wu = v_com_wu,
                       --ap_ext_ident = x_ap_ext_ident,
                       ap_ext_ident2 = x_ap_ext_ident2,
                       ap_num = x_ap_num,
                       ap_vf = x_ap_vf,
                       ap_is_ext_process = x_ap_is_ext_process,
                       ap_dest_org = x_ap_dest_org,
                       ap_cu = x_ap_cu,
                       ap_create_dt = x_ap_create_dt,
                       ap_ap_main = x_ap_ap_main
        WHEN NOT MATCHED
        THEN
            INSERT     (ap_id,                                      /*ap_pc,*/
                        ap_src_id,
                        ap_tp,
                        ap_sub_tp,
                        ap_reg_dt,
                        ap_src,
                        ap_st,
                        com_org,
                        ap_is_second,
                        com_wu,                              /*ap_ext_ident,*/
                        ap_num,
                        ap_vf,
                        ap_is_ext_process,
                        ap_ext_ident2,
                        ap_dest_org,
                        ap_cu,
                        ap_create_dt,
                        ap_ap_main)
                VALUES (x_ap_id,                                  /*x_ap_pc,*/
                        x_ap_src_id,
                        x_ap_tp,
                        x_ap_sub_tp,
                        x_ap_reg_dt,
                        x_ap_src,
                        x_ap_st,
                        v_com_org,
                        x_ap_is_second,
                        v_com_wu,                          /*x_ap_ext_ident,*/
                        x_ap_num,
                        x_ap_vf,
                        x_ap_is_ext_process,
                        x_ap_ext_ident2,
                        x_ap_dest_org,
                        x_ap_cu,
                        x_ap_create_dt,
                        x_ap_ap_main);

        --#105819
        UPDATE uss_esr.appeal dst
           SET dst.ap_st = 'V'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_ids, appeal src, appeal mn
                     WHERE     src.ap_id = x_id
                           AND src.ap_ap_main = mn.ap_id
                           AND mn.ap_st = 'V'
                           AND dst.ap_id = mn.ap_id);


        /*  INSERT INTO uss_esr.appeal (ap_id, ap_src_id, ap_num, ap_reg_dt,
                                      ap_src, ap_st, com_org, ap_is_second,
                                      com_wu, ap_tp, ap_ext_ident,
                                      ap_pc)
            SELECT ap_id, ap_id, ap_num, ap_reg_dt,
                   ap_src, 'O', com_org, ap_is_second,
                   com_wu, ap_tp, ap_ext_ident,
                   (SELECT pc_id
                    FROM uss_esr.v_personalcase, ap_person
                    WHERE app_ap = ap_id
                      AND app_sc = pc_sc
                      AND app_tp = 'Z') --!!!Якщо не знайдено - повинні одразу створитись після копіювання зверненнь - людина звернулась в перший раз
            FROM appeal, tmp_work_ids
            WHERE ap_id = x_id;*/

        MERGE INTO uss_esr.ap_service
             USING (SELECT aps_id             AS x_aps_id,
                           aps_ap             AS x_aps_ap,
                           aps_st             AS x_aps_st,
                           history_status     AS x_history_status,
                           aps_nst            AS x_aps_nst
                      FROM ap_service, tmp_work_ids
                     WHERE aps_ap = x_id)
                ON (aps_id = x_aps_id)
        WHEN MATCHED
        THEN
            UPDATE SET aps_ap = x_aps_ap,
                       aps_st = x_aps_st,
                       history_status = x_history_status,
                       aps_nst = x_aps_nst
        WHEN NOT MATCHED
        THEN
            INSERT     (aps_id,
                        aps_ap,
                        aps_st,
                        history_status,
                        aps_nst)
                VALUES (x_aps_id,
                        x_aps_ap,
                        x_aps_st,
                        x_history_status,
                        x_aps_nst);

        /*INSERT INTO uss_esr.ap_service (aps_id, aps_nst, aps_ap, aps_st, history_status)
          SELECT aps_id, aps_nst, aps_ap, aps_st, history_status
          FROM ap_service, tmp_work_ids
          WHERE aps_ap = x_id;*/

        --#APP_NUM
        MERGE INTO uss_esr.ap_person
             USING (SELECT app_id            AS x_app_id,
                           app_ap            AS x_app_ap,
                           app_sc            AS x_app_sc,
                           app_tp            AS x_app_tp,
                           history_status    AS x_history_status,
                           sc_scc            AS x_sc_scc,
                           app_num           AS x_app_num,
                           (CASE history_status
                                WHEN 'A' THEN app_vf
                                ELSE NULL
                            END)             AS x_app_vf
                      FROM tmp_work_ids
                           JOIN ap_person ON app_ap = x_id
                           LEFT JOIN uss_person.v_socialcard
                               ON sc_id = app_sc)
                ON (app_id = x_app_id)
        WHEN MATCHED
        THEN
            UPDATE SET app_ap = x_app_ap,
                       app_sc = x_app_sc,
                       app_tp = x_app_tp,
                       history_status = x_history_status,
                       app_vf = x_app_vf,
                       app_scc = x_sc_scc,
                       app_num = x_app_num
        WHEN NOT MATCHED
        THEN
            INSERT     (app_id,
                        app_ap,
                        app_sc,
                        app_tp,
                        history_status,
                        app_vf,
                        app_scc,
                        app_num)
                VALUES (x_app_id,
                        x_app_ap,
                        x_app_sc,
                        x_app_tp,
                        x_history_status,
                        x_app_vf,
                        x_sc_scc,
                        x_app_num);

        /*INSERT INTO uss_esr.ap_person (app_id, app_ap, app_tp, history_status, app_sc)
          SELECT app_id, app_ap, app_tp, history_status, app_sc
          FROM ap_person, tmp_work_ids
          WHERE app_ap = x_id;*/

        MERGE INTO uss_esr.ap_payment
             USING (SELECT apm_id               AS x_apm_id,
                           apm_ap               AS x_apm_ap,
                           apm_aps              AS x_apm_aps,
                           apm_app              AS x_apm_app,
                           apm_kaot             AS x_apm_kaot,
                           apm_nb               AS x_apm_nb,
                           apm_tp               AS x_apm_tp,
                           apm_index            AS x_apm_index,
                           apm_account          AS x_apm_account,
                           apm_need_account     AS x_apm_need_account,
                           history_status       AS x_history_status,
                           apm_street           AS x_apm_street,
                           apm_ns               AS x_apm_ns,
                           apm_building         AS x_apm_building,
                           apm_block            AS x_apm_block,
                           apm_apartment        AS x_apm_apartment,
                           apm_dppa             AS x_apm_dppa
                      FROM ap_payment, tmp_work_ids
                     WHERE apm_ap = x_id)
                ON (apm_id = x_apm_id)
        WHEN MATCHED
        THEN
            UPDATE SET apm_ap = x_apm_ap,
                       apm_aps = x_apm_aps,
                       apm_app = x_apm_app,
                       apm_kaot = x_apm_kaot,
                       apm_nb = x_apm_nb,
                       apm_tp = x_apm_tp,
                       apm_index = x_apm_index,
                       apm_account = x_apm_account,
                       apm_need_account = x_apm_need_account,
                       history_status = x_history_status,
                       apm_street = x_apm_street,
                       apm_ns = x_apm_ns,
                       apm_building = x_apm_building,
                       apm_block = x_apm_block,
                       apm_apartment = x_apm_apartment,
                       apm_dppa = x_apm_dppa
        WHEN NOT MATCHED
        THEN
            INSERT     (apm_id,
                        apm_ap,
                        apm_aps,
                        apm_app,
                        apm_kaot,
                        apm_nb,
                        apm_tp,
                        apm_index,
                        apm_account,
                        apm_need_account,
                        history_status,
                        apm_street,
                        apm_ns,
                        apm_building,
                        apm_block,
                        apm_apartment,
                        apm_dppa)
                VALUES (x_apm_id,
                        x_apm_ap,
                        x_apm_aps,
                        x_apm_app,
                        x_apm_kaot,
                        x_apm_nb,
                        x_apm_tp,
                        x_apm_index,
                        x_apm_account,
                        x_apm_need_account,
                        x_history_status,
                        x_apm_street,
                        x_apm_ns,
                        x_apm_building,
                        x_apm_block,
                        x_apm_apartment,
                        x_apm_dppa);

        /*INSERT INTO uss_esr.ap_payment (apm_id, apm_ap, apm_aps, apm_app, apm_tp, apm_index, apm_kaot, apm_nb, apm_account, apm_need_account, history_status, apm_street, apm_ns, apm_building, apm_block, apm_apartment)
          SELECT apm_id, apm_ap, apm_aps, apm_app, apm_tp, apm_index, apm_kaot, apm_nb, apm_account, apm_need_account, history_status, apm_street, apm_ns, apm_building, apm_block, apm_apartment
          FROM ap_payment, tmp_work_ids
          WHERE apm_ap = x_id;*/

        MERGE INTO uss_esr.ap_document
             USING (SELECT apd_id            AS x_apd_id,
                           apd_ap            AS x_apd_ap,
                           apd_app           AS x_apd_app,
                           apd_ndt           AS x_apd_ndt,
                           apd_doc           AS x_apd_doc,
                           apd_dh            AS x_apd_dh,
                           history_status    AS x_history_status,
                           (CASE history_status
                                WHEN 'A' THEN apd_vf
                                ELSE NULL
                            END)             AS x_apd_vf
                      FROM ap_document, tmp_work_ids
                     WHERE apd_ap = x_id)
                ON (apd_id = x_apd_id)
        WHEN MATCHED
        THEN
            UPDATE SET apd_ap = x_apd_ap,
                       apd_app = x_apd_app,
                       apd_ndt = x_apd_ndt,
                       apd_doc = x_apd_doc,
                       apd_dh = x_apd_dh,
                       history_status = x_history_status,
                       apd_vf = x_apd_vf
        WHEN NOT MATCHED
        THEN
            INSERT     (apd_id,
                        apd_ap,
                        apd_app,
                        apd_ndt,
                        apd_doc,
                        apd_dh,
                        history_status,
                        apd_vf)
                VALUES (x_apd_id,
                        x_apd_ap,
                        x_apd_app,
                        x_apd_ndt,
                        x_apd_doc,
                        x_apd_dh,
                        x_history_status,
                        x_apd_vf);

        /*INSERT INTO uss_esr.ap_document (apd_id, apd_ap, apd_ndt, apd_doc, apd_app, history_status, apd_dh)
          SELECT apd_id, apd_ap, apd_ndt, apd_doc, apd_app, history_status, apd_dh
          FROM ap_document, tmp_work_ids
          WHERE apd_ap = x_id;*/

        MERGE INTO uss_esr.ap_document_attr
             USING (SELECT apda_id             AS x_apda_id,
                           apda_ap             AS x_apda_ap,
                           apda_apd            AS x_apda_apd,
                           apda_nda            AS x_apda_nda,
                           apda_val_int        AS x_apda_val_int,
                           apda_val_sum        AS x_apda_val_sum,
                           apda_val_id         AS x_apda_val_id,
                           apda_val_dt         AS x_apda_val_dt,
                           apda_val_string     AS x_apda_val_string,
                           history_status      AS x_history_status
                      FROM ap_document_attr, tmp_work_ids
                     WHERE apda_ap = x_id)
                ON (apda_id = x_apda_id)
        WHEN MATCHED
        THEN
            UPDATE SET apda_ap = x_apda_ap,
                       apda_apd = x_apda_apd,
                       apda_nda = x_apda_nda,
                       apda_val_int = x_apda_val_int,
                       apda_val_sum = x_apda_val_sum,
                       apda_val_id = x_apda_val_id,
                       apda_val_dt = x_apda_val_dt,
                       apda_val_string = x_apda_val_string,
                       history_status = x_history_status
        WHEN NOT MATCHED
        THEN
            INSERT     (apda_id,
                        apda_ap,
                        apda_apd,
                        apda_nda,
                        apda_val_int,
                        apda_val_sum,
                        apda_val_id,
                        apda_val_dt,
                        apda_val_string,
                        history_status)
                VALUES (x_apda_id,
                        x_apda_ap,
                        x_apda_apd,
                        x_apda_nda,
                        x_apda_val_int,
                        x_apda_val_sum,
                        x_apda_val_id,
                        x_apda_val_dt,
                        x_apda_val_string,
                        x_history_status);

        /*INSERT INTO uss_esr.ap_document_attr (apda_id, apda_ap, apda_apd, apda_nda, apda_val_int, apda_val_dt, apda_val_string, apda_val_id, apda_val_sum, history_status)
          SELECT apda_id, apda_ap, apda_apd, apda_nda, apda_val_int, apda_val_dt, apda_val_string, apda_val_id, apda_val_sum, history_status
          FROM ap_document_attr, tmp_work_ids
          WHERE apda_ap = x_id;*/

        --!!!Сделать копирование данных сессий!!!
        MERGE INTO uss_esr.ap_log
             USING (SELECT apl_id          AS x_apl_id,
                           apl_ap          AS x_apl_ap,
                           apl_st          AS x_apl_st,
                           apl_message     AS x_apl_message,
                           apl_st_old      AS x_apl_st_old,
                           apl_tp          AS x_apl_tp
                      FROM ap_log, tmp_work_ids
                     WHERE apl_ap = x_id)
                ON (apl_id = x_apl_id)
        WHEN MATCHED
        THEN
            UPDATE SET apl_ap = x_apl_ap,
                       apl_st = x_apl_st,
                       apl_message = x_apl_message,
                       apl_st_old = x_apl_st_old,
                       apl_tp = x_apl_tp
        WHEN NOT MATCHED
        THEN
            INSERT     (apl_id,
                        apl_ap,
                        apl_st,
                        apl_message,
                        apl_st_old,
                        apl_tp)
                VALUES (x_apl_id,
                        x_apl_ap,
                        x_apl_st,
                        x_apl_message,
                        x_apl_st_old,
                        x_apl_tp);

        --!!!Сделать копирование данных сессий!!!
        /*INSERT INTO uss_esr.ap_log (apl_id, apl_ap, \*apl_hs, *\apl_st, apl_message, apl_st_old)
          SELECT apl_id, apl_ap, \*apl_hs, *\apl_st, apl_message, apl_st_old
          FROM ap_log, tmp_work_ids
          WHERE apl_ap = x_id;*/

        --Декларація
        MERGE INTO uss_esr.ap_declaration
             USING (SELECT apr_id            AS x_apr_id,
                           apr_fn            AS x_apr_fn,
                           apr_mn            AS x_apr_mn,
                           apr_ln            AS x_apr_ln,
                           apr_residence     AS x_apr_residence,
                           com_org           AS x_com_org,
                           apr_start_dt      AS x_apr_start_dt,
                           apr_stop_dt       AS x_apr_stop_dt,
                           apr_ap            AS x_apr_ap
                      FROM ap_declaration, tmp_work_ids
                     WHERE apr_ap = x_id)
                ON (apr_id = x_apr_id)
        WHEN MATCHED
        THEN
            UPDATE SET apr_fn = x_apr_fn,
                       apr_mn = x_apr_mn,
                       apr_ln = x_apr_ln,
                       apr_residence = x_apr_residence,
                       com_org = x_com_org,
                       apr_start_dt = x_apr_start_dt,
                       apr_stop_dt = x_apr_stop_dt,
                       apr_ap = x_apr_ap
        WHEN NOT MATCHED
        THEN
            INSERT     (apr_id,
                        apr_fn,
                        apr_mn,
                        apr_ln,
                        apr_residence,
                        com_org,
                        apr_start_dt,
                        apr_stop_dt,
                        apr_ap)
                VALUES (x_apr_id,
                        x_apr_fn,
                        x_apr_mn,
                        x_apr_ln,
                        x_apr_residence,
                        x_com_org,
                        x_apr_start_dt,
                        x_apr_stop_dt,
                        x_apr_ap);

        MERGE INTO uss_esr.apr_person
             USING (SELECT aprp_id            AS x_aprp_id,
                           aprp_apr           AS x_aprp_apr,
                           aprp_fn            AS x_aprp_fn,
                           aprp_mn            AS x_aprp_mn,
                           aprp_ln            AS x_aprp_ln,
                           aprp_tp            AS x_aprp_tp,
                           aprp_inn           AS x_aprp_inn,
                           aprp_notes         AS x_aprp_notes,
                           history_status     AS x_history_status,
                           aprp_app           AS x_aprp_app
                      FROM apr_person, ap_declaration, tmp_work_ids
                     WHERE apr_ap = x_id AND aprp_apr = apr_id)
                ON (aprp_id = x_aprp_id)
        WHEN MATCHED
        THEN
            UPDATE SET aprp_apr = x_aprp_apr,
                       aprp_fn = x_aprp_fn,
                       aprp_mn = x_aprp_mn,
                       aprp_ln = x_aprp_ln,
                       aprp_tp = x_aprp_tp,
                       aprp_inn = x_aprp_inn,
                       aprp_notes = x_aprp_notes,
                       history_status = x_history_status,
                       aprp_app = x_aprp_app
        WHEN NOT MATCHED
        THEN
            INSERT     (aprp_id,
                        aprp_apr,
                        aprp_fn,
                        aprp_mn,
                        aprp_ln,
                        aprp_tp,
                        aprp_inn,
                        aprp_notes,
                        history_status,
                        aprp_app)
                VALUES (x_aprp_id,
                        x_aprp_apr,
                        x_aprp_fn,
                        x_aprp_mn,
                        x_aprp_ln,
                        x_aprp_tp,
                        x_aprp_inn,
                        x_aprp_notes,
                        x_history_status,
                        x_aprp_app);

        MERGE INTO uss_esr.apr_income
             USING (SELECT apri_id              AS x_apri_id,
                           apri_apr             AS x_apri_apr,
                           apri_ln_initials     AS x_apri_ln_initials,
                           apri_tp              AS x_apri_tp,
                           apri_sum             AS x_apri_sum,
                           apri_source          AS x_apri_source,
                           apri_aprp            AS x_apri_aprp,
                           history_status       AS x_history_status,
                           apri_start_dt        AS x_apri_start_dt,
                           apri_stop_dt         AS x_apri_stop_dt
                      FROM apr_income, ap_declaration, tmp_work_ids
                     WHERE apr_ap = x_id AND apri_apr = apr_id)
                ON (apri_id = x_apri_id)
        WHEN MATCHED
        THEN
            UPDATE SET apri_apr = x_apri_apr,
                       apri_ln_initials = x_apri_ln_initials,
                       apri_tp = x_apri_tp,
                       apri_sum = x_apri_sum,
                       apri_source = x_apri_source,
                       apri_aprp = x_apri_aprp,
                       history_status = x_history_status,
                       apri_start_dt = x_apri_start_dt,
                       apri_stop_dt = x_apri_stop_dt
        WHEN NOT MATCHED
        THEN
            INSERT     (apri_id,
                        apri_apr,
                        apri_ln_initials,
                        apri_tp,
                        apri_sum,
                        apri_source,
                        apri_aprp,
                        history_status,
                        apri_start_dt,
                        apri_stop_dt)
                VALUES (x_apri_id,
                        x_apri_apr,
                        x_apri_ln_initials,
                        x_apri_tp,
                        x_apri_sum,
                        x_apri_source,
                        x_apri_aprp,
                        x_history_status,
                        x_apri_start_dt,
                        x_apri_stop_dt);

        MERGE INTO uss_esr.apr_living_quarters
             USING (SELECT aprl_id              AS x_aprl_id,
                           aprl_apr             AS x_aprl_apr,
                           aprl_ln_initials     AS x_aprl_ln_initials,
                           aprl_area            AS x_aprl_area,
                           aprl_qnt             AS x_aprl_qnt,
                           aprl_address         AS x_aprl_address,
                           aprl_aprp            AS x_aprl_aprp,
                           history_status       AS x_history_status,
                           aprl_tp              AS x_aprl_tp,
                           aprl_ch              AS x_aprl_ch
                      FROM apr_living_quarters, ap_declaration, tmp_work_ids
                     WHERE apr_ap = x_id AND aprl_apr = apr_id)
                ON (aprl_id = x_aprl_id)
        WHEN MATCHED
        THEN
            UPDATE SET aprl_apr = x_aprl_apr,
                       aprl_ln_initials = x_aprl_ln_initials,
                       aprl_area = x_aprl_area,
                       aprl_qnt = x_aprl_qnt,
                       aprl_address = x_aprl_address,
                       aprl_aprp = x_aprl_aprp,
                       history_status = x_history_status,
                       aprl_tp = x_aprl_tp,
                       aprl_ch = x_aprl_ch
        WHEN NOT MATCHED
        THEN
            INSERT     (aprl_id,
                        aprl_apr,
                        aprl_ln_initials,
                        aprl_area,
                        aprl_qnt,
                        aprl_address,
                        aprl_aprp,
                        history_status,
                        aprl_tp,
                        aprl_ch)
                VALUES (x_aprl_id,
                        x_aprl_apr,
                        x_aprl_ln_initials,
                        x_aprl_area,
                        x_aprl_qnt,
                        x_aprl_address,
                        x_aprl_aprp,
                        x_history_status,
                        x_aprl_tp,
                        x_aprl_ch);

        MERGE INTO uss_esr.apr_spending
             USING (SELECT aprs_id              AS x_aprs_id,
                           aprs_apr             AS x_aprs_apr,
                           aprs_ln_initials     AS x_aprs_ln_initials,
                           aprs_tp              AS x_aprs_tp,
                           aprs_cost_type       AS x_aprs_cost_type,
                           aprs_cost            AS x_aprs_cost,
                           aprs_dt              AS x_aprs_dt,
                           aprs_aprp            AS x_aprs_aprp,
                           history_status       AS x_history_status
                      FROM apr_spending, ap_declaration, tmp_work_ids
                     WHERE apr_ap = x_id AND aprs_apr = apr_id)
                ON (aprs_id = x_aprs_id)
        WHEN MATCHED
        THEN
            UPDATE SET aprs_apr = x_aprs_apr,
                       aprs_ln_initials = x_aprs_ln_initials,
                       aprs_tp = x_aprs_tp,
                       aprs_cost_type = x_aprs_cost_type,
                       aprs_cost = x_aprs_cost,
                       aprs_dt = x_aprs_dt,
                       aprs_aprp = x_aprs_aprp,
                       history_status = x_history_status
        WHEN NOT MATCHED
        THEN
            INSERT     (aprs_id,
                        aprs_apr,
                        aprs_ln_initials,
                        aprs_tp,
                        aprs_cost_type,
                        aprs_cost,
                        aprs_dt,
                        aprs_aprp,
                        history_status)
                VALUES (x_aprs_id,
                        x_aprs_apr,
                        x_aprs_ln_initials,
                        x_aprs_tp,
                        x_aprs_cost_type,
                        x_aprs_cost,
                        x_aprs_dt,
                        x_aprs_aprp,
                        x_history_status);

        MERGE INTO uss_esr.apr_vehicle
             USING (SELECT aprv_id                 AS x_aprv_id,
                           aprv_apr                AS x_aprv_apr,
                           aprv_ln_initials        AS x_aprv_ln_initials,
                           aprv_car_brand          AS x_aprv_car_brand,
                           aprv_license_plate      AS x_aprv_license_plate,
                           aprv_production_year    AS x_aprv_production_year,
                           aprv_is_social_car      AS x_aprv_is_social_car,
                           aprv_aprp               AS x_aprv_aprp,
                           history_status          AS x_history_status
                      FROM apr_vehicle, ap_declaration, tmp_work_ids
                     WHERE apr_ap = x_id AND aprv_apr = apr_id)
                ON (aprv_id = x_aprv_id)
        WHEN MATCHED
        THEN
            UPDATE SET aprv_apr = x_aprv_apr,
                       aprv_ln_initials = x_aprv_ln_initials,
                       aprv_car_brand = x_aprv_car_brand,
                       aprv_license_plate = x_aprv_license_plate,
                       aprv_production_year = x_aprv_production_year,
                       aprv_is_social_car = x_aprv_is_social_car,
                       aprv_aprp = x_aprv_aprp,
                       history_status = x_history_status
        WHEN NOT MATCHED
        THEN
            INSERT     (aprv_id,
                        aprv_apr,
                        aprv_ln_initials,
                        aprv_car_brand,
                        aprv_license_plate,
                        aprv_production_year,
                        aprv_is_social_car,
                        aprv_aprp,
                        history_status)
                VALUES (x_aprv_id,
                        x_aprv_apr,
                        x_aprv_ln_initials,
                        x_aprv_car_brand,
                        x_aprv_license_plate,
                        x_aprv_production_year,
                        x_aprv_is_social_car,
                        x_aprv_aprp,
                        x_history_status);

        MERGE INTO uss_esr.apr_land_plot
             USING (SELECT aprt_id              AS x_aprt_id,
                           aprt_apr             AS x_aprt_apr,
                           aprt_ln_initials     AS x_aprt_ln_initials,
                           aprt_area            AS x_aprt_area,
                           aprt_ownership       AS x_aprt_ownership,
                           aprt_purpose         AS x_aprt_purpose,
                           aprt_aprp            AS x_aprt_aprp,
                           history_status       AS x_history_status
                      FROM apr_land_plot, ap_declaration, tmp_work_ids
                     WHERE apr_ap = x_id AND aprt_apr = apr_id)
                ON (aprt_id = x_aprt_id)
        WHEN MATCHED
        THEN
            UPDATE SET aprt_apr = x_aprt_apr,
                       aprt_ln_initials = x_aprt_ln_initials,
                       aprt_area = x_aprt_area,
                       aprt_ownership = x_aprt_ownership,
                       aprt_purpose = x_aprt_purpose,
                       aprt_aprp = x_aprt_aprp,
                       history_status = x_history_status
        WHEN NOT MATCHED
        THEN
            INSERT     (aprt_id,
                        aprt_apr,
                        aprt_ln_initials,
                        aprt_area,
                        aprt_ownership,
                        aprt_purpose,
                        aprt_aprp,
                        history_status)
                VALUES (x_aprt_id,
                        x_aprt_apr,
                        x_aprt_ln_initials,
                        x_aprt_area,
                        x_aprt_ownership,
                        x_aprt_purpose,
                        x_aprt_aprp,
                        x_history_status);

        MERGE INTO uss_esr.apr_other_income
             USING (SELECT apro_id               AS x_apro_id,
                           apro_apr              AS x_apro_apr,
                           apro_tp               AS x_apro_tp,
                           apro_income_info      AS x_apro_income_info,
                           apro_income_usage     AS x_apro_income_usage,
                           apro_aprp             AS x_apro_aprp,
                           history_status        AS x_history_status
                      FROM apr_other_income, ap_declaration, tmp_work_ids
                     WHERE apr_ap = x_id AND apro_apr = apr_id)
                ON (apro_id = x_apro_id)
        WHEN MATCHED
        THEN
            UPDATE SET apro_apr = x_apro_apr,
                       apro_tp = x_apro_tp,
                       apro_income_info = x_apro_income_info,
                       apro_income_usage = x_apro_income_usage,
                       apro_aprp = x_apro_aprp,
                       history_status = x_history_status
        WHEN NOT MATCHED
        THEN
            INSERT     (apro_id,
                        apro_apr,
                        apro_tp,
                        apro_income_info,
                        apro_income_usage,
                        apro_aprp,
                        history_status)
                VALUES (x_apro_id,
                        x_apro_apr,
                        x_apro_tp,
                        x_apro_income_info,
                        x_apro_income_usage,
                        x_apro_aprp,
                        x_history_status);


        MERGE INTO uss_esr.apr_alimony
             USING (SELECT apra_id                 AS x_apra_id,
                           apra_apr                AS x_apra_apr,
                           apra_aprp               AS x_apra_aprp,
                           apra_payer              AS x_apra_payer,
                           apra_sum                AS x_apra_sum,
                           apra_is_have_arrears    AS x_apra_is_have_arrears,
                           history_status          AS x_history_status
                      FROM apr_alimony, ap_declaration, tmp_work_ids
                     WHERE apr_ap = x_id AND apra_apr = apr_id)
                ON (apra_id = x_apra_id)
        WHEN MATCHED
        THEN
            UPDATE SET apra_apr = x_apra_apr,
                       apra_aprp = x_apra_aprp,
                       apra_payer = x_apra_payer,
                       apra_sum = x_apra_sum,
                       apra_is_have_arrears = x_apra_is_have_arrears,
                       history_status = x_history_status
        WHEN NOT MATCHED
        THEN
            INSERT     (apra_id,
                        apra_apr,
                        apra_aprp,
                        apra_payer,
                        apra_sum,
                        apra_is_have_arrears,
                        history_status)
                VALUES (x_apra_id,
                        x_apra_apr,
                        x_apra_aprp,
                        x_apra_payer,
                        x_apra_sum,
                        x_apra_is_have_arrears,
                        x_history_status);


        DELETE FROM uss_esr.ap_income
              WHERE     api_src IN ('PFU', 'DPS')
                    AND EXISTS
                            (SELECT 1
                               FROM tmp_work_ids, ap_person
                              WHERE app_id = api_app AND app_ap = x_id);

        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''.,''');

        FOR xx IN (SELECT x_id                       AS z_ap,
                          app_id                     AS z_app,
                          ap_tp,
                          (SELECT vfa_answer_data
                             FROM verification, vf_answer
                            WHERE     vf_vf_main = app_vf
                                  AND vf_nvt = 7
                                  AND vf_id = vfa_vf
                                  AND ROWNUM < 2)    AS z_data
                     FROM tmp_work_ids, ap_person, appeal
                    WHERE x_id = app_ap AND x_id = ap_id)
        LOOP
            IF xx.z_data IS NOT NULL
            THEN
                BEGIN
                    l_xmldata := xmltype (xx.z_data);

                    INSERT INTO uss_esr.ap_income (api_id,
                                                   api_app,
                                                   api_month,
                                                   api_src,
                                                   api_sum,
                                                   api_exch_tp,
                                                   api_tp,
                                                   api_esv_paid,
                                                   api_esv_min,
                                                   api_edrpou,
                                                   api_tax_sum)
                        SELECT 0,
                               xx.z_app,
                               q_month,
                               q_src,
                               q_sum,
                               q_code,
                               nitc_apri_tp     AS q_tp,
                               q_esv_paid,
                               q_esv_min,
                               q_edrpou,
                               0
                          FROM uss_ndi.v_ndi_income_tp_config  t,
                               (       SELECT TO_DATE (z_month, 'DDMMYYYY')
                                                  AS q_month,
                                              (0 + z_sum) / 100
                                                  AS q_sum,
                                              z_code
                                                  AS q_code,
                                              z_edrpou
                                                  AS q_edrpou,
                                              z_esv_paid
                                                  AS q_esv_paid,
                                              z_esv_min
                                                  AS q_esv_min,
                                              'PFU'
                                                  AS q_src
                                         FROM XMLTABLE (
                                                  '/UPSZN_ANSWER/PERSONS_ANSWER/PERSON_ANSWER/PAYMENTS/PAYMENT'
                                                  PASSING l_xmldata
                                                  COLUMNS z_month       VARCHAR2 (10) PATH 'MONTH',
                                                          z_sum         VARCHAR2 (50) PATH 'SUM_PAYMENT',
                                                          z_code        VARCHAR2 (10) PATH 'SYMP_TYPE',
                                                          z_edrpou      VARCHAR2 (12) PATH 'CODE_INSURER',
                                                          z_esv_paid    VARCHAR2 (10) PATH 'PAY_INSURER',
                                                          z_esv_min     VARCHAR2 (10) PATH 'PAY_INSURER_OZN'))
                         WHERE     t.history_status = 'A'
                               AND nitc_src = q_src
                               AND nitc_exch_tp = q_code
                               AND (   (    xx.ap_tp = 'SS'
                                        AND nitc_api_use_tp IN ('S', 'VS'))
                                    OR (    xx.ap_tp = 'V'
                                        AND nitc_api_use_tp IN ('V', 'VS')));
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;
            END IF;
        END LOOP;

        FOR xx IN (SELECT x_id                       AS z_ap,
                          app_id                     AS z_app,
                          ap_tp,
                          (SELECT vfa_answer_data
                             FROM verification, vf_answer
                            WHERE     vf_vf_main = app_vf
                                  AND vf_nvt IN (4,
                                                 5,
                                                 8,
                                                 9)
                                  AND vf_id = vfa_vf
                                  AND ROWNUM < 2)    AS z_data
                     FROM tmp_work_ids, ap_person, appeal
                    WHERE x_id = app_ap AND x_id = ap_id)
        LOOP
            IF xx.z_data IS NOT NULL
            THEN
                BEGIN
                    l_xmldata := xmltype (xx.z_data);

                    INSERT INTO uss_esr.ap_income (api_id,
                                                   api_app,
                                                   api_start_dt,
                                                   api_stop_dt,
                                                   api_src,
                                                   api_sum,
                                                   api_exch_tp,
                                                   api_tp,
                                                   api_esv_paid,
                                                   api_esv_min,
                                                   api_edrpou,
                                                   api_tax_sum)
                        SELECT 0,
                               xx.z_app,
                               q_month_start,
                               q_month_stop,
                               q_src,
                               q_sum,
                               q_code,
                               nitc_apri_tp     AS q_tp,
                               q_esv_paid,
                               q_esv_min,
                               q_edrpou,
                               q_tax_sum
                          FROM uss_ndi.v_ndi_income_tp_config  t,
                               (      SELECT CASE
                                                 WHEN is_number (z_year) = 0
                                                 THEN
                                                     NULL
                                                 ELSE
                                                     CASE
                                                         WHEN    LENGTH (
                                                                     TRIM (
                                                                         z_quarter)) =
                                                                 0
                                                              OR (    LENGTH (
                                                                          TRIM (
                                                                              z_quarter)) >
                                                                      0
                                                                  AND is_number (
                                                                          SUBSTR (
                                                                              TRIM (
                                                                                  z_quarter),
                                                                              1,
                                                                              1)) =
                                                                      0)
                                                         THEN
                                                             NULL
                                                         WHEN LENGTH (
                                                                  TRIM (z_quarter)) =
                                                              1
                                                         THEN
                                                             TO_DATE (
                                                                    '01.'
                                                                 || LPAD (
                                                                           ''
                                                                        || (    (  0
                                                                                 + SUBSTR (
                                                                                       TRIM (
                                                                                           z_quarter),
                                                                                       1,
                                                                                       1))
                                                                              * 3
                                                                            - 2),
                                                                        2,
                                                                        '0')
                                                                 || '.'
                                                                 || LPAD (
                                                                        TRIM (
                                                                            z_year),
                                                                        4,
                                                                        '0'),
                                                                 'DD.MM.YYYY')
                                                         ELSE
                                                             TO_DATE (
                                                                    '01.'
                                                                 || DECODE (
                                                                        SUBSTR (
                                                                            TRIM (
                                                                                UPPER (
                                                                                    z_quarter)),
                                                                            5),
                                                                        'СІЧЕНЬ', '01',
                                                                        'ЛЮТИЙ', '02',
                                                                        'БЕРЕЗЕНЬ', '03',
                                                                        'КВІТЕНЬ', '04',
                                                                        'ТРАВЕНЬ', '05',
                                                                        'ЧЕРВЕНЬ', '06',
                                                                        'ЛИПЕНЬ', '07',
                                                                        'СЕРПЕНЬ', '08',
                                                                        'ВЕРЕСЕНЬ', '09',
                                                                        'ЖОВТЕНЬ', '10',
                                                                        'ЛИСТОПАД', '11',
                                                                        'ГРУДЕНЬ', '12')
                                                                 || '.'
                                                                 || LPAD (
                                                                        TRIM (
                                                                            z_year),
                                                                        4,
                                                                        '0'),
                                                                 'DD.MM.YYYY')
                                                     END
                                             END
                                                 AS q_month_start,
                                             CASE
                                                 WHEN is_number (z_year) = 0
                                                 THEN
                                                     NULL
                                                 ELSE
                                                     CASE
                                                         WHEN    LENGTH (
                                                                     TRIM (
                                                                         z_quarter)) =
                                                                 0
                                                              OR (    LENGTH (
                                                                          TRIM (
                                                                              z_quarter)) >
                                                                      1
                                                                  AND is_number (
                                                                          SUBSTR (
                                                                              TRIM (
                                                                                  z_quarter),
                                                                              1,
                                                                              1)) =
                                                                      0)
                                                         THEN
                                                             NULL
                                                         WHEN LENGTH (
                                                                  TRIM (z_quarter)) =
                                                              1
                                                         THEN
                                                             LAST_DAY (
                                                                 TO_DATE (
                                                                        '01.'
                                                                     || LPAD (
                                                                               ''
                                                                            || (  (  0
                                                                                   + SUBSTR (
                                                                                         TRIM (
                                                                                             z_quarter),
                                                                                         1,
                                                                                         1))
                                                                                * 3),
                                                                            2,
                                                                            '0')
                                                                     || '.'
                                                                     || LPAD (
                                                                            TRIM (
                                                                                z_year),
                                                                            4,
                                                                            '0'),
                                                                     'DD.MM.YYYY'))
                                                         ELSE
                                                             LAST_DAY (
                                                                 TO_DATE (
                                                                        '01.'
                                                                     || DECODE (
                                                                            SUBSTR (
                                                                                TRIM (
                                                                                    UPPER (
                                                                                        z_quarter)),
                                                                                5),
                                                                            'СІЧЕНЬ', '01',
                                                                            'ЛЮТИЙ', '02',
                                                                            'БЕРЕЗЕНЬ', '03',
                                                                            'КВІТЕНЬ', '04',
                                                                            'ТРАВЕНЬ', '05',
                                                                            'ЧЕРВЕНЬ', '06',
                                                                            'ЛИПЕНЬ', '07',
                                                                            'СЕРПЕНЬ', '08',
                                                                            'ВЕРЕСЕНЬ', '09',
                                                                            'ЖОВТЕНЬ', '10',
                                                                            'ЛИСТОПАД', '11',
                                                                            'ГРУДЕНЬ', '12')
                                                                     || '.'
                                                                     || LPAD (
                                                                            TRIM (
                                                                                z_year),
                                                                            4,
                                                                            '0'),
                                                                     'DD.MM.YYYY'))
                                                     END
                                             END
                                                 AS q_month_stop,
                                             NVL (
                                                 CASE
                                                     WHEN is_number (z_sum) = 1
                                                     THEN
                                                         (0 + z_sum)
                                                 END,
                                                 0)
                                                 AS q_sum,
                                             SUBSTR (z_code, 1, 3)
                                                 AS q_code,
                                             z_edrpou
                                                 AS q_edrpou,
                                             'F'
                                                 AS q_esv_paid,
                                             'F'
                                                 AS q_esv_min,
                                             'DPS'
                                                 AS q_src,
                                             NVL (
                                                 CASE
                                                     WHEN is_number (z_tax_sum) = 1
                                                     THEN
                                                         (0 + z_tax_sum)
                                                 END,
                                                 0)
                                                 AS q_tax_sum
                                        FROM XMLTABLE (
                                                 xmlnamespaces (
                                                     'http://www.talend.org/service/'
                                                         AS "tns"),
                                                 '/tns:InfoIncomeSourcesDRFOAnswerResponse/SourcesOfIncome/IncomeTaxes'
                                                 PASSING l_xmldata
                                                 COLUMNS z_year       VARCHAR2 (1000) PATH 'period_year',
                                                         z_quarter    VARCHAR2 (1000) PATH 'period_quarter',
                                                         z_edrpou     VARCHAR2 (1000) PATH './../TaxAgent',
                                                         z_sum        VARCHAR2 (1000) PATH 'IncomeAccrued',
                                                         z_tax_sum    VARCHAR2 (1000) PATH 'TaxCharged',
                                                         z_code       VARCHAR2 (1000) PATH 'SignOfIncomePrivilege'))
                         WHERE     t.history_status = 'A'
                               AND nitc_src = q_src
                               AND nitc_exch_tp = q_code
                               AND (   (    xx.ap_tp = 'SS'
                                        AND nitc_api_use_tp IN ('S', 'VS'))
                                    OR (    xx.ap_tp = 'V'
                                        AND nitc_api_use_tp IN ('V', 'VS')));
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;
            END IF;
        END LOOP;

        DELETE FROM uss_esr.ap_vf_answers an
              WHERE EXISTS
                        (SELECT 1
                           FROM tmp_work_ids
                          WHERE an.apva_ap = x_id);

        FOR Rec
            IN (SELECT p.App_Id,
                       p.App_ap,
                       v.vf_id,
                       v.vf_nvt,
                       a.vfa_id,
                       a.Vfa_Answer_Data
                  FROM Uss_Visit.Ap_Person  p
                       JOIN Uss_Visit.Verification v
                           ON     p.App_Vf = v.Vf_Vf_Main
                              AND v.Vf_Nvt = 33
                              AND v.Vf_St <> 'E'
                       JOIN Uss_Visit.Vf_Answer a ON v.Vf_Id = a.Vfa_Vf
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM tmp_work_ids
                                 WHERE p.app_ap = x_id)
                       AND p.History_Status = 'A')
        LOOP
            DECLARE
                l_Resp          Ikis_Rbm.Api$request_Mfu.r_Vf_Response;
                l_Id_Param      VARCHAR2 (10);
                l_Is_Recomend   NUMBER;
            BEGIN
                l_Resp :=
                    Ikis_Rbm.Api$request_Mfu.Parse_Verification_Resp (
                        Rec.Vfa_Answer_Data);

                IF l_Resp.Facts_Recomend IS NULL
                THEN
                    NULL;
                ELSIF l_Resp.Facts_Recomend.COUNT = 0
                THEN
                    NULL;
                ELSE
                    FOR i
                        IN l_Resp.Facts_Recomend.FIRST ..
                           l_Resp.Facts_Recomend.LAST
                    LOOP
                        INSERT INTO uss_esr.ap_vf_answers (apva_id,
                                                           apva_ap,
                                                           apva_vfa,
                                                           apva_nvt,
                                                           apva_id_rec,
                                                           apva_id_param,
                                                           apva_recomend,
                                                           apva_is_recomend,
                                                           apva_result,
                                                           apva_vf)
                             VALUES (0,
                                     rec.app_ap,
                                     rec.vfa_id,
                                     rec.vf_nvt,
                                     l_Resp.Facts_Recomend (i).Id_Rec,
                                     l_Resp.Facts_Recomend (i).Id_Param,
                                     l_Resp.Facts_Recomend (i).Recomend,
                                     l_Resp.Facts_Recomend (i).Is_Recomend,
                                     l_Resp.Facts_Recomend (i).Result,
                                     rec.vf_id);
                    END LOOP;
                END IF;
            END;
        END LOOP;
    END;

    PROCEDURE copy_full_ap_to_rnsp
    IS
        l_ext_ident   NUMBER;
    BEGIN
        DBMS_OUTPUT.put_line ('BEGIN copy_full_ap_to_rnsp');

        BEGIN
            DELETE FROM tmp_work_ids1
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids1 (x_id)
                SELECT ap_vf     AS x_vf
                  FROM tmp_work_ids, appeal
                 WHERE x_id = ap_id
                UNION
                SELECT app_vf
                  FROM tmp_work_ids, ap_person
                 WHERE x_id = app_ap
                UNION
                SELECT apd_vf
                  FROM tmp_work_ids, ap_document
                 WHERE x_id = apd_ap;


            FOR xx IN (SELECT x_id FROM tmp_work_ids1)
            LOOP
                MERGE INTO uss_rnsp.verification
                     USING (    SELECT vf_id
                                           AS x_vf_id,
                                       vf_vf_main
                                           AS x_vf_vf_main,
                                       vf_tp
                                           AS x_vf_tp,
                                       vf_st
                                           AS x_vf_st,
                                       vf_start_dt
                                           AS x_vf_start_dt,
                                       vf_stop_dt
                                           AS x_vf_stop_dt,
                                       vf_expected_stop_dt
                                           AS x_vf_expected_stop_dt,
                                       vf_nvt
                                           AS x_vf_nvt,
                                       vf_obj_tp
                                           AS x_vf_obj_tp,
                                       vf_obj_id
                                           AS x_vf_obj_id,
                                       vf_hs
                                           AS x_vf_hs,
                                       vf_hs_rewrite
                                           AS x_vf_hs_rewrite,
                                       vf_own_st
                                           AS x_vf_own_st,
                                       vf_plan_dt
                                           AS x_vf_plan_dt
                                  FROM verification
                            START WITH vf_id = xx.x_id
                            CONNECT BY PRIOR vf_id = vf_vf_main)
                        ON (vf_id = x_vf_id)
                WHEN MATCHED
                THEN
                    UPDATE SET vf_vf_main = x_vf_vf_main,
                               vf_tp = x_vf_tp,
                               vf_st = x_vf_st,
                               vf_start_dt = x_vf_start_dt,
                               vf_stop_dt = x_vf_stop_dt,
                               vf_expected_stop_dt = x_vf_expected_stop_dt,
                               vf_nvt = x_vf_nvt,
                               vf_obj_tp = x_vf_obj_tp,
                               vf_obj_id = x_vf_obj_id,
                               vf_hs = x_vf_hs,
                               vf_hs_rewrite = x_vf_hs_rewrite,
                               vf_own_st = x_vf_own_st                     --,
                --vf_plan_dt = x_vf_plan_dt
                WHEN NOT MATCHED
                THEN
                    INSERT     (vf_id,
                                vf_vf_main,
                                vf_tp,
                                vf_st,
                                vf_start_dt,
                                vf_stop_dt,
                                vf_expected_stop_dt,
                                vf_nvt,
                                vf_obj_tp,
                                vf_obj_id,
                                vf_hs,
                                vf_hs_rewrite,
                                vf_own_st                     /*, vf_plan_dt*/
                                         )
                        VALUES (x_vf_id,
                                x_vf_vf_main,
                                x_vf_tp,
                                x_vf_st,
                                x_vf_start_dt,
                                x_vf_stop_dt,
                                x_vf_expected_stop_dt,
                                x_vf_nvt,
                                x_vf_obj_tp,
                                x_vf_obj_id,
                                x_vf_hs,
                                x_vf_hs_rewrite,
                                x_vf_own_st                 /*, x_vf_plan_dt*/
                                           );

                MERGE INTO uss_rnsp.vf_log
                     USING (SELECT vfl_id          AS x_vfl_id,
                                   vfl_vf          AS x_vfl_vf,
                                   vfl_message     AS x_vfl_message,
                                   vfl_tp          AS x_vfl_tp,
                                   vfl_hs          AS x_vfl_hs,
                                   vfl_dt          AS x_vfl_dt
                              FROM vf_log,
                                   (    SELECT vf_id     AS x_vf_id
                                          FROM verification
                                    START WITH vf_id = xx.x_id
                                    CONNECT BY PRIOR vf_id = vf_vf_main)
                             WHERE vfl_vf = x_vf_id)
                        ON (vfl_id = x_vfl_id)
                WHEN MATCHED
                THEN
                    UPDATE SET vfl_vf = x_vfl_vf,
                               vfl_message = x_vfl_message,
                               vfl_tp = x_vfl_tp,
                               vfl_hs = x_vfl_hs,
                               vfl_dt = x_vfl_dt
                WHEN NOT MATCHED
                THEN
                    INSERT     (vfl_id,
                                vfl_vf,
                                vfl_message,
                                vfl_tp,
                                vfl_hs,
                                vfl_dt)
                        VALUES (x_vfl_id,
                                x_vfl_vf,
                                x_vfl_message,
                                x_vfl_tp,
                                x_vfl_hs,
                                x_vfl_dt);
            END LOOP;
        --EXCEPTION
        --  WHEN others THEN
        --   NULL;
        END;

        MERGE INTO uss_rnsp.appeal
             USING (SELECT ap_id                AS x_ap_id,
                           ap_id                AS x_ap_src_id,
                           ap_num               AS x_ap_num,
                           ap_reg_dt            AS x_ap_reg_dt,
                           ap_src               AS x_ap_src,
                           'S'                  AS x_ap_st,
                           com_org              AS v_com_org,
                           ap_is_second         AS x_ap_is_second,
                           --#100384
                           CASE
                               WHEN EXISTS
                                        (SELECT 1
                                           FROM ap_document
                                          WHERE     apd_ap = ap_id
                                                AND apd_ndt = 740)
                               THEN
                                   com_wu
                           END                  AS v_com_wu,
                           ap_tp                AS x_ap_tp,
                           ap_sub_tp            AS x_ap_sub_tp,
                           ap_ext_ident         AS x_ap_ext_ident,
                           ap_vf                AS x_ap_vf,
                           ap_is_ext_process    AS x_ap_is_ext_process,
                           ap_dest_org          AS x_ap_dest_org
                      FROM appeal, tmp_work_ids
                     WHERE ap_id = x_id)
                ON (ap_id = x_ap_id)
        WHEN MATCHED
        THEN
            UPDATE SET                                      --ap_pc = x_ap_pc,
                                                    --ap_src_id = x_ap_src_id,
             ap_tp = x_ap_tp,
             ap_sub_tp = x_ap_sub_tp,
             ap_reg_dt = x_ap_reg_dt,
             ap_src = x_ap_src,
             ap_st = x_ap_st,
             com_org = v_com_org,
             ap_is_second = x_ap_is_second,
             com_wu = v_com_wu,
             --ap_ext_ident = x_ap_ext_ident,
             ap_num = x_ap_num,
             --ap_vf = x_ap_vf,
             ap_is_ext_process = x_ap_is_ext_process,
             ap_dest_org = x_ap_dest_org
        WHEN NOT MATCHED
        THEN
            INSERT     (ap_id,                                     /*ap_pc, */
                                                                /*ap_src_id,*/
                        ap_tp,
                        ap_sub_tp,
                        ap_reg_dt,
                        ap_src,
                        ap_st,
                        com_org,
                        ap_is_second,
                        com_wu,
                        ap_ext_ident,
                        ap_num,                                     /*ap_vf,*/
                        ap_is_ext_process,
                        ap_dest_org)
                VALUES (x_ap_id,                                  /*x_ap_pc,*/
                                                              /*x_ap_src_id,*/
                        x_ap_tp,
                        x_ap_sub_tp,
                        x_ap_reg_dt,
                        x_ap_src,
                        x_ap_st,
                        v_com_org,
                        x_ap_is_second,
                        v_com_wu,
                        x_ap_ext_ident,
                        x_ap_num,                                 /*x_ap_vf,*/
                        x_ap_is_ext_process,
                        x_ap_dest_org);

        MERGE INTO uss_rnsp.ap_service
             USING (SELECT aps_id             AS x_aps_id,
                           aps_ap             AS x_aps_ap,
                           aps_st             AS x_aps_st,
                           history_status     AS x_history_status,
                           aps_nst            AS x_aps_nst
                      FROM ap_service, tmp_work_ids
                     WHERE aps_ap = x_id)
                ON (aps_id = x_aps_id)
        WHEN MATCHED
        THEN
            UPDATE SET aps_ap = x_aps_ap,
                       aps_st = x_aps_st,
                       history_status = x_history_status,
                       aps_nst = x_aps_nst
        WHEN NOT MATCHED
        THEN
            INSERT     (aps_id,
                        aps_ap,
                        aps_st,
                        history_status,
                        aps_nst)
                VALUES (x_aps_id,
                        x_aps_ap,
                        x_aps_st,
                        x_history_status,
                        x_aps_nst);

        MERGE INTO uss_rnsp.ap_person
             USING (SELECT app_id             AS x_app_id,
                           app_ap             AS x_app_ap,
                           app_sc             AS x_app_sc,
                           app_tp             AS x_app_tp,
                           history_status     AS x_history_status,
                           app_vf             AS x_app_vf,
                           app_fn             AS x_app_fn,
                           app_mn             AS x_app_mn,
                           app_ln             AS x_app_ln,
                           app_inn            AS x_app_inn,
                           app_ndt            AS x_app_ndt,
                           app_doc_num        AS x_app_doc_num,
                           app_esr_num        AS x_app_esr_num,
                           app_gender         AS x_app_gender
                      FROM ap_person, tmp_work_ids
                     WHERE app_ap = x_id)
                ON (app_id = x_app_id)
        WHEN MATCHED
        THEN
            UPDATE SET app_ap = x_app_ap,
                       app_sc = x_app_sc,
                       app_tp = x_app_tp,
                       app_fn = x_app_fn,
                       app_mn = x_app_mn,
                       app_ln = x_app_ln,
                       app_inn = x_app_inn,
                       app_ndt = x_app_ndt,
                       app_doc_num = x_app_doc_num,
                       app_esr_num = x_app_esr_Num,
                       app_gender = x_app_gender,
                       history_status = x_history_status
        WHEN NOT MATCHED
        THEN
            INSERT     (app_id,
                        app_ap,
                        app_sc,
                        app_tp,
                        history_status,
                        app_fn,
                        app_mn,
                        app_ln,
                        app_inn,
                        app_ndt,
                        app_doc_num,
                        app_esr_num,
                        app_gender)
                VALUES (x_app_id,
                        x_app_ap,
                        x_app_sc,
                        x_app_tp,
                        x_history_status,
                        x_app_fn,
                        x_app_mn,
                        x_app_ln,
                        x_app_inn,
                        x_app_ndt,
                        x_app_doc_num,
                        x_app_esr_num,
                        x_app_gender);

        MERGE INTO uss_rnsp.ap_document
             USING (SELECT apd_id             AS x_apd_id,
                           apd_ap             AS x_apd_ap,
                           apd_app            AS x_apd_app,
                           apd_ndt            AS x_apd_ndt,
                           apd_doc            AS x_apd_doc,
                           apd_dh             AS x_apd_dh,
                           history_status     AS x_history_status,
                           apd_vf             AS x_apd_vf,
                           apd_aps            AS x_apd_aps
                      FROM ap_document, tmp_work_ids
                     WHERE     apd_ap = x_id
                           AND (apd_ndt != 730 OR apd_ndt IS NULL))
                ON (apd_id = x_apd_id)
        WHEN MATCHED
        THEN
            UPDATE SET apd_ap = x_apd_ap,
                       apd_app = x_apd_app,
                       apd_ndt = x_apd_ndt,
                       apd_doc = x_apd_doc,
                       apd_dh = x_apd_dh,
                       history_status = x_history_status,
                       apd_vf = x_apd_vf,
                       apd_aps = x_apd_aps
        WHEN NOT MATCHED
        THEN
            INSERT     (apd_id,
                        apd_ap,
                        apd_app,
                        apd_ndt,
                        apd_doc,
                        apd_dh,
                        history_status,
                        apd_vf,
                        apd_aps)
                VALUES (x_apd_id,
                        x_apd_ap,
                        x_apd_app,
                        x_apd_ndt,
                        x_apd_doc,
                        x_apd_dh,
                        x_history_status,
                        x_apd_vf,
                        x_apd_aps);


        MERGE INTO uss_rnsp.ap_document_attr
             USING (SELECT apda_id             AS x_apda_id,
                           apda_ap             AS x_apda_ap,
                           apda_apd            AS x_apda_apd,
                           apda_nda            AS x_apda_nda,
                           apda_val_int        AS x_apda_val_int,
                           apda_val_sum        AS x_apda_val_sum,
                           apda_val_id         AS x_apda_val_id,
                           apda_val_dt         AS x_apda_val_dt,
                           apda_val_string     AS x_apda_val_string,
                           history_status      AS x_history_status
                      FROM ap_document_attr, tmp_work_ids
                     WHERE     apda_ap = x_id
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM ap_document
                                     WHERE     apd_id = apda_apd
                                           AND apd_ndt = 730))
                ON (apda_id = x_apda_id)
        WHEN MATCHED
        THEN
            UPDATE SET apda_ap = x_apda_ap,
                       apda_apd = x_apda_apd,
                       apda_nda = x_apda_nda,
                       apda_val_int = x_apda_val_int,
                       apda_val_sum = x_apda_val_sum,
                       apda_val_id = x_apda_val_id,
                       apda_val_dt = x_apda_val_dt,
                       apda_val_string = x_apda_val_string,
                       history_status = x_history_status
        WHEN NOT MATCHED
        THEN
            INSERT     (apda_id,
                        apda_ap,
                        apda_apd,
                        apda_nda,
                        apda_val_int,
                        apda_val_sum,
                        apda_val_id,
                        apda_val_dt,
                        apda_val_string,
                        history_status)
                VALUES (x_apda_id,
                        x_apda_ap,
                        x_apda_apd,
                        x_apda_nda,
                        x_apda_val_int,
                        x_apda_val_sum,
                        x_apda_val_id,
                        x_apda_val_dt,
                        x_apda_val_string,
                        x_history_status);


        --!!!Сделать копирование данных сессий!!!
        -- #84314
        /*MERGE INTO uss_rnsp.ap_log
          USING (SELECT apl_id AS x_apl_id, apl_ap AS x_apl_ap, apl_st AS x_apl_st, apl_message AS x_apl_message, apl_st_old AS x_apl_st_old, apl_tp AS x_apl_tp
                 FROM ap_log, tmp_work_ids
                 WHERE apl_ap = x_id)
            ON (apl_id = x_apl_id)
          WHEN MATCHED THEN
            UPDATE SET apl_ap = x_apl_ap,
                       apl_st = x_apl_st,
                       apl_message = x_apl_message,
                       apl_st_old = x_apl_st_old,
                       apl_tp = x_apl_tp
          WHEN NOT MATCHED THEN
            INSERT (apl_id, apl_ap, apl_st, apl_message, apl_st_old, apl_tp)
              VALUES (x_apl_id, x_apl_ap, x_apl_st, x_apl_message, x_apl_st_old, x_apl_tp);
        */
        FOR ap IN (SELECT * FROM tmp_work_ids)
        LOOP
            uss_rnsp.api$find.Update_appeal_ap_ext_ident (
                p_ap_id       => ap.x_id,
                p_ext_ident   => l_ext_ident);

            UPDATE appeal
               SET ap_ext_ident = l_ext_ident
             WHERE ap_id = ap.x_id;
        END LOOP;
    END;

    --Передача даних зверненнь до системи ЄСР
    --Закоментовано 09.08.2024 - #106772, якщо процедура не використовується - видалити після 23.08.2024
    /*PROCEDURE copy_appeals_to_esr
    IS
    BEGIN
      DELETE FROM tmp_work_ids WHERE 1 = 1;
      --Збираємо звернення
      INSERT INTO tmp_work_ids (x_id)
        SELECT ap_id
        FROM appeal visit
        WHERE ap_st IN ('VO', 'VE')
          AND ap_tp = 'V'
          --AND NOT EXISTS (SELECT 1 FROM uss_esr.appeal esr WHERE esr.ap_id = visit.ap_id)
          AND EXISTS (SELECT 1 FROM ap_person sl WHERE app_ap = ap_id AND app_sc IS NOT NULL AND sl.history_status = 'A')
          AND NOT EXISTS (SELECT 1 FROM ap_person sl WHERE app_ap = ap_id AND app_sc IS NULL AND sl.history_status = 'A');

      IF SQL%ROWCOUNT > 0 THEN
        copy_full_ap_to_esr;
        uss_esr.api$personalcase.init_pc_by_appeal;


        UPDATE appeal
          SET ap_st = 'S'
          WHERE EXISTS (SELECT 1 FROM tmp_work_ids WHERE ap_id = x_id);

        for rec in(SELECT x_id as ap_id FROM tmp_work_ids)
        loop
          --Відправляємо заявнику повідомлення про зміну статуса
          Send_Ap_St_Notification(p_Ap_Id => Rec.Ap_Id, p_Ap_St => 'S');
        end loop;
      END IF;
    END;*/

    --Передача даних зверненнь до системи ЄСР за допомогою
    PROCEDURE copy_appeals_to_esr_schedule (p_hs histsession.hs_id%TYPE)
    IS
    BEGIN
        copy_full_ap_to_esr;
        uss_esr.api$personalcase.init_pc_by_appeal;

        FOR vAp
            IN (                                                     --#109549
                SELECT *
                  FROM tmp_work_ids, Appeal
                 WHERE     ap_id = x_id
                       AND ap_src IN ('CMES')
                       AND API$APPEAL.Get_Ap_Attr_Val_Str (ap_id, 3687) = 'G'
                       AND API$APPEAL.Get_Ap_Attr_Val_Id (ap_id, 3689)
                               IS NOT NULL
                --#111840
                UNION ALL
                SELECT *
                  FROM tmp_work_ids, Appeal
                 WHERE     ap_id = x_id
                       AND ap_src IN ('CMES', 'PORTAL', 'USS')
                       AND ap_tp IN ('R.OS')
                --AND EXISTS(SELECT 1 FROM Ap_Document apd WHERE apd_ap = ap_id AND apd_ndt=864  AND apd.history_status='A')
                --AND EXISTS(SELECT 1 FROM Ap_Document_Attr apda WHERE apda_ap = ap_id and apda_nda in (3062, 3066) And apda_val_string is not null and apda.history_status='A')
                --#110881
                UNION ALL
                SELECT *
                  FROM tmp_work_ids, Appeal
                 WHERE     ap_id = x_id
                       AND ap_src IN ('CMES')
                       AND ap_tp IN ('R.GS')
                       AND EXISTS
                               (SELECT 1
                                  FROM Ap_Document apd
                                 WHERE     apd_ap = ap_id
                                       AND apd_ndt = 800
                                       AND apd.history_status = 'A')
                       AND EXISTS
                               (SELECT 1
                                  FROM Ap_Document_Attr apda
                                 WHERE     apda_ap = ap_id
                                       AND apda_nda IN (395,
                                                        396,
                                                        397,
                                                        398,
                                                        402)
                                       AND apda_val_string IS NOT NULL
                                       AND apda.history_status = 'A'))
        LOOP
            uss_esr.api$find.Init_Act_By_Appeal (vAp.x_Id);
        END LOOP;

        --#106772
        INSERT INTO ap_log (apl_id,
                            apl_ap,
                            apl_hs,
                            apl_st,
                            apl_st_old,
                            apl_message,
                            apl_tp)
            SELECT 0,
                   ap_id,
                   p_hs,
                   'S',
                   ap_st,
                   CHR (38) || '5',
                   'SYS'
              FROM appeal, tmp_work_ids
             WHERE ap_id = x_id;

        UPDATE appeal
           SET ap_st = 'S'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_ids
                     WHERE ap_id = x_id);

        FOR rec IN (SELECT x_id AS ap_id FROM tmp_work_ids)
        LOOP
            --Відправляємо заявнику повідомлення про зміну статуса
            Send_Ap_St_Notification (p_Ap_Id => Rec.Ap_Id, p_Ap_St => 'S');
        END LOOP;
    END;

    --Передача даних зверненнь до системи ЄСР за допомогою
    PROCEDURE copy_appeals_to_rnsp_schedule (p_hs histsession.hs_id%TYPE)
    IS
    BEGIN
        copy_full_ap_to_rnsp;

        INSERT INTO ap_log (apl_id,
                            apl_ap,
                            apl_hs,
                            apl_st,
                            apl_st_old,
                            apl_message,
                            apl_tp)
            SELECT 0,
                   ap_id,
                   p_hs,
                   'S',
                   ap_st,
                   CHR (38) || '5',
                   'SYS'
              FROM appeal, tmp_work_ids
             WHERE ap_id = x_id;

        UPDATE appeal
           SET ap_st = 'S'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_ids
                     WHERE ap_id = x_id);

        FOR rec IN (SELECT x_id AS ap_id FROM tmp_work_ids)
        LOOP
            --Відправляємо заявнику повідомлення про зміну статуса
            Send_Ap_St_Notification (p_Ap_Id => Rec.Ap_Id, p_Ap_St => 'S');
        END LOOP;
    END;



    --Повернення Звернення на довведення
    PROCEDURE return_appeal_to_editing (
        p_ap_id       appeal.ap_id%TYPE,
        p_message     ap_log.apl_tp%TYPE:= NULL,
        p_esr_hs_wu   histsession.hs_wu%TYPE:= NULL)       --#73983 2021.12.09
    IS
        l_hs       histsession.hs_id%TYPE;
        l_st_new   appeal.ap_st%TYPE := 'B';
    BEGIN
        --#73983 2021.12.09
        l_hs := TOOLS.GetHistSession (p_esr_hs_wu);

        UPDATE appeal
           SET ap_st = 'B'
         WHERE     ap_id = p_ap_id
               AND ap_st = 'S'
               AND NOT (ap_src = 'PORTAL' AND ap_tp = 'G');

        IF SQL%ROWCOUNT > 0
        THEN
            uss_visit.dnet$community.Reg_Appeal_Status_Send (p_ap_id);
            l_st_new := 'B';
        END IF;

        --#94818 Повернення на доопрацювання заяви 700, створеної в кабінеті НСП
        UPDATE appeal
           SET ap_st = 'X'
         WHERE ap_id = p_ap_id AND ap_src = 'PORTAL' AND ap_tp = 'G';

        IF SQL%ROWCOUNT > 0
        THEN
            uss_visit.dnet$community.Reg_Appeal_Status_Send (p_ap_id);
            l_st_new := 'X';

            UPDATE uss_esr.appeal
               SET ap_st = 'X'
             WHERE ap_id = p_ap_id;
        END IF;

        --#73983 2021.12.09
        Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_Id,
                              p_Apl_Hs        => l_hs,
                              p_Apl_St        => l_st_new,
                              p_Apl_Message   => CHR (38) || '20',
                              p_Apl_St_Old    => 'S',
                              p_Apl_Tp        => 'SYS');

        IF p_message IS NOT NULL
        THEN
            Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_Id,
                                  p_Apl_Hs        => l_hs,
                                  p_Apl_St        => l_st_new,
                                  p_Apl_Message   => p_message,
                                  p_Apl_St_Old    => 'S',
                                  p_Apl_Tp        => 'USR');
        END IF;
    END;

    --Повернення Звернення на відхилення
    --#100823
    PROCEDURE return_appeal_to_reject (
        p_ap_id       appeal.ap_id%TYPE,
        p_message     ap_log.apl_tp%TYPE:= NULL,
        p_esr_hs_wu   histsession.hs_wu%TYPE:= NULL)       --#73983 2021.12.09
    IS
        l_hs       histsession.hs_id%TYPE;
        l_st_new   appeal.ap_st%TYPE := 'X';
    BEGIN
        --#73983 2021.12.09
        l_hs := TOOLS.GetHistSession (p_esr_hs_wu);

        UPDATE appeal
           SET ap_st = 'X'
         WHERE     ap_id = p_ap_id
               AND ap_st = 'S'
               AND (ap_src = 'PORTAL' AND ap_tp = 'SS');

        IF SQL%ROWCOUNT > 0
        THEN
            uss_visit.dnet$community.Reg_Appeal_Status_Send (p_ap_id);
            l_st_new := 'X';
        END IF;

        --#73983 2021.12.09
        Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_Id,
                              p_Apl_Hs        => l_hs,
                              p_Apl_St        => l_st_new,
                              p_Apl_Message   => CHR (38) || '20',
                              p_Apl_St_Old    => 'S',
                              p_Apl_Tp        => 'SYS');

        IF p_message IS NOT NULL
        THEN
            Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_Id,
                                  p_Apl_Hs        => l_hs,
                                  p_Apl_St        => l_st_new,
                                  p_Apl_Message   => p_message,
                                  p_Apl_St_Old    => 'S',
                                  p_Apl_Tp        => 'USR');
        END IF;
    END;

    --Повернення Звернення на статус "виконано"
    PROCEDURE return_appeal_to_done (
        p_ap_id       appeal.ap_id%TYPE,
        p_message     ap_log.apl_tp%TYPE:= NULL,
        p_esr_hs_wu   histsession.hs_wu%TYPE:= NULL)       --#73983 2021.12.09
    IS
        l_hs         histsession.hs_id%TYPE;
        v_ap_st      appeal.ap_st%TYPE;
        v_ap_tp      appeal.ap_tp%TYPE;
        l_IsPFU      NUMBER;
        l_IsExists   NUMBER;
    BEGIN
        --#111418
        SELECT COUNT (1)
          INTO l_IsExists
          FROM uss_visit.appeal
         WHERE ap_id = p_ap_id;

        IF l_IsExists = 0
        THEN
            RETURN;
        END IF;

        --#73983 2021.12.09
        l_hs := TOOLS.GetHistSession (p_esr_hs_wu);


           UPDATE appeal
              SET ap_st = 'V'
            WHERE     ap_id = p_ap_id
                  AND (ap_st = 'S' OR (ap_tp = 'D' AND ap_st = 'FD')) --формування витягу - статус звернення може бути FD
        RETURNING ap_st, ap_tp
             INTO v_ap_st, v_ap_tp;

        IF SQL%ROWCOUNT > 0
        THEN
            UPDATE uss_esr.appeal
               SET ap_st = 'V'
             WHERE ap_id = p_ap_id;

            UPDATE ap_service
               SET aps_st = '2'
             WHERE aps_ap = p_ap_id AND history_status = 'A';
        END IF;

        SELECT COUNT (1)
          INTO l_IsPFU
          FROM uss_visit.appeal, uss_visit.ap_service
         WHERE     aps_ap = ap_id
               AND AP_TP = 'D'
               AND aps_nst = 981
               AND ap_id = p_ap_id;

        IF l_IsPFU > 0
        THEN
            Api$appeal.Write_Log (
                p_Apl_Ap       => p_Ap_Id,
                p_Apl_Hs       => l_hs,
                p_Apl_St       => 'V',
                p_Apl_Message   =>
                    'uss_visit.dnet$exch_uss2ikis.Reg_Appeal_Bnf01_Send(p_ap_id =>p_Apl_Ap);',
                p_Apl_St_Old   =>                                      /*'S'*/
                                  v_ap_st,
                p_Apl_Tp       => 'SYS');
            uss_visit.dnet$exch_uss2ikis.Reg_Appeal_Bnf01_Send (
                p_ap_id   => p_ap_id);
        END IF;

        Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_Id,
                              p_Apl_Hs        => l_hs,
                              p_Apl_St        => 'V',
                              p_Apl_Message   => CHR (38) || '57',
                              p_Apl_St_Old    =>                       /*'S'*/
                                                 v_ap_st,
                              p_Apl_Tp        => 'SYS');

        IF p_message IS NOT NULL
        THEN
            Api$appeal.Write_Log (
                p_Apl_Ap        => p_Ap_Id,
                p_Apl_Hs        => l_hs,
                p_Apl_St        => 'V',
                p_Apl_Message   => p_message,
                p_Apl_St_Old    =>                                     /*'S'*/
                                   v_ap_st,
                p_Apl_Tp        =>                                   /*'USR'*/
                    (CASE v_ap_tp WHEN 'IA' THEN 'SYS' ELSE 'USR' END)); --#88501 звернення по єДопомозі опрацьовуються автоматично
        END IF;
    END;

    PROCEDURE Create_document (p_ap_id     appeal.ap_id%TYPE,
                               p_apd_ndt   ap_Document.apd_ndt%TYPE,
                               p_Apd_Doc   ap_Document.Apd_Doc%TYPE,
                               p_Apd_Dh    ap_Document.apd_Dh%TYPE,
                               p_Com_Wu    appeal.com_wu%TYPE,
                               p_doc_atr   SYS_REFCURSOR)
    IS
        l_apd_Id       ap_Document.apd_id%TYPE;
        l_apd_New_Id   ap_Document.apd_id%TYPE;
        L_List_apda    Type_table_apda;
        l_cnt          NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM appeal
         WHERE ap_id = p_ap_id;

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        FETCH p_doc_atr BULK COLLECT INTO L_List_apda;

        SELECT MAX (apd_id)
          INTO l_apd_id
          FROM ap_Document
         WHERE     apd_ap = p_ap_id
               AND apd_ndt = p_apd_ndt
               AND history_status = 'A';

        IF l_apd_id IS NULL OR l_apd_id < 0
        THEN
            DBMS_OUTPUT.put_line ('INSERT INTO Ap_Document ');

            UPDATE Ap_Document_Attr a
               SET a.History_Status = 'H'
             WHERE a.Apda_Apd IN
                       (SELECT d.apd_id
                          FROM Ap_Document d
                         WHERE     apd_ap = p_ap_id
                               AND apd_ndt = p_apd_ndt
                               AND d.History_Status = 'A');

            UPDATE Ap_Document d
               SET d.History_Status = 'H'
             WHERE     apd_ap = p_ap_id
                   AND apd_ndt = p_apd_ndt
                   AND d.History_Status = 'A';

            INSERT INTO Ap_Document (Apd_Ap,
                                     Apd_Ndt,
                                     Apd_Doc,
                                     Apd_Dh,
                                     History_Status)
                 VALUES (p_ap_id,
                         p_apd_ndt,
                         p_Apd_Doc,
                         p_Apd_Dh,
                         'A')
              RETURNING Apd_Id
                   INTO l_apd_New_Id;
        ELSE
            DBMS_OUTPUT.put_line ('UPDATE Ap_Document SET ');
            l_apd_New_Id := l_apd_id;

            UPDATE Ap_Document
               SET Apd_Doc = p_Apd_Doc, Apd_Dh = p_Apd_Dh
             WHERE Apd_Id = l_apd_id;
        END IF;

        -----Attr
        FOR rec
            IN (SELECT apda_id          AS x_apda_id,
                       p_ap_id          AS x_ap_id,
                       l_apd_New_Id     AS x_apd_Id,
                       rec_nda,
                       rec_val_int,
                       rec_val_sum,
                       rec_val_id,
                       rec_val_dt,
                       rec_val_string
                  FROM TABLE (L_List_apda)
                       LEFT JOIN Ap_Document_Attr
                           ON     apda_nda = rec_nda
                              AND apda_apd = l_apd_New_Id
                              AND History_Status = 'A')
        LOOP
            DBMS_OUTPUT.put_line ('rec_nda = ' || rec.rec_nda);

            IF rec.x_apda_id IS NULL
            THEN
                INSERT INTO Ap_Document_Attr (Apda_Id,
                                              Apda_Ap,
                                              Apda_Apd,
                                              Apda_Nda,
                                              Apda_Val_Id,
                                              Apda_Val_Int,
                                              Apda_Val_Dt,
                                              Apda_Val_String,
                                              Apda_Val_Sum,
                                              History_Status)
                     VALUES (rec.x_apda_id,
                             rec.x_ap_id,
                             rec.x_apd_Id,
                             rec.rec_nda,
                             rec.rec_Val_Id,
                             rec.rec_Val_Int,
                             rec.rec_Val_Dt,
                             rec.rec_Val_String,
                             rec.rec_Val_Sum,
                             'A');
            ELSE
                UPDATE Ap_Document_Attr
                   SET Apda_Val_Id = rec.rec_Val_Id,
                       Apda_Val_Int = rec.rec_Val_Int,
                       Apda_Val_Dt = rec.rec_Val_Dt,
                       Apda_Val_String = rec.rec_Val_String,
                       Apda_Val_Sum = rec.rec_Val_Sum
                 WHERE apda_id = rec.x_apda_id;
            END IF;
        END LOOP;
    END;

    --======================================================================--
    PROCEDURE Create_document730 (
        p_ap_id     appeal.ap_id%TYPE,
        p_Apd_Doc   ap_Document.Apd_Doc%TYPE,
        p_Apd_Dh    ap_Document.apd_Dh%TYPE,
        p_Com_Wu    appeal.com_wu%TYPE,
        p_num       ap_Document_attr.Apda_Val_Int%TYPE,
        p_regdate   ap_Document_attr.Apda_Val_Dt%TYPE)
    IS
        l_apd_Id        ap_Document.apd_id%TYPE;
        l_apd_New_Id    ap_Document.apd_id%TYPE;
        l_apd_ndt       ap_Document.apd_ndt%TYPE := 730;

        l_apda_Id       Ap_Document_Attr.Apda_Id%TYPE;
        l_apda_New_Id   ap_Document_Attr.apda_id%TYPE;
    BEGIN
        SELECT MAX (apd_id)
          INTO l_apd_id
          FROM ap_Document
         WHERE     apd_ap = p_ap_id
               AND apd_ndt = l_apd_ndt
               AND history_status = 'A'
               AND EXISTS
                       (SELECT 1
                          FROM Ap_Document_Attr
                         WHERE     apda_apd = apd_id
                               AND apda_nda = 1112                         --№
                               AND apda_val_int = p_num                    --№
                               AND Ap_Document_Attr.History_Status = 'A')
               AND EXISTS
                       (SELECT 1
                          FROM Ap_Document_Attr
                         WHERE     apda_apd = apd_id
                               AND apda_nda = 1113                      --Дата
                               AND apda_val_dt = p_regdate                 --№
                               AND Ap_Document_Attr.History_Status = 'A');

        IF l_apd_id IS NULL OR l_apd_id < 0
        THEN
            INSERT INTO Ap_Document (Apd_Ap,
                                     Apd_Ndt,
                                     Apd_Doc,
                                     Apd_Dh,
                                     History_Status)
                 VALUES (p_ap_id,
                         l_apd_ndt,
                         p_Apd_Doc,
                         p_Apd_Dh,
                         'A')
              RETURNING Apd_Id
                   INTO l_apd_New_Id;
        ELSE
            l_apd_New_Id := l_apd_id;

            UPDATE Ap_Document
               SET Apd_Doc = p_Apd_Doc, Apd_Dh = p_Apd_Dh
             WHERE Apd_Id = l_apd_id;
        END IF;

        /*
            api$appeal.Save_Document(p_Apd_Id              => l_apd_id,
                                     p_Apd_Ap              => p_ap_id,
                                     p_Apd_Ndt             => l_apd_ndt,
                                     p_Apd_Doc             => NULL,
                                     p_Apd_Vf              => NULL,
                                     p_Apd_App             => NULL,
                                     p_New_Id              => l_apd_New_Id,
                                     p_Com_Wu              => p_Com_Wu,
                                     p_Apd_Dh              => NULL,
                                     p_Apd_Aps             => NULL);
            UPDATE ap_document SET
                Apd_Doc  = p_Apd_Doc,
                Apd_Dh   = p_Apd_Dh
            WHERE Apd_Id = l_apd_New_Id;
        */
        -----Attr
        SELECT MAX (Apda_Id)
          INTO l_Apda_Id
          FROM Ap_Document_Attr
         WHERE     apda_apd = l_apd_New_Id
               AND apda_nda = 1112                                         --№
               AND History_Status = 'A';

        api$appeal.Save_Document_Attr (p_Apda_Id           => l_Apda_Id,
                                       p_Apda_Ap           => p_ap_id,
                                       p_Apda_Apd          => l_apd_New_Id,
                                       p_Apda_Nda          => 1112,
                                       p_Apda_Val_Int      => p_num,
                                       p_Apda_Val_Dt       => NULL,
                                       p_Apda_Val_String   => NULL,
                                       p_Apda_Val_Id       => NULL,
                                       p_Apda_Val_Sum      => NULL,
                                       p_New_Id            => l_Apda_new_Id);

        SELECT MAX (Apda_Id)
          INTO l_Apda_Id
          FROM Ap_Document_Attr
         WHERE     apda_apd = l_Apda_new_Id
               AND apda_nda = 1113                                      --Дата
               AND Ap_Document_Attr.History_Status = 'A';

        api$appeal.Save_Document_Attr (p_Apda_Id           => l_Apda_Id,
                                       p_Apda_Ap           => p_ap_id,
                                       p_Apda_Apd          => l_apd_New_Id,
                                       p_Apda_Nda          => 1113,
                                       p_Apda_Val_Int      => NULL,
                                       p_Apda_Val_Dt       => p_regdate,
                                       p_Apda_Val_String   => NULL,
                                       p_Apda_Val_Id       => NULL,
                                       p_Apda_Val_Sum      => NULL,
                                       p_New_Id            => l_Apda_new_Id);
    --18   Загальна інформація               1112  №
    --18   Загальна інформація               1113  Дата
    --18   Загальна інформація               1114  Рішення  V_DDN_RNSP_DECISION
    --18   Загальна інформація               1115  Підстави прийняття рішення про повернення на доопрацювання
    END;


    PROCEDURE Create_document730 (p_ap_id     appeal.ap_id%TYPE,
                                  p_Apd_Doc   ap_Document.Apd_Doc%TYPE,
                                  p_Apd_Dh    ap_Document.apd_Dh%TYPE,
                                  p_Com_Wu    appeal.com_wu%TYPE,
                                  p_doc_atr   SYS_REFCURSOR)
    IS
        l_apd_Id       ap_Document.apd_id%TYPE;
        l_apd_New_Id   ap_Document.apd_id%TYPE;
        l_apd_ndt      ap_Document.apd_ndt%TYPE := 730;

        L_List_apda    Type_table_apda;
    --    l_apda_Id     Ap_Document_Attr.Apda_Id%TYPE;
    --    l_apda_New_Id ap_Document_Attr.apda_id%TYPE;

    BEGIN
        FETCH p_doc_atr BULK COLLECT INTO L_List_apda;

        SELECT MAX (apd_id)
          INTO l_apd_id
          FROM ap_Document
         WHERE     apd_ap = p_ap_id
               AND apd_ndt = l_apd_ndt
               AND history_status = 'A'
               AND EXISTS
                       (SELECT 1
                          FROM Ap_Document_Attr
                               JOIN TABLE (L_List_apda) ON apda_nda = rec_nda
                         WHERE     apda_apd = apd_id
                               AND apda_nda = 1112                         --№
                               AND apda_val_int = rec_val_int
                               AND Ap_Document_Attr.History_Status = 'A')
               AND EXISTS
                       (SELECT 1
                          FROM Ap_Document_Attr
                               JOIN TABLE (L_List_apda) ON apda_nda = rec_nda
                         WHERE     apda_apd = apd_id
                               AND apda_nda = 1113                      --Дата
                               AND apda_val_dt = rec_val_dt
                               AND Ap_Document_Attr.History_Status = 'A');

        IF l_apd_id IS NULL OR l_apd_id < 0
        THEN
            DBMS_OUTPUT.put_line ('INSERT INTO Ap_Document ');

            UPDATE Ap_Document_Attr a
               SET a.History_Status = 'H'
             WHERE a.Apda_Apd IN
                       (SELECT d.apd_id
                          FROM Ap_Document d
                         WHERE     apd_ap = p_ap_id
                               AND apd_ndt = l_apd_ndt
                               AND d.History_Status = 'A');

            UPDATE Ap_Document d
               SET d.History_Status = 'H'
             WHERE     apd_ap = p_ap_id
                   AND apd_ndt = l_apd_ndt
                   AND d.History_Status = 'A';


            INSERT INTO Ap_Document (Apd_Ap,
                                     Apd_Ndt,
                                     Apd_Doc,
                                     Apd_Dh,
                                     History_Status)
                 VALUES (p_ap_id,
                         l_apd_ndt,
                         p_Apd_Doc,
                         p_Apd_Dh,
                         'A')
              RETURNING Apd_Id
                   INTO l_apd_New_Id;
        ELSE
            DBMS_OUTPUT.put_line ('UPDATE Ap_Document SET ');
            l_apd_New_Id := l_apd_id;

            UPDATE Ap_Document
               SET Apd_Doc = p_Apd_Doc, Apd_Dh = p_Apd_Dh
             WHERE Apd_Id = l_apd_id;
        END IF;

        -----Attr
        FOR rec
            IN (SELECT apda_id          AS x_apda_id,
                       p_ap_id          AS x_ap_id,
                       l_apd_New_Id     AS x_apd_Id,
                       rec_nda,
                       rec_val_int,
                       rec_val_sum,
                       rec_val_id,
                       rec_val_dt,
                       rec_val_string
                  FROM TABLE (L_List_apda)
                       LEFT JOIN Ap_Document_Attr
                           ON     apda_nda = rec_nda
                              AND apda_apd = l_apd_New_Id
                              AND History_Status = 'A')
        LOOP
            DBMS_OUTPUT.put_line ('rec_nda = ' || rec.rec_nda);

            IF rec.x_apda_id IS NULL
            THEN
                INSERT INTO Ap_Document_Attr (Apda_Id,
                                              Apda_Ap,
                                              Apda_Apd,
                                              Apda_Nda,
                                              Apda_Val_Id,
                                              Apda_Val_Int,
                                              Apda_Val_Dt,
                                              Apda_Val_String,
                                              Apda_Val_Sum,
                                              History_Status)
                     VALUES (rec.x_apda_id,
                             rec.x_ap_id,
                             rec.x_apd_Id,
                             rec.rec_nda,
                             rec.rec_Val_Id,
                             rec.rec_Val_Int,
                             rec.rec_Val_Dt,
                             rec.rec_Val_String,
                             rec.rec_Val_Sum,
                             'A');
            ELSE
                UPDATE Ap_Document_Attr
                   SET Apda_Val_Id = rec.rec_Val_Id,
                       Apda_Val_Int = rec.rec_Val_Int,
                       Apda_Val_Dt = rec.rec_Val_Dt,
                       Apda_Val_String = rec.rec_Val_String,
                       Apda_Val_Sum = rec.rec_Val_Sum
                 WHERE apda_id = rec.x_apda_id;
            END IF;
        END LOOP;
    /*
       MERGE INTO Ap_Document_Attr
       USING (  SELECT apda_id      AS x_apda_id,
                       p_ap_id      AS x_ap_id,
                       l_apd_New_Id AS x_apd_Id,
                       rec_nda,
                       rec_val_int,
                       rec_val_sum,
                       rec_val_id,
                       rec_val_dt,
                       rec_val_string
                FROM TABLE(L_List_apda)
                     LEFT JOIN Ap_Document_Attr ON apda_nda = rec_nda AND History_Status = 'A'
                WHERE apda_apd = l_apd_New_Id
              )
       ON (apda_id = x_apda_id)
       WHEN MATCHED THEN UPDATE SET
           apda_id = x_apda_id
    --     Apda_Val_Id     = rec_Val_Id,
    --     Apda_Val_Int    = rec_Val_Int,
    --     Apda_Val_Dt     = rec_Val_Dt,
    --     Apda_Val_String = rec_Val_String,
    --     Apda_Val_Sum    = rec_Val_Sum
       WHEN NOT MATCHED THEN INSERT (Apda_Id, Apda_Ap, Apda_Apd, Apda_Nda, Apda_Val_Id, Apda_Val_Int, Apda_Val_Dt, Apda_Val_String, Apda_Val_Sum, History_Status)
          VALUES (x_apda_id, x_ap_id, x_apd_Id, rec_nda, rec_Val_Id,  rec_Val_Int, rec_Val_Dt,  rec_Val_String, rec_Val_Sum, 'A');*/

    END;



    PROCEDURE Update_document_pdf (p_apd_id    ap_Document.Apd_Id%TYPE,
                                   p_Apd_Doc   ap_Document.Apd_Doc%TYPE,
                                   p_Apd_Dh    ap_Document.apd_Dh%TYPE     --,
                                                                      --p_Com_Wu   appeal.com_wu%TYPE
                                                                      )
    IS
    BEGIN
        UPDATE Ap_Document
           SET Apd_Doc = p_Apd_Doc, Apd_Dh = p_Apd_Dh
         WHERE Apd_Id = p_apd_id;
    END;


    -- info:   Створення документа-рішення
    -- params: p_ap_id - ідентифікатор звернення
    --         p_doc_id - ідентифікатор документа в Е/А
    --         p_dh_id - ідентифікатор зрізу документа в Е/А
    -- note:   #77050
    FUNCTION create_decision_doc (p_ap_id    IN appeal.ap_id%TYPE,
                                  p_doc_id   IN ap_document.apd_doc%TYPE,
                                  p_dh_id    IN ap_document.apd_dh%TYPE)
        RETURN NUMBER
    IS
        v_apd_id   ap_document.apd_id%TYPE;
    BEGIN
        INSERT INTO ap_document (apd_ap,
                                 apd_ndt,
                                 apd_doc,
                                 apd_dh,
                                 history_status)
             VALUES (p_ap_id,
                     10051,
                     p_doc_id,
                     p_dh_id,
                     'A')
          RETURNING apd_id
               INTO v_apd_id;

        RETURN v_apd_id;
    END;

    -- info:   додавання атрибутів документа-рішення
    -- params: p_ap_id - ідентифікатор звернення
    --         p_apd_id - ідентифікатор документа-рішення
    -- note:   #82581
    FUNCTION add_decision_attr (
        p_ap_id             appeal.ap_id%TYPE,
        p_apd_id            ap_document.apd_id%TYPE,
        p_apda_nda          ap_document_attr.apda_nda%TYPE,
        p_apda_val_int      ap_document_attr.apda_val_int%TYPE,
        p_apda_val_dt       ap_document_attr.apda_val_dt%TYPE,
        p_apda_val_string   ap_document_attr.apda_val_string%TYPE,
        p_apda_val_id       ap_document_attr.apda_val_id%TYPE,
        p_apda_val_sum      ap_document_attr.apda_val_sum%TYPE)
        RETURN ap_document_attr.apda_id%TYPE
    IS
        v_apda_id   ap_document_attr.apda_id%TYPE;
    BEGIN
        INSERT INTO ap_document_attr (apda_id,
                                      apda_ap,
                                      apda_apd,
                                      apda_nda,
                                      apda_val_int,
                                      apda_val_dt,
                                      apda_val_string,
                                      apda_val_id,
                                      apda_val_sum,
                                      history_status)
             VALUES (0,
                     p_ap_id,
                     p_apd_id,
                     p_apda_nda,
                     p_apda_val_int,
                     p_apda_val_dt,
                     p_apda_val_string,
                     p_apda_val_id,
                     p_apda_val_sum,
                     'A')
          RETURNING apda_id
               INTO v_apda_id;

        RETURN v_apda_id;
    END;

    FUNCTION Get_visit2esr_html (p_ap NUMBER)
        RETURN XMLTYPE
    IS
        html   XMLTYPE;
    BEGIN
        WITH
            tr
            AS
                (  SELECT v.vea_ap,
                          XMLAGG (XMLELEMENT (
                                      "tr",
                                      XMLCONCAT (
                                          XMLELEMENT ("td", v.vea_id),
                                          XMLELEMENT ("td", v.vea_st_new),
                                          XMLELEMENT ("td", v.vea_st_old),
                                          XMLELEMENT ("td", v.vea_message),
                                          XMLELEMENT ("td", v.vea_hs_ins),
                                          XMLELEMENT (
                                              "td",
                                              (SELECT TO_CHAR (
                                                          h.hs_dt,
                                                          'dd.mm.yy hh24:mi:ss')
                                                 FROM histsession h
                                                WHERE h.hs_id = v.vea_hs_ins)),
                                          XMLELEMENT ("td", v.vea_hs_exec),
                                          XMLELEMENT (
                                              "td",
                                              (SELECT TO_CHAR (
                                                          h.hs_dt,
                                                          'dd.mm.yy hh24:mi:ss')
                                                 FROM histsession h
                                                WHERE h.hs_id = v.vea_hs_exec))))
                                  ORDER BY v.vea_id)    AS xml_tr
                     FROM visit2esr_actions v
                    WHERE v.vea_ap = p_ap
                 GROUP BY v.vea_ap),
            tbl
            AS
                (SELECT vea_ap,
                        XMLELEMENT (
                            "table",
                            XMLATTRIBUTES (1 AS "border"),
                            XMLCONCAT (
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('5%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('5%' AS "width",
                                                   'left' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('5%' AS "width",
                                                   'left' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('50%' AS "width",
                                                   'left' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('5%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('10%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('5%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('10%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "th",
                                    XMLELEMENT (
                                        "tr",
                                        XMLCONCAT (
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'vea_id'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'vea_st_new'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'vea_st_old'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'vea_message'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'vea_hs_ins'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'dt_ins'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'vea_hs_exec'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'dt_exec')))),
                                XMLELEMENT ("tb", xml_tr)))    AS xml_table
                   FROM tr)
        SELECT xml_table
          INTO html
          FROM tbl;

        RETURN html;
    END;


    -- скасування звернення з превіркою на стан для Є-допомоги
    FUNCTION Cancel_Appeals (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_St         VARCHAR2 (10);
        l_St_name    VARCHAR2 (200);
        l_rowcount   PLS_INTEGER;
        l_ret        BOOLEAN := FALSE;
    BEGIN
        SELECT Ap_St, st.DIC_SNAME
          INTO l_St, l_St_name
          FROM Appeal t JOIN uss_ndi.v_ddn_ap_st st ON st.DIC_VALUE = ap_st
         WHERE t.Ap_Id = p_Ap_Id;

        IF l_St IN ('X',
                    'V',
                    'PV',
                    'NS')
        THEN
            RETURN FALSE;
        END IF;

        IF l_St IN ('N',
                    'F',
                    'VW',
                    'VO',
                    'VE')
        THEN
            UPDATE Appeal
               SET Ap_St = Api$appeal.c_Ap_St_Declined
             WHERE     Ap_Id = p_Ap_Id
                   AND Ap_St IN ('N',
                                 'F',
                                 'VW',
                                 'VO',
                                 'VE');

            l_rowcount := SQL%ROWCOUNT;

            IF l_rowcount > 0
            THEN
                UPDATE Ap_Service
                   SET Aps_St = 'V'
                 WHERE Aps_ap = p_Ap_Id;

                l_ret := TRUE;
            ELSE
                l_ret := FALSE;
            END IF;
        ELSIF l_St IN ('S', 'WD'                                    /*, 'NS'*/
                                )
        THEN
            uss_esr.api$personalcase.Calcel_pd_by_appeal (p_Ap_Id, l_ret);

            IF l_ret
            THEN
                UPDATE Appeal
                   SET Ap_St = Api$appeal.c_Ap_St_Declined
                 WHERE Ap_Id = p_Ap_Id AND Ap_St IN ('S', 'WD'      /*, 'NS'*/
                                                              );

                l_rowcount := SQL%ROWCOUNT;

                IF l_rowcount > 0
                THEN
                    UPDATE Ap_Service
                       SET Aps_St = 'V'
                     WHERE Aps_ap = p_Ap_Id;

                    l_ret := TRUE;
                ELSE
                    l_ret := FALSE;
                END IF;
            END IF;
        END IF;

        IF l_ret
        THEN
            Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_id,
                                  p_Apl_Hs        => Tools.Gethistsession,
                                  p_Apl_St        => Api$appeal.c_Ap_St_Declined,
                                  p_Apl_Message   => CHR (38) || '69',
                                  p_Apl_St_Old    => l_St);
        END IF;

        RETURN l_ret;
    END;

    --------------------------------------------------------------------------
    --   Відправка заявнику повідомлення про зміну статуса звернення
    --------------------------------------------------------------------------
    PROCEDURE Send_Ap_St_Notification (p_Ap_Id     IN NUMBER,
                                       p_Ap_St     IN VARCHAR2,
                                       p_Message   IN VARCHAR2 DEFAULT NULL)
    IS
        c_Src_Vst   CONSTANT VARCHAR2 (10) := '35';
        l_Sc_Id              NUMBER;
        l_Sc_Unique          VARCHAR2 (100);
        l_Ntm_Id             NUMBER;
        l_Error              VARCHAR2 (4000);
        l_Title              VARCHAR2 (1000);
        l_Text               VARCHAR2 (4000);
        l_App_Fullname       VARCHAR (1000);
        l_Ap_St_Name         VARCHAR (100);
    BEGIN
        IF NVL (p_Ap_St, '-') NOT IN ('V',
                                      'PV',
                                      'S',
                                      'X',
                                      'D')
        THEN
            RETURN;
        END IF;

        SELECT MAX (App_Sc),
               MAX (Sc_Unique),
               MAX (INITCAP (App_Fn) || ' ' || INITCAP (App_Mn))
          INTO l_Sc_Id, l_Sc_Unique, l_App_Fullname
          FROM Ap_Person JOIN Uss_Person.v_Socialcard ON App_Sc = Sc_Id
         WHERE     App_Ap = p_Ap_Id
               AND History_Status = 'A'
               AND App_Tp IN ('Z', 'O');

        IF l_Sc_Id IS NULL
        THEN
            RETURN;
        END IF;

        SELECT MAX (Dic_Sname)
          INTO l_Ap_St_Name
          FROM Uss_Ndi.v_Ddn_Ap_St
         WHERE Dic_Value = p_Ap_St;

        l_Title := CHR (38) || '21';
        l_Text :=
               CHR (38)
            || '21#pib='
            || l_App_Fullname
            || '#status='
            || l_Ap_St_Name
            || '#sc='
            || l_Sc_Unique;

        Uss_Person.Api$nt_Api.Sendonebynumident (p_Numident   => NULL,
                                                 p_Sc         => l_Sc_Id,
                                                 p_Source     => c_Src_Vst,
                                                 p_Type       => 'COM',
                                                 p_Title      => l_Title,
                                                 p_Text       => l_Text,
                                                 p_Id         => l_Ntm_Id,
                                                 p_Error      => l_Error);

        IF l_Ntm_Id IS NOT NULL
        THEN
            Uss_Person.Api$nt_Api.Makesendtaskbyparams (
                p_Nip_Id     => NULL,
                p_Start_Dt   => NULL,
                p_Stop_Dt    => NULL,
                p_Ntg_Id     => NULL,
                p_Info_Tp    => 'EMAIL',
                p_Source     => c_Src_Vst,
                p_Tp         => 'COM',
                p_Ntm        => l_Ntm_Id);
        END IF;
    END;
BEGIN
    -- Initialization
    NULL;
END API$AP_PROCESSING;
/