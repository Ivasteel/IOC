/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_SOURCE
    BEFORE INSERT
    ON uss_esr.pd_source
    FOR EACH ROW
BEGIN
    IF (:NEW.pds_id = 0) OR (:NEW.pds_id IS NULL)
    THEN
        :NEW.pds_id := ID_pd_source (:NEW.pds_id);
    END IF;
END;
/
