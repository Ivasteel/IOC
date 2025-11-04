/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$CALC_RIGHT_NEW
IS
    --Перевірка заповненості атрибутів документів - повертає кількість незаповнених атрибутів
    FUNCTION check_documents_filled (p_app        ap_document.apd_app%TYPE,
                                     p_ndt        ap_document.apd_ndt%TYPE,
                                     p_nda_list   VARCHAR2,
                                     p_Is_Need    NUMBER DEFAULT 1)
        RETURN VARCHAR2;

    --Перевірка заповненості атрибутів документа 201 - повертає перелік незаповнених атрибутів
    FUNCTION check_documents_201 (p_app       ap_document.apd_app%TYPE,
                                  p_Is_Need   NUMBER DEFAULT 1)
        RETURN VARCHAR2;

    --Перевірка заповненості атрибутів документа 809 - повертає перелік незаповнених атрибутів
    FUNCTION check_documents_809 (p_app       ap_document.apd_app%TYPE,
                                  p_Is_Need   NUMBER DEFAULT 1)
        RETURN VARCHAR2;

    FUNCTION check_documents_filled_ap (p_ap         ap_document.apd_ap%TYPE,
                                        p_ndt        ap_document.apd_ndt%TYPE,
                                        p_nda_list   VARCHAR2,
                                        p_Is_Need    NUMBER DEFAULT 1)
        RETURN VARCHAR2;

    FUNCTION check_documents_filled_pib (p_app        ap_document.apd_app%TYPE,
                                         p_ndt        ap_document.apd_ndt%TYPE,
                                         p_nda_list   VARCHAR2,
                                         p_nda_pib    VARCHAR2,
                                         p_calc_dt    DATE)
        RETURN VARCHAR2;

    FUNCTION check_documents_filled_val (p_app        ap_document.apd_app%TYPE,
                                         p_ndt        ap_document.apd_ndt%TYPE,
                                         p_nda_list   VARCHAR2,
                                         p_str_list   VARCHAR2,
                                         p_Is_Need    NUMBER DEFAULT 1)
        RETURN VARCHAR2;

    FUNCTION check_documents_filled_600 (p_app   ap_document.apd_app%TYPE,
                                         p_pd    pc_decision.pd_id%TYPE)
        RETURN VARCHAR2;

    --==============================================================--
    --  Перевірка наявності документа
    --==============================================================--
    FUNCTION check_documents_exists (p_app   ap_document.apd_app%TYPE,
                                     p_ndt   ap_document.apd_ndt%TYPE)
        RETURN VARCHAR2;


    --==============================================================--
    --  Перевірка статусу веріфікації документа
    --==============================================================--
    FUNCTION check_vf_st (p_app   ap_document.apd_app%TYPE,
                          p_ndt   ap_document.apd_ndt%TYPE)
        RETURN VARCHAR2;

    FUNCTION check_248_10040 (p_sc    ap_person.app_sc%TYPE,
                              p_app   ap_document.apd_app%TYPE,
                              p_ndt   ap_document.apd_ndt%TYPE)
        RETURN VARCHAR2;

    FUNCTION Check_Income_Statement (p_app       ap_document.apd_app%TYPE,
                                     p_ndt       ap_document.apd_ndt%TYPE,
                                     p_nda       ap_document_attr.apda_nda%TYPE,
                                     p_calc_dt   DATE)
        RETURN VARCHAR2;

    FUNCTION get_month_start (p_dt DATE, p_mode INTEGER:= 1)
        RETURN INTEGER;

    --Отримання параметру Дата з документу по учаснику
    FUNCTION get_doc_dt (p_app       ap_document.apd_app%TYPE,
                         p_ndt       ap_document.apd_ndt%TYPE,
                         p_nda       ap_document_attr.apda_nda%TYPE,
                         p_calc_dt   DATE)
        RETURN DATE;

    --Отримання параметру строка з документу по учаснику
    FUNCTION get_doc_string (p_app       ap_document.apd_app%TYPE,
                             p_ndt       ap_document.apd_ndt%TYPE,
                             p_nda       ap_document_attr.apda_nda%TYPE,
                             p_calc_dt   DATE,
                             p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    --Отримання id параметру документу по учаснику
    FUNCTION get_doc_id (p_app       ap_document.apd_app%TYPE,
                         p_ndt       ap_document.apd_ndt%TYPE,
                         p_nda       ap_document_attr.apda_nda%TYPE,
                         p_calc_dt   DATE,
                         p_default   NUMBER DEFAULT NULL)
        RETURN NUMBER;

    --Отримання текстового параметру документу по документу
    FUNCTION get_attr_string (p_apd       ap_document.apd_id%TYPE,
                              p_nda       ap_document_attr.apda_nda%TYPE,
                              p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    --Отримання наявності документу
    FUNCTION get_doc_count (p_app       ap_document.apd_app%TYPE,
                            p_ndt       ap_document.apd_ndt%TYPE,
                            p_calc_dt   DATE)
        RETURN NUMBER;

    FUNCTION get_doc_list_cnt (p_app        ap_document.apd_app%TYPE,
                               p_list_ndt   VARCHAR2,
                               p_calc_dt    DATE)
        RETURN NUMBER;

    --==============================================================--
    --  Ознака «Категорія отримувача соціальних послуг» - наявність документів
    --==============================================================--
    FUNCTION IsRecip_SS_doc_exists (p_app_id ap_person.app_id%TYPE)
        RETURN NUMBER;

    --==============================================================--
    --                    ПЕРЕВІРКА СПОСОБІВ ВИПЛАТ
    --==============================================================--
    FUNCTION Validate_pdm_pay (P_PD_ID IN NUMBER)
        RETURN VARCHAR2;

    --Перевірка наявності права на допомогу
    PROCEDURE init_right_for_decision (p_mode           INTEGER, --1=з p_pd_id, 2=з таблиці tmp_work_ids
                                       p_pd_id          pc_decision.pd_id%TYPE,
                                       p_messages   OUT SYS_REFCURSOR);


    --+++++++++++++++++++++
    PROCEDURE dbms_output_decision_info (p_id NUMBER);

    PROCEDURE dbms_output_appeal_info (p_id NUMBER);

    PROCEDURE Test_right (id NUMBER);
--+++++++++++++++++++++

END;
/
