/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_DOCUMENT
    BEFORE INSERT
    ON uss_esr.pd_document
    FOR EACH ROW
BEGIN
    IF (:NEW.pdo_id = 0) OR (:NEW.pdo_id IS NULL)
    THEN
        :NEW.pdo_id := ID_pd_document (:NEW.pdo_id);
    END IF;
END;
/
