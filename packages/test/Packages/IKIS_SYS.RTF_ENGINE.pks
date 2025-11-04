/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.rtf_engine
    AUTHID CURRENT_USER
IS
    -- Author  : FIRICH
    -- Created : 17.04.2009 15:24:37
    -- Purpose : обертка для rtf-движка из IKIS_SYSWEB

    PROCEDURE AddDataset (p_dataset IN VARCHAR2, p_sql IN VARCHAR2);

    PROCEDURE AddParam (P_PARAM_NAME IN VARCHAR2, P_PARAM_VALUE VARCHAR2);

    PROCEDURE AddRelation (pmaster        IN VARCHAR2,
                           pmasterfield   IN VARCHAR2,
                           pdetail        IN VARCHAR2,
                           pdetailfield   IN VARCHAR2);

    PROCEDURE AddSummary (pdataset   IN VARCHAR2,
                          pfield     IN VARCHAR2,
                          ptype      IN VARCHAR2,
                          pformat    IN VARCHAR2);

    PROCEDURE DatasetIntoReport (preport OUT BLOB);

    FUNCTION ExistsDataset (p_dataset IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION ExistsRelation (pmaster   IN VARCHAR2,
                             pdetail   IN VARCHAR2,
                             ptype     IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION ExistsSummary (pdataset      IN VARCHAR2,
                            pfield        IN VARCHAR2,
                            ptype         IN VARCHAR2,
                            ptypeexists   IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION GetParamValue (p_param_name IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE InitReport (P_SS_CODE IN VARCHAR2, P_CODE IN VARCHAR2);

    PROCEDURE PublishReport;

    FUNCTION PublishReportBlob
        RETURN BLOB;
END rtf_engine;
/


CREATE OR REPLACE PUBLIC SYNONYM RTF_ENGINE FOR IKIS_SYS.RTF_ENGINE
/


GRANT EXECUTE ON IKIS_SYS.RTF_ENGINE TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RTF_ENGINE TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RTF_ENGINE TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RTF_ENGINE TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RTF_ENGINE TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RTF_ENGINE TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RTF_ENGINE TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RTF_ENGINE TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RTF_ENGINE TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RTF_ENGINE TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RTF_ENGINE TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RTF_ENGINE TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.rtf_engine
IS
    PROCEDURE InitReport (P_SS_CODE IN VARCHAR2, P_CODE IN VARCHAR2)
    IS
    BEGIN
        ikis_sysweb.reportfl_engine.InitReport (P_SS_CODE, P_CODE);
    END;

    PROCEDURE addparam (P_PARAM_NAME IN VARCHAR2, P_PARAM_VALUE VARCHAR2)
    IS
    BEGIN
        ikis_sysweb.reportfl_engine.ADDPARAM (P_PARAM_NAME, P_PARAM_VALUE);
    END;

    PROCEDURE adddataset (p_dataset IN VARCHAR2, p_sql IN VARCHAR2)
    IS
    BEGIN
        ikis_sysweb.reportfl_engine.adddataset (p_dataset, p_sql);
    END;

    FUNCTION existsdataset (p_dataset IN VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN ikis_sysweb.reportfl_engine.existsdataset (p_dataset);
    END;

    PROCEDURE addrelation (pmaster        IN VARCHAR2,
                           pmasterfield   IN VARCHAR2,
                           pdetail        IN VARCHAR2,
                           pdetailfield   IN VARCHAR2)
    IS
    BEGIN
        ikis_sysweb.reportfl_engine.addrelation (pmaster,
                                                 pmasterfield,
                                                 pdetail,
                                                 pdetailfield);
    END;

    FUNCTION existsrelation (pmaster   IN VARCHAR2,
                             pdetail   IN VARCHAR2,
                             ptype     IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN ikis_sysweb.reportfl_engine.existsrelation (pmaster,
                                                           pdetail,
                                                           ptype);
    END;

    PROCEDURE addsummary (pdataset   IN VARCHAR2,
                          pfield     IN VARCHAR2,
                          ptype      IN VARCHAR2,
                          pformat    IN VARCHAR2)
    IS
    BEGIN
        ikis_sysweb.reportfl_engine.addsummary (pdataset,
                                                pfield,
                                                ptype,
                                                pformat);
    END;

    FUNCTION existssummary (pdataset      IN VARCHAR2,
                            pfield        IN VARCHAR2,
                            ptype         IN VARCHAR2,
                            ptypeexists   IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN ikis_sysweb.reportfl_engine.existssummary (pdataset,
                                                          pfield,
                                                          ptype,
                                                          ptypeexists);
    END;

    FUNCTION getparamvalue (p_param_name IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN ikis_sysweb.reportfl_engine.getparamvalue (p_param_name);
    END;

    PROCEDURE datasetintoreport (preport OUT BLOB)
    IS
    BEGIN
        ikis_sysweb.reportfl_engine.datasetintoreport (preport);
    END;

    PROCEDURE publishreport
    IS
    BEGIN
        ikis_sysweb.reportfl_engine.publishreport;
    END;

    FUNCTION publishreportblob
        RETURN BLOB
    IS
    BEGIN
        RETURN ikis_sysweb.reportfl_engine.publishreportblob;
    END;
BEGIN
    -- initialization
    NULL;
END rtf_engine;
/