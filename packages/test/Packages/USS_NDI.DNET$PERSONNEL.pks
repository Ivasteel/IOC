/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$PERSONNEL
IS
    -- Author  : BOGDAN
    -- Created : 10.10.2023 16:59:35
    -- Purpose : Кадри

    -- #92620
    PROCEDURE Get_Education_Level (p_ose_id   IN     NUMBER,
                                   res_cur       OUT SYS_REFCURSOR);

    -- #92620
    PROCEDURE Query_Education_Level (res_cur OUT SYS_REFCURSOR);

    -- #92620
    PROCEDURE Delete_Education_Level (p_ose_id IN NUMBER);

    -- #92620
    PROCEDURE Save_Education_Level (
        p_ose_id        IN     NUMBER,
        p_OSE_NAME      IN     NDI_OS_EDUCATION_LV.OSE_NAME%TYPE,
        p_OSE_SUBNAME   IN     NDI_OS_EDUCATION_LV.OSE_SUBNAME%TYPE,
        p_new_id           OUT NUMBER);
END DNET$PERSONNEL;
/


GRANT EXECUTE ON USS_NDI.DNET$PERSONNEL TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$PERSONNEL
IS
    -- #92620
    PROCEDURE Get_Education_Level (p_ose_id   IN     NUMBER,
                                   res_cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR SELECT *
                           FROM ndi_os_education_lv t
                          WHERE t.ose_id = p_ose_id;
    END;

    -- #92620
    PROCEDURE Query_Education_Level (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR SELECT *
                           FROM ndi_os_education_lv t
                          WHERE t.history_status = 'A';
    END;

    -- #92620
    PROCEDURE Delete_Education_Level (p_ose_id IN NUMBER)
    IS
    BEGIN
        UPDATE ndi_os_education_lv t
           SET t.history_status = 'H'
         WHERE t.ose_id = p_ose_id;
    END;

    -- #92620
    PROCEDURE Save_Education_Level (
        p_ose_id        IN     NUMBER,
        p_OSE_NAME      IN     NDI_OS_EDUCATION_LV.OSE_NAME%TYPE,
        p_OSE_SUBNAME   IN     NDI_OS_EDUCATION_LV.OSE_SUBNAME%TYPE,
        p_new_id           OUT NUMBER)
    IS
    BEGIN
        IF (p_ose_id IS NULL OR p_ose_id < 0)
        THEN
            INSERT INTO NDI_OS_EDUCATION_LV (OSE_NAME,
                                             OSE_SUBNAME,
                                             HISTORY_STATUS)
                 VALUES (p_OSE_NAME, p_OSE_SUBNAME, 'A')
              RETURNING OSE_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_ose_id;

            UPDATE NDI_OS_EDUCATION_LV
               SET OSE_NAME = p_OSE_NAME, OSE_SUBNAME = p_OSE_SUBNAME
             WHERE OSE_ID = p_OSE_ID;
        END IF;
    END;
BEGIN
    NULL;
END DNET$PERSONNEL;
/