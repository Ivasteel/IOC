/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_RNSP_TARIFF
    BEFORE INSERT
    ON uss_rnsp.rnsp_tariff
    FOR EACH ROW
BEGIN
    IF (:NEW.rnspt_id = 0) OR (:NEW.rnspt_id IS NULL)
    THEN
        :NEW.rnspt_id := ID_rnsp_tariff (:NEW.rnspt_id);
    END IF;
END;
/
