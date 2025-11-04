/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_FEATURES
    BEFORE INSERT
    ON uss_esr.pd_features
    FOR EACH ROW
BEGIN
    IF (:NEW.pde_id = 0) OR (:NEW.pde_id IS NULL)
    THEN
        :NEW.pde_id := ID_pd_features (:NEW.pde_id);
    END IF;
END;
/
