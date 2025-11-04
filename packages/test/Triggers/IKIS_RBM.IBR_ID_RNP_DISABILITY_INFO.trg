/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_RNP_DISABILITY_INFO
    BEFORE INSERT
    ON ikis_rbm.rnp_disability_info
    FOR EACH ROW
BEGIN
    IF (:NEW.rnpd_id = 0) OR (:NEW.rnpd_id IS NULL)
    THEN
        :NEW.rnpd_id := ID_rnp_disability_info (:NEW.rnpd_id);
    END IF;
END;
/
