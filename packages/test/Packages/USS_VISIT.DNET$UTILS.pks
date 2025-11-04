/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$UTILS
IS
    -- Author  : BOGDAN
    -- Created : 25.06.2021 11:26:44
    -- Purpose : Утиліти, версії та інше

    -- список утиліт, документації та релізів на перегляд
    PROCEDURE get_site_info (utils      OUT SYS_REFCURSOR,
                             docs       OUT SYS_REFCURSOR,
                             versions   OUT SYS_REFCURSOR,
                             study      OUT SYS_REFCURSOR);

    -- #75740: к-ство файлов по типам
    PROCEDURE get_site_quick_info (p_res_cur OUT SYS_REFCURSOR);

    -- поточна версія утиліти сканування
    PROCEDURE get_agent_version (p_version OUT VARCHAR2);

    -- вивантаження файлу
    PROCEDURE get_file (p_av_id IN NUMBER, p_file_cur OUT SYS_REFCURSOR);


    -- Логування при підпису
    PROCEDURE WRITE_CRYPTO_LOG (p_event_tp IN VARCHAR2, p_event_info IN CLOB);
END DNET$UTILS;
/


GRANT EXECUTE ON USS_VISIT.DNET$UTILS TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.DNET$UTILS TO II01RC_USS_VISIT_WEB
/


/* Formatted on 8/12/2025 6:00:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$UTILS
IS
    -- список утиліт, документації та релізів на перегляд
    PROCEDURE get_site_info (utils      OUT SYS_REFCURSOR,
                             docs       OUT SYS_REFCURSOR,
                             versions   OUT SYS_REFCURSOR,
                             study      OUT SYS_REFCURSOR)
    IS
    BEGIN
        ikis_sys.ikis_app_info.get_site_info ('USS_VISIT',
                                              utils,
                                              docs,
                                              versions,
                                              study);
    END;

    -- #75740: к-ство файлов по типам
    PROCEDURE get_site_quick_info (p_res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        ikis_sys.ikis_app_info.get_site_quick_info ('USS_VISIT', p_res_cur);
    END;

    -- поточна версія утиліти сканування
    PROCEDURE get_agent_version (p_version OUT VARCHAR2)
    IS
    BEGIN
        ikis_sys.ikis_app_info.get_agent_version ('USS_VISIT', p_version);
    END;


    -- вивантаження файлу
    PROCEDURE get_file (p_av_id IN NUMBER, p_file_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        ikis_sys.ikis_app_info.get_file ('USS_VISIT', p_av_id, p_file_cur);
    END;

    -- Логування при підпису
    PROCEDURE WRITE_CRYPTO_LOG (p_event_tp IN VARCHAR2, p_event_info IN CLOB)
    IS
        l_id   NUMBER;
    BEGIN
        l_id :=
            IKIS_SYSWEB.write_crypto_log (p_event_tp,
                                          p_event_info,
                                          tools.GetCurrWu);
    END;
BEGIN
    NULL;
END DNET$UTILS;
/