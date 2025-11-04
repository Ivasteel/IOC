/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_RNSP2VISIT_ACTIONS
    BEFORE INSERT
    ON uss_rnsp.rnsp2visit_actions
    FOR EACH ROW
BEGIN
    IF (:NEW.rva_id = 0) OR (:NEW.rva_id IS NULL)
    THEN
        :NEW.rva_id := ID_rnsp2visit_actions (:NEW.rva_id);
    END IF;
END;
/
