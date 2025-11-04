/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NST_INCOME_ORDER
    BEFORE INSERT
    ON uss_ndi.ndi_nst_income_order
    FOR EACH ROW
BEGIN
    IF (:NEW.nio_id = 0) OR (:NEW.nio_id IS NULL)
    THEN
        :NEW.nio_id := ID_ndi_nst_income_order (:NEW.nio_id);
    END IF;
END;
/
