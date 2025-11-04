/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_RPT_QUERIES
    BEFORE INSERT
    ON uss_ndi.ndi_rpt_queries
    FOR EACH ROW
BEGIN
    IF (:NEW.rq_id = 0) OR (:NEW.rq_id IS NULL)
    THEN
        :NEW.rq_id := ID_ndi_rpt_queries (:NEW.rq_id);
    END IF;
END;
/
