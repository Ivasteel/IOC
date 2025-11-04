/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_MSG_TEMPLATE
    BEFORE INSERT
    ON uss_ndi.ndi_msg_template
    FOR EACH ROW
BEGIN
    IF (:NEW.nmt_id = 0) OR (:NEW.nmt_id IS NULL)
    THEN
        :NEW.nmt_id := ID_ndi_msg_template (:NEW.nmt_id);
    END IF;
END;
/
