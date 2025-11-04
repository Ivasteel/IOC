/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_RN_DOCUMENT
    BEFORE INSERT
    ON uss_rnsp.rn_document
    FOR EACH ROW
BEGIN
    IF (:NEW.rnd_id = 0) OR (:NEW.rnd_id IS NULL)
    THEN
        :NEW.rnd_id := ID_rn_document (:NEW.rnd_id);
    END IF;
END;
/
