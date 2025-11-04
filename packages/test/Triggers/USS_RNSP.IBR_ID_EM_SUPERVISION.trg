/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_EM_SUPERVISION
    BEFORE INSERT
    ON uss_rnsp.em_supervision
    FOR EACH ROW
BEGIN
    IF (:NEW.emv_id = 0) OR (:NEW.emv_id IS NULL)
    THEN
        :NEW.emv_id := ID_em_supervision (:NEW.emv_id);
    END IF;
END;
/
