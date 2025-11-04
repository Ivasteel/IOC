/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_RN_PERSON
    BEFORE INSERT
    ON ikis_rbm.rn_person
    FOR EACH ROW
BEGIN
    IF (:NEW.rnp_id = 0) OR (:NEW.rnp_id IS NULL)
    THEN
        :NEW.rnp_id := ID_rn_person (:NEW.rnp_id);
    END IF;
END;
/
