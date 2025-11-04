/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_WEB_META
IS
    -- Author  : YURA_A
    -- Created : 11.12.2006 13:34:48
    -- Purpose : Загрузка метаданных

    PROCEDURE Load_web_role (p_wr_id        w_roles.wr_id%TYPE,
                             p_wr_name      w_roles.wr_name%TYPE,
                             p_wr_wut       w_roles.wr_wut%TYPE,
                             p_wr_descr     w_roles.wr_descr%TYPE,
                             p_wr_ss_code   w_roles.wr_ss_code%TYPE);

    PROCEDURE Assign_w_rolw2type (p_wr_id    w_roles2type.wr_id%TYPE,
                                  p_wut_id   w_roles2type.wut_id%TYPE);

    PROCEDURE Load_w_roles_refc (
        p_buffer_table_refc   ikis_common.TReportResult);

    PROCEDURE Load_w_roles2type_refc (
        p_buffer_table_refc   ikis_common.TReportResult);
END IKIS_WEB_META;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_WEB_META FOR IKIS_SYSWEB.IKIS_WEB_META
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO IKIS_WEBPROXY WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_META TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:11:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_WEB_META
IS
    PROCEDURE Load_web_role (p_wr_id        w_roles.wr_id%TYPE,
                             p_wr_name      w_roles.wr_name%TYPE,
                             p_wr_wut       w_roles.wr_wut%TYPE,
                             p_wr_descr     w_roles.wr_descr%TYPE,
                             p_wr_ss_code   w_roles.wr_ss_code%TYPE)
    IS
    BEGIN
        UPDATE w_roles
           SET wr_name = p_wr_name,
               wr_wut = p_wr_wut,
               wr_descr = p_wr_descr,
               wr_ss_code = p_wr_ss_code
         WHERE wr_id = p_wr_id;

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO w_roles (wr_id,
                                 wr_name,
                                 wr_wut,
                                 wr_descr,
                                 wr_ss_code)
                 VALUES (p_wr_id,
                         p_wr_name,
                         p_wr_wut,
                         p_wr_descr,
                         p_wr_ss_code);
        END IF;
    END;

    PROCEDURE Assign_w_rolw2type (p_wr_id    w_roles2type.wr_id%TYPE,
                                  p_wut_id   w_roles2type.wut_id%TYPE)
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM w_roles2type
         WHERE wr_id = p_wr_id AND wut_id = p_wut_id;

        IF l_cnt = 0
        THEN
            INSERT INTO w_roles2type (wr_id, wut_id)
                 VALUES (p_wr_id, p_wut_id);
        END IF;
    END;

    PROCEDURE Load_w_roles_refc (
        p_buffer_table_refc   ikis_common.TReportResult)
    IS
        l_rec   w_roles%ROWTYPE;
    BEGIN
        LOOP
            FETCH p_buffer_table_refc INTO l_rec;

            EXIT WHEN p_buffer_table_refc%NOTFOUND;
            ikis_web_meta.load_web_role (p_wr_id        => l_rec.wr_id,
                                         p_wr_name      => l_rec.wr_name,
                                         p_wr_wut       => l_rec.wr_wut,
                                         p_wr_descr     => l_rec.wr_descr,
                                         p_wr_ss_code   => l_rec.wr_ss_code);
        END LOOP;
    END;

    PROCEDURE Load_w_roles2type_refc (
        p_buffer_table_refc   ikis_common.TReportResult)
    IS
        l_rec   w_roles2type%ROWTYPE;
    BEGIN
        LOOP
            FETCH p_buffer_table_refc INTO l_rec;

            EXIT WHEN p_buffer_table_refc%NOTFOUND;
            ikis_web_meta.assign_w_rolw2type (p_wr_id    => l_rec.wr_id,
                                              p_wut_id   => l_rec.wut_id);
        END LOOP;
    END;
END IKIS_WEB_META;
/