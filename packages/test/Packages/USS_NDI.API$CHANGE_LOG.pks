/* Formatted on 8/12/2025 5:55:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$CHANGE_LOG
IS
    -- Author  : VANO
    -- Created : 07.11.2024 12:26:31
    -- Purpose : Функції ведення журналу змін довідників

    --Формування запису в журналі змін довідників
    PROCEDURE write_change_log (
        p_ncl_object       ndi_change_log.ncl_object%TYPE,
        p_ncl_action       ndi_change_log.ncl_action%TYPE,
        p_ncl_record_id    ndi_change_log.ncl_record_id%TYPE,
        p_ncl_hs           ndi_change_log.ncl_hs%TYPE,
        p_ncl_decription   VARCHAR2 DEFAULT NULL);
END API$CHANGE_LOG;
/


/* Formatted on 8/12/2025 5:55:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$CHANGE_LOG
IS
    --Формування запису в журналі змін довідників
    PROCEDURE write_change_log (
        p_ncl_object       ndi_change_log.ncl_object%TYPE,
        p_ncl_action       ndi_change_log.ncl_action%TYPE,
        p_ncl_record_id    ndi_change_log.ncl_record_id%TYPE,
        p_ncl_hs           ndi_change_log.ncl_hs%TYPE,
        p_ncl_decription   VARCHAR2 DEFAULT NULL)
    IS
        l_description        VARCHAR2 (32000);
        l_description_part   VARCHAR2 (4000);
        l_iter               INTEGER;
        l_hs                 ndi_change_log.ncl_hs%TYPE;
    BEGIN
        IF    p_ncl_object IS NULL
           OR p_ncl_action IS NULL
           OR p_ncl_record_id IS NULL
        THEN
            raise_application_error (
                -20000,
                'В функцію запису журналу змін довідників не передано довідник або дію, або ідентифікатор!');
        END IF;

        IF p_ncl_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        ELSE
            l_hs := p_ncl_hs;
        END IF;

        l_description := p_ncl_decription;
        --!!!! Дописати для випадку НЕ передачі p_ncl_decription (передали NULL) блок коду, який спробує на основі p_ncl_object та p_ncl_record_id сформувати
        --повідомлення виду: 'Комантар_поля_1=значення_поля_1;CRLF;....;Комантар_поля_N=значення_поля_N'. Прибираючи з цього повідомлення поля _ID, _HS, _HS_INS, _HS_DEL

        l_iter := 1;
        l_description_part :=
            SUBSTR (l_description, 4000 * (l_iter - 1) + 1, 4000);

        LOOP
            INSERT INTO ndi_change_log (ncl_id,
                                        ncl_hs,
                                        ncl_object,
                                        ncl_action,
                                        ncl_record_id,
                                        ncl_change_description,
                                        ncl_part)
                 VALUES (0,
                         l_hs,
                         p_ncl_object,
                         p_ncl_action,
                         p_ncl_record_id,
                         l_description_part,
                         l_iter);

            l_iter := l_iter + 1;
            l_description_part :=
                SUBSTR (l_description, 4000 * (l_iter - 1) + 1, 4000);

            EXIT WHEN    l_description_part IS NULL
                      OR LENGTH (l_description_part) = 0;
        END LOOP;
    END;
BEGIN
    NULL;
END API$CHANGE_LOG;
/