/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$IMPEXP
IS
    -- Author  : BOGDAN
    -- Created : 04.09.2023 16:03:18
    -- Purpose :

    --
    PROCEDURE import_reports (p_r_id IN NUMBER, p_blob IN BLOB);

    PROCEDURE get_report_list (res_cur OUT SYS_REFCURSOR);

    PROCEDURE get_report_file (p_r_id IN NUMBER, res_cur OUT SYS_REFCURSOR);
END dnet$impexp;
/


GRANT EXECUTE ON USS_NDI.DNET$IMPEXP TO DNET_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$IMPEXP TO II01RC_USS_NDI_PORTAL
/

GRANT EXECUTE ON USS_NDI.DNET$IMPEXP TO II01RC_USS_NDI_WEB
/

GRANT EXECUTE ON USS_NDI.DNET$IMPEXP TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$IMPEXP
IS
    PROCEDURE import_reports (p_r_id IN NUMBER, p_blob IN BLOB)
    IS
    BEGIN
        api$impexp.import_reports (p_r_id, p_blob);
    END;

    PROCEDURE get_report_list (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR SELECT *
                           FROM v_ndi_report_type t;
    END;

    PROCEDURE get_report_file (p_r_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        FOR xx IN (SELECT rt_id     AS x_id
                     FROM uss_ndi.v_ndi_report_type
                    WHERE rt_id IN (p_r_id))
        LOOP
            DELETE FROM tmp_lob
                  WHERE x_id = xx.x_id;

            INSERT INTO tmp_lob (x_id, x_clob)
                SELECT xx.x_id,
                       XMLROOT (
                           XMLELEMENT (
                               "report",
                               (SELECT XMLELEMENT (
                                           "ndi_report_type",
                                           XMLELEMENT ("rt_id", rt_id),
                                           XMLELEMENT ("rt_code", rt_code),
                                           XMLELEMENT ("rt_name", rt_name),
                                           XMLELEMENT ("rt_nrg", rt_nrg),
                                           XMLELEMENT ("rt_desc", rt_desc))
                                  FROM uss_ndi.v_ndi_report_type
                                 WHERE rt_id = xx.x_id),
                               (SELECT XMLELEMENT (
                                           "ndi_rpt_group",
                                           XMLELEMENT ("nrg_id", nrg_id),
                                           XMLELEMENT ("nrg_code", nrg_code),
                                           XMLELEMENT ("nrg_name", nrg_name))
                                  FROM uss_ndi.v_ndi_rpt_group,
                                       uss_ndi.v_ndi_report_type
                                 WHERE rt_nrg = nrg_id AND rt_id = xx.x_id),
                               (SELECT XMLELEMENT (
                                           "ndi_rpt_access",
                                           XMLAGG (
                                               XMLELEMENT (
                                                   "row",
                                                   XMLELEMENT ("ra_id",
                                                               ra_id),
                                                   XMLELEMENT ("ra_nrg",
                                                               ra_nrg),
                                                   XMLELEMENT ("ra_rt",
                                                               ra_rt),
                                                   XMLELEMENT (
                                                       "ra_start_dt",
                                                       TO_CHAR (
                                                           ra_start_dt,
                                                           'DD.MM.YYYY HH24:MI:SS')),
                                                   XMLELEMENT (
                                                       "ra_stop_dt",
                                                       TO_CHAR (
                                                           ra_stop_dt,
                                                           'DD.MM.YYYY HH24:MI:SS')),
                                                   XMLELEMENT ("ra_tp",
                                                               ra_tp),
                                                   XMLELEMENT ("ra_wr",
                                                               ra_wr))))
                                  FROM (SELECT ra.*
                                          FROM uss_ndi.v_ndi_rpt_access  ra,
                                               uss_ndi.v_ndi_report_type
                                         WHERE     ra_rt = rt_id
                                               AND rt_id = xx.x_id
                                        UNION
                                        SELECT ra.*
                                          FROM uss_ndi.v_ndi_rpt_access  ra,
                                               uss_ndi.v_ndi_report_type
                                         WHERE     ra_nrg = rt_nrg
                                               AND rt_id = xx.x_id
                                               AND ra_rt IS NULL)),
                               (SELECT XMLELEMENT (
                                           "ndi_rpt_queries",
                                           XMLELEMENT ("rq_id", rq_id),
                                           XMLELEMENT ("rq_rt", rq_rt),
                                           XMLELEMENT (
                                               "rq_query",
                                               TOOLS.encode_base64 (
                                                   TOOLS.ConvertC2B (
                                                       rq_query))),
                                           XMLELEMENT ("rq_tp", rq_tp),
                                           XMLELEMENT ("rq_st", rq_st),
                                           XMLELEMENT (
                                               "rq_start_dt",
                                               TO_CHAR (
                                                   rq_start_dt,
                                                   'DD.MM.YYYY HH24:MI:SS')),
                                           XMLELEMENT (
                                               "rq_stop_dt",
                                               TO_CHAR (
                                                   rq_stop_dt,
                                                   'DD.MM.YYYY HH24:MI:SS')),
                                           XMLELEMENT (
                                               "rq_rpt_header",
                                               CASE
                                                   WHEN rq_rpt_header IS NULL
                                                   THEN
                                                       NULL
                                                   ELSE
                                                       TOOLS.encode_base64 (
                                                           TOOLS.ConvertC2B (
                                                               rq_rpt_header))
                                               END))
                                  FROM uss_ndi.v_ndi_rpt_queries
                                 WHERE rq_rt = xx.x_id),
                               (SELECT XMLELEMENT (
                                           "ndi_rpt_params",
                                           XMLAGG (
                                               XMLELEMENT (
                                                   "row",
                                                   XMLELEMENT ("nrp_id",
                                                               nrp_id),
                                                   XMLELEMENT ("nrp_rt",
                                                               nrp_rt),
                                                   XMLELEMENT ("nrp_code",
                                                               nrp_code),
                                                   XMLELEMENT ("nrp_name",
                                                               nrp_name),
                                                   XMLELEMENT ("nrp_data_tp",
                                                               nrp_data_tp))))
                                  FROM uss_ndi.v_ndi_rpt_params
                                 WHERE nrp_rt = xx.x_id)),
                           VERSION '1.0" encoding="utf-8').getClobVal ()
                  FROM DUAL;
        END LOOP;

        OPEN res_cur FOR
            SELECT t.fn                  AS FileName,
                   t.file_blob           AS Content,
                   'application/xml'     AS Mime_Type
              FROM (SELECT 'export_' || t.x_id || '.xml'     AS fn,
                           tools.ConvertC2B (t.x_clob)       AS file_blob
                      --t.x_clob AS file_blob
                      FROM tmp_lob t
                     WHERE t.x_id = p_r_id) t;
    END;
BEGIN
    NULL;
END dnet$impexp;
/