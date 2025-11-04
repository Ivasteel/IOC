/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AP_VF_ANSWERS
    BEFORE INSERT
    ON uss_esr.ap_vf_answers
    FOR EACH ROW
BEGIN
    IF (:NEW.apva_id = 0) OR (:NEW.apva_id IS NULL)
    THEN
        :NEW.apva_id := ID_ap_vf_answers (:NEW.apva_id);
    END IF;
END;
/
